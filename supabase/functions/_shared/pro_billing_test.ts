import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  clientLimitForTier,
  mapSubscriptionToProConfig,
  normalizeBillingInterval,
  normalizeProTier,
} from "./pro_billing.ts";

Deno.test("normalizeProTier falls back to starter", () => {
  assertEquals(normalizeProTier(undefined), "starter");
  assertEquals(normalizeProTier("unknown"), "starter");
  assertEquals(normalizeProTier("GROWTH"), "growth");
  assertEquals(normalizeProTier("studio"), "studio");
});

Deno.test("clientLimitForTier maps production tiers", () => {
  assertEquals(clientLimitForTier("starter"), 10);
  assertEquals(clientLimitForTier("growth"), 50);
  assertEquals(clientLimitForTier("studio"), 500);
});

Deno.test("normalizeBillingInterval supports annual aliases", () => {
  assertEquals(normalizeBillingInterval(undefined), "monthly");
  assertEquals(normalizeBillingInterval("year"), "annual");
  assertEquals(normalizeBillingInterval("annual"), "annual");
});

Deno.test("mapSubscriptionToProConfig keeps tier limits for valid billing states", () => {
  assertEquals(mapSubscriptionToProConfig("trialing", "starter"), {
    status: "trialing",
    tier: "starter",
    clientLimit: 10,
    billingInterval: "monthly",
  });
  assertEquals(mapSubscriptionToProConfig("active", "growth", "annual"), {
    status: "active",
    tier: "growth",
    clientLimit: 50,
    billingInterval: "annual",
  });
  assertEquals(mapSubscriptionToProConfig("past_due", "studio"), {
    status: "past_due",
    tier: "studio",
    clientLimit: 500,
    billingInterval: "monthly",
  });
});

Deno.test("mapSubscriptionToProConfig cancels or inactivates unsafe states", () => {
  assertEquals(mapSubscriptionToProConfig("canceled", "growth"), {
    status: "canceled",
    tier: "growth",
    clientLimit: 50,
    billingInterval: "monthly",
  });
  assertEquals(mapSubscriptionToProConfig("incomplete", "growth"), {
    status: "inactive",
    tier: "growth",
    clientLimit: 50,
    billingInterval: "monthly",
  });
});
