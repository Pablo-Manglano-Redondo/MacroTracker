export type ProStatus =
  | "trialing"
  | "active"
  | "past_due"
  | "canceled"
  | "inactive";

export type ProTier = "starter" | "growth" | "studio";
export type ProBillingInterval = "monthly" | "annual";

export type ProTierConfig = {
  status: ProStatus;
  tier: ProTier;
  clientLimit: number;
  billingInterval: ProBillingInterval;
};

export function normalizeProTier(value: unknown): ProTier {
  const tier = String(value ?? "starter").toLowerCase();
  if (tier === "growth" || tier === "studio") {
    return tier;
  }
  return "starter";
}

export function clientLimitForTier(tier: ProTier): number {
  switch (tier) {
    case "studio":
      return 500;
    case "growth":
      return 50;
    case "starter":
      return 10;
  }
}

export function normalizeBillingInterval(
  value: unknown,
): ProBillingInterval {
  const interval = String(value ?? "monthly").toLowerCase();
  if (interval === "annual" || interval === "year") {
    return "annual";
  }
  return "monthly";
}

export function mapSubscriptionToProConfig(
  subscriptionStatus: string,
  tierValue?: unknown,
  billingIntervalValue?: unknown,
): ProTierConfig {
  const tier = normalizeProTier(tierValue);
  const clientLimit = clientLimitForTier(tier);
  const billingInterval = normalizeBillingInterval(billingIntervalValue);

  switch (subscriptionStatus) {
    case "trialing":
      return { status: "trialing", tier, clientLimit, billingInterval };
    case "active":
      return { status: "active", tier, clientLimit, billingInterval };
    case "past_due":
    case "unpaid":
      return { status: "past_due", tier, clientLimit, billingInterval };
    case "canceled":
    case "incomplete_expired":
      return { status: "canceled", tier, clientLimit, billingInterval };
    default:
      return { status: "inactive", tier, clientLimit, billingInterval };
  }
}
