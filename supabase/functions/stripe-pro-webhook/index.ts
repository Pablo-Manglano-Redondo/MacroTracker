import Stripe from "npm:stripe@17.7.0";
import { createClient } from "npm:@supabase/supabase-js@2.48.1";
import { mapSubscriptionToProConfig } from "../_shared/pro_billing.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
const webhookSecret = Deno.env.get("STRIPE_PRO_WEBHOOK_SECRET") ?? "";

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  if (!stripeSecretKey || !webhookSecret) {
    return new Response("Missing Stripe webhook configuration", {
      status: 400,
    });
  }

  const signature = request.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Missing Stripe signature", {
      status: 400,
    });
  }

  const rawBody = await request.text();
  const stripe = new Stripe(stripeSecretKey, {
    apiVersion: "2025-02-24.acacia",
  });
  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      rawBody,
      signature,
      webhookSecret,
    );
  } catch (error) {
    return new Response(`Invalid Stripe signature: ${errorMessage(error)}`, {
      status: 400,
    });
  }

  try {
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutSession(
          event.data.object as Stripe.Checkout.Session,
        );
        break;
      case "customer.subscription.created":
      case "customer.subscription.updated":
      case "customer.subscription.deleted":
        await handleSubscription(event.data.object as Stripe.Subscription);
        break;
      default:
        break;
    }
  } catch (error) {
    return new Response(`Webhook handling failed: ${errorMessage(error)}`, {
      status: 500,
    });
  }

  return Response.json({ received: true });
});

async function handleCheckoutSession(session: Stripe.Checkout.Session) {
  const professionalId = session.client_reference_id ??
    session.metadata?.professional_id;
  if (!professionalId) {
    return;
  }

  await updateProfessionalBilling({
    professionalId,
    customerId: asString(session.customer),
    subscriptionId: asString(session.subscription),
    tier: session.metadata?.tier,
    subscriptionStatus: "active",
  });
}

async function handleSubscription(subscription: Stripe.Subscription) {
  const professionalId = subscription.metadata?.professional_id;
  if (!professionalId) {
    return;
  }

  await updateProfessionalBilling({
    professionalId,
    customerId: asString(subscription.customer),
    subscriptionId: subscription.id,
    tier: subscription.metadata?.tier,
    subscriptionStatus: subscription.status,
  });
}

async function updateProfessionalBilling({
  professionalId,
  customerId,
  subscriptionId,
  tier,
  subscriptionStatus,
}: {
  professionalId: string;
  customerId: string | null;
  subscriptionId: string | null;
  tier?: string | null;
  subscriptionStatus: string;
}) {
  const config = mapSubscriptionToProConfig(subscriptionStatus, tier);
  const update = {
    pro_status: config.status,
    client_limit: config.clientLimit,
    stripe_customer_id: customerId,
    stripe_subscription_id: subscriptionId,
    updated_at: new Date().toISOString(),
  };

  const { error } = await supabase
    .from("professionals")
    .update(update)
    .eq("id", professionalId);

  if (error) {
    throw error;
  }
}

function asString(value: { id?: string } | string | null) {
  if (typeof value === "string") {
    return value;
  }
  return value?.id ?? null;
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : String(error);
}
