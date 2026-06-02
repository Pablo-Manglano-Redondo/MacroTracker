import Stripe from "npm:stripe@17.7.0";
import { createClient } from "npm:@supabase/supabase-js@2.48.1";
import { normalizeProTier } from "../_shared/pro_billing.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2025-02-24.acacia",
});

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const starterPriceId = Deno.env.get("STRIPE_PRO_STARTER_PRICE_ID") ?? "";
const growthPriceId = Deno.env.get("STRIPE_PRO_GROWTH_PRICE_ID") ?? "";
const studioPriceId = Deno.env.get("STRIPE_PRO_STUDIO_PRICE_ID") ?? "";

const serviceClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      headers: corsHeaders(),
    });
  }
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authHeader = request.headers.get("authorization");
  if (!authHeader) {
    return json({ error: "Authentication is required" }, 401);
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  const { data: authData, error: authError } = await serviceClient.auth.getUser(
    token,
  );
  if (authError || !authData.user) {
    return json({ error: "Invalid authentication" }, 401);
  }

  const body = await request.json().catch(() => ({}));
  const tier = normalizeProTier(body.tier);
  const origin = body.origin || request.headers.get("origin") || "";
  const price = priceForTier(tier);
  if (!price) {
    return json({ error: `Missing Stripe price for tier ${tier}` }, 500);
  }

  const { data: professional, error: professionalError } = await serviceClient
    .from("professionals")
    .select("id, display_name, business_name, stripe_customer_id")
    .eq("user_id", authData.user.id)
    .single();
  if (professionalError || !professional) {
    return json({ error: "Professional profile must be created first" }, 400);
  }

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    customer: professional.stripe_customer_id || undefined,
    customer_email: professional.stripe_customer_id
      ? undefined
      : authData.user.email ?? undefined,
    client_reference_id: professional.id,
    line_items: [{ price, quantity: 1 }],
    success_url: `${origin}?checkout=success`,
    cancel_url: `${origin}?checkout=cancelled`,
    metadata: {
      professional_id: professional.id,
      tier,
    },
    subscription_data: {
      metadata: {
        professional_id: professional.id,
        tier,
      },
    },
  });

  return json({ url: session.url });
});

function priceForTier(tier: string) {
  if (tier === "studio") return studioPriceId;
  if (tier === "growth") return growthPriceId;
  return starterPriceId;
}

function json(body: unknown, status = 200) {
  return Response.json(body, {
    status,
    headers: corsHeaders(),
  });
}

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}
