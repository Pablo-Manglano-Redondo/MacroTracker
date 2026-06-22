// Deploy: supabase functions deploy send-notification-email --no-verify-jwt
// Env: RESEND_API_KEY

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { resolveRequestLocale, t } from '../_shared/i18n.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? '';

serve(async (req) => {
  const locale = resolveRequestLocale(req);
  try {
    const { to, subject, html } = await req.json();

    if (!to || !subject || !html) {
      return new Response(
        JSON.stringify({ error: t(locale, 'sendNotificationEmail.missingPayload') }),
        { status: 400 },
      );
    }

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'MacroTracker <notifications@macrotracker.app>',
        to,
        subject,
        html,
      }),
    });

    const data = await res.json();
    if (!res.ok) {
      console.error('[send-notification-email] resend failed', data);
      return new Response(
        JSON.stringify({ error: t(locale, 'sendNotificationEmail.requestFailed') }),
        { status: 500, headers: { 'Content-Type': 'application/json' } },
      );
    }

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('[send-notification-email] failed', error);
    return new Response(
      JSON.stringify({ error: t(locale, 'sendNotificationEmail.requestFailed') }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
