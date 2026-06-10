// Deploy: supabase functions deploy send-notification-email --no-verify-jwt
// Env: RESEND_API_KEY

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? '';

serve(async (req) => {
  const { to, subject, html } = await req.json();

  if (!to || !subject || !html) {
    return new Response(JSON.stringify({ error: 'Missing to, subject, or html' }), { status: 400 });
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
  return new Response(JSON.stringify(data), {
    status: res.ok ? 200 : 500,
    headers: { 'Content-Type': 'application/json' },
  });
});
