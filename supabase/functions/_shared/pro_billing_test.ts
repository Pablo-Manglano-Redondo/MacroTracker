import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  clientLimitForTier,
  mapSubscriptionToProConfig,
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

Deno.test("mapSubscriptionToProConfig keeps tier limits for valid billing states", () => {
  assertEquals(mapSubscriptionToProConfig("trialing", "starter"), {
    status: "trialing",
    tier: "starter",
    clientLimit: 10,
  });
  assertEquals(mapSubscriptionToProConfig("active", "growth"), {
    status: "active",
    tier: "growth",
    clientLimit: 50,
  });
  assertEquals(mapSubscriptionToProConfig("past_due", "studio"), {
    status: "past_due",
    tier: "studio",
    clientLimit: 500,
  });
});

Deno.test("mapSubscriptionToProConfig cancels or inactivates unsafe states", () => {
  assertEquals(mapSubscriptionToProConfig("canceled", "growth"), {
    status: "canceled",
    tier: "growth",
    clientLimit: 50,
  });
  assertEquals(mapSubscriptionToProConfig("incomplete", "growth"), {
    status: "inactive",
    tier: "growth",
    clientLimit: 50,
  });
});
