import Stripe from "npm:stripe@17.7.0";
import { createClient } from "npm:@supabase/supabase-js@2.48.1";
import { resolveRequestLocale, t } from "../_shared/i18n.ts";
import { authenticateUser } from "../_shared/auth.ts";
import { corsHeaders, jsonResponse } from "../_shared/cors.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";

const serviceClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

Deno.serve(async (request) => {
  const locale = resolveRequestLocale(request);

  if (request.method === "OPTIONS") {
    return new Response(null, {
      headers: corsHeaders,
    });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: t(locale, "common.methodNotAllowed") }, 405);
  }

  if (!stripeSecretKey) {
    return jsonResponse({
      error: t(locale, "stripeProPortal.missingSecretKey"),
    }, 500);
  }

  const { user, errorResponse } = await authenticateUser(request, locale, corsHeaders);
  if (errorResponse) {
    return errorResponse;
  }
  if (!user) {
    return jsonResponse({ error: t(locale, "common.invalidAuthentication") }, 401);
  }

  // Fetch the professional profile to get the stripe_customer_id
  const { data: professional, error: professionalError } = await serviceClient
    .from("professionals")
    .select("id, stripe_customer_id")
    .eq("user_id", user.id)
    .single();

  if (professionalError || !professional) {
    return jsonResponse({
      code: "missing_professional_profile",
      error: t(locale, "stripeProPortal.missingProfessionalProfile"),
    }, 400);
  }

  if (!professional.stripe_customer_id) {
    return jsonResponse({
      code: "missing_stripe_customer",
      error: t(locale, "stripeProPortal.missingStripeCustomer"),
    }, 400);
  }

  const body = await request.json().catch(() => ({}));
  const origin = body.origin || request.headers.get("origin") || "";

  const stripe = new Stripe(stripeSecretKey, {
    apiVersion: "2025-02-24.acacia",
  });

  try {
    const session = await stripe.billingPortal.sessions.create({
      customer: professional.stripe_customer_id,
      return_url: origin || undefined,
    });

    return jsonResponse({
      url: session.url,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return jsonResponse({
      error: t(locale, "stripeProPortal.portalSessionCreationFailed", { details: message }),
    }, 500);
  }
});
