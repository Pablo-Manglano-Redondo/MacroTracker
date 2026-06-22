// Deploy: supabase functions deploy send-push-notification --no-verify-jwt
// Env (option 1 - HTTP v1, recommended):
//   FCM_SERVICE_ACCOUNT_JSON - full service account JSON key (with private_key, client_email, project_id)
// Env (option 2 - legacy, deprecated):
//   FCM_SERVER_KEY - from Firebase Console > Cloud Messaging > Server key
// Invoked by DB trigger or directly: POST with { user_id, title, body, data }

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { SignJWT, importPKCS8 } from 'https://deno.land/x/jose@v5.9.6/index.ts';
import { resolveRequestLocale, t, type RequestLocale } from '../_shared/i18n.ts';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY') ?? '';
const FCM_SERVICE_ACCOUNT_JSON = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON') ?? '';

const GOOGLE_OAUTH_URL = 'https://oauth2.googleapis.com/token';
const FCM_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

let _cachedToken: { token: string; expiresAt: number } | null = null;

async function getOAuthToken(locale: RequestLocale): Promise<string> {
  if (_cachedToken && Date.now() < _cachedToken.expiresAt) {
    return _cachedToken.token;
  }

  let sa: { client_email: string; private_key: string; project_id: string };
  try {
    sa = JSON.parse(FCM_SERVICE_ACCOUNT_JSON);
  } catch {
    throw new Error(t(locale, 'sendPushNotification.invalidServiceAccountJson'));
  }

  const now = Math.floor(Date.now() / 1000);
  const jwt = await new SignJWT({
    iss: sa.client_email,
    scope: FCM_SCOPE,
    aud: GOOGLE_OAUTH_URL,
    iat: now,
    exp: now + 3600,
  })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .sign(await importPKCS8(sa.private_key, 'RS256'));

  const res = await fetch(GOOGLE_OAUTH_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(t(locale, 'sendPushNotification.oauthFailed', {
      details: data.error_description ?? data.error ?? 'unknown',
    }));
  }

  _cachedToken = { token: data.access_token, expiresAt: now + data.expires_in - 300 };
  return data.access_token;
}

function buildV1Payload(token: string, title: string, body: string | null, data: Record<string, string> | undefined, platform: string) {
  const msg: Record<string, unknown> = {
    token,
    notification: { title, body: body ?? '' },
    data: { ...(data ?? {}), click_action: 'FLUTTER_NOTIFICATION_CLICK' },
  };
  if (platform === 'android') {
    msg.android = {
      priority: 'high',
      notification: { sound: 'default', channel_id: 'push_notifications' },
    };
  } else if (platform === 'ios') {
    msg.apns = {
      payload: { aps: { sound: 'default', badge: 1 } },
    };
  }
  return { message: msg };
}

async function sendV1(locale: RequestLocale, token: string, title: string, body: string | null, data: Record<string, string> | undefined, platform: string, projectId: string) {
  const accessToken = await getOAuthToken(locale);
  const payload = buildV1Payload(token, title, body, data, platform);

  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const result = await res.json();
  if (!res.ok) {
    console.error('[send-push-notification] FCM v1 rejected notification', result);
  }
  return {
    success: res.ok,
    error: res.ok ? undefined : t(locale, 'sendPushNotification.providerRejected'),
  };
}

async function sendLegacy(locale: RequestLocale, token: string, title: string, body: string | null, data: Record<string, string> | undefined) {
  const payload = {
    to: token,
    notification: { title, body: body ?? '', sound: 'default' },
    data: { ...(data ?? {}), click_action: 'FLUTTER_NOTIFICATION_CLICK' },
    priority: 'high',
  };

  const res = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${FCM_SERVER_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const result = await res.json();
  if (!res.ok) {
    console.error('[send-push-notification] FCM legacy rejected notification', result);
  }
  return {
    success: res.ok,
    error: res.ok ? undefined : t(locale, 'sendPushNotification.providerRejected'),
  };
}

serve(async (req) => {
  const locale = resolveRequestLocale(req);
  try {
    const { user_id, title, body, data } = await req.json();

    if (!user_id || !title) {
      return new Response(
        JSON.stringify({ error: t(locale, 'sendPushNotification.missingUserIdOrTitle') }),
        { status: 400 },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    const { data: tokens, error } = await supabase
      .from('device_tokens')
      .select('token, platform')
      .eq('user_id', user_id);

    if (error) {
      console.error('[send-push-notification] token lookup failed', error);
      throw error;
    }
    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, reason: t(locale, 'sendPushNotification.noTokens') }),
        { status: 200 },
      );
    }

    const useV1 = !!FCM_SERVICE_ACCOUNT_JSON;
    let projectId = '';
    if (useV1) {
      try { projectId = JSON.parse(FCM_SERVICE_ACCOUNT_JSON).project_id; } catch { /* ignore */ }
    }

    const results: { token: string; success: boolean; error?: string }[] = [];

    for (const t of tokens) {
      try {
        const result = useV1
          ? await sendV1(locale, t.token, title, body, data, t.platform, projectId)
          : await sendLegacy(locale, t.token, title, body, data);
        results.push({ token: t.token, ...result });
      } catch (err) {
        console.error('[send-push-notification] per-token delivery failed', err);
        results.push({
          token: t.token,
          success: false,
          error: t(locale, 'sendPushNotification.deliveryFailed'),
        });
      }
    }

    const sent = results.filter(r => r.success).length;
    return new Response(JSON.stringify({ sent, total: tokens.length, results }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('[send-push-notification] request failed', err);
    return new Response(
      JSON.stringify({ error: t(locale, 'sendPushNotification.requestFailed') }),
      { status: 500 },
    );
  }
});
