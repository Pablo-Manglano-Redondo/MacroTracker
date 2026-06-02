export type ProStatus =
  | "trialing"
  | "active"
  | "past_due"
  | "canceled"
  | "inactive";

export type ProTier = "starter" | "growth" | "studio";

export type ProTierConfig = {
  status: ProStatus;
  tier: ProTier;
  clientLimit: number;
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

export function mapSubscriptionToProConfig(
  subscriptionStatus: string,
  tierValue?: unknown,
): ProTierConfig {
  const tier = normalizeProTier(tierValue);
  const clientLimit = clientLimitForTier(tier);

  switch (subscriptionStatus) {
    case "trialing":
      return { status: "trialing", tier, clientLimit };
    case "active":
      return { status: "active", tier, clientLimit };
    case "past_due":
    case "unpaid":
      return { status: "past_due", tier, clientLimit };
    case "canceled":
    case "incomplete_expired":
      return { status: "canceled", tier, clientLimit };
    default:
      return { status: "inactive", tier, clientLimit };
  }
}
