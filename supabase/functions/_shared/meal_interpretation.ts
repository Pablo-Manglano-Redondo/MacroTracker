import { mealInterpretationSchema } from "./meal_interpretation_schema.ts";

export type InterpretationMode = "text" | "photo";

export type MealInterpretationRequest = {
  mode: InterpretationMode;
  text?: string;
  imageBase64?: string;
  mimeType?: string;
  locale: string;
  unitSystem: string;
  mealTypeHint?: string | null;
  analysisContext?: string | null;
  personalExamples?: Array<{
    title: string;
    sourceLabel?: string;
    defaultAmount?: number;
    defaultUnit?: string;
    kcal?: number;
    carbs?: number;
    fat?: number;
    protein?: number;
  }> | null;
};

export type MealInterpretationItem = {
  id: string;
  label: string;
  amount: number;
  unit: string;
  kcal: number;
  carbs: number;
  fat: number;
  protein: number;
  confidenceBand: "low" | "medium" | "high";
  editable: boolean;
};

export type MealInterpretationResponse = {
  title: string;
  summary: string;
  confidenceBand: "low" | "medium" | "high";
  totals: {
    kcal: number;
    carbs: number;
    fat: number;
    protein: number;
  };
  items: MealInterpretationItem[];
};

export async function buildMealInterpretationDraft(
  request: MealInterpretationRequest,
) {
  const model = Deno.env.get(
    request.mode === "photo"
      ? "GEMINI_MEAL_PHOTO_MODEL"
      : "GEMINI_MEAL_TEXT_MODEL",
  ) ?? (request.mode === "photo"
    ? "gemini-2.5-flash"
    : "gemini-2.5-flash-lite");
  const apiKey = Deno.env.get("GEMINI_API_KEY");

  if (!apiKey) {
    throw new Error("Missing GEMINI_API_KEY");
  }

  const endpoint =
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    },
    body: JSON.stringify({
      contents: [
        {
          role: "user",
          parts: buildUserParts(request),
        },
      ],
      generationConfig: {
        temperature: 0.2,
        topK: 20,
        maxOutputTokens: 1200,
        responseMimeType: "application/json",
        responseJsonSchema: mealInterpretationSchema,
      },
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini error ${response.status}: ${errorText}`);
  }

  const payload = await response.json();
  const parsed = extractStructuredResponse(payload);
  return normalizeDraftResponse(parsed, request, model, payload?.usageMetadata);
}

function buildSystemPrompt(mode: InterpretationMode): string {
  return [
    "You are a nutrition estimation engine for a privacy-first macro tracking app.",
    "Return valid JSON only and follow the provided schema exactly.",
    "Your job is to estimate a practical meal breakdown that the user can edit before saving.",
    "Use only these units: g, ml, serving, oz, fl oz, g/ml.",
    "Prefer g or ml when reasonably inferable. If portion is ambiguous, use serving.",
    "Estimate calories, carbs, fat and protein for each item and for the total meal.",
    "Use confidenceBand conservatively. If unsure about portion size or hidden ingredients, choose low or medium.",
    "Do not invent brands unless the user explicitly names one.",
    "If personal context or repeated meal examples are provided, prefer them when they plausibly match the observed meal.",
    "Treat oils, dressings, sauces, cheese, nut butters and toppings conservatively unless they are clearly visible or explicitly mentioned.",
    "When a dish appears to match a saved user meal, align portions and macros to that example instead of returning a generic alternative.",
    mode === "photo"
      ? "For photos, describe the dish and visible ingredients only. Do not claim certainty about hidden ingredients."
      : "For text input, parse the foods the user actually described and choose reasonable defaults for ambiguous portions.",
    "summary should be a short natural sentence describing the interpretation.",
  ].join(" ");
}

function buildUserParts(request: MealInterpretationRequest) {
  const metadataLines = [
    buildSystemPrompt(request.mode),
    `Locale: ${request.locale || "unknown"}`,
    `Unit system: ${request.unitSystem || "metric"}`,
    `Meal type hint: ${request.mealTypeHint || "none"}`,
    "Output JSON only.",
  ];

  const analysisContext = request.analysisContext?.trim();
  if (analysisContext) {
    metadataLines.push(`User context:\n${analysisContext}`);
  }

  const personalExamples = request.personalExamples
    ?.filter((example) => typeof example?.title === "string" && example.title.trim().length > 0)
    .slice(0, 4) ?? [];
  if (personalExamples.length > 0) {
    metadataLines.push("Repeated personal meal examples:");
    for (const example of personalExamples) {
      metadataLines.push(formatPersonalExample(example));
    }
  }

  const metadata = metadataLines.join("\n");

  if (request.mode === "photo") {
    if (!request.imageBase64) {
      throw new Error("Missing imageBase64");
    }

    return [
      {
        text: `${metadata}\nEstimate the meal from this photo.`,
      },
      {
        inlineData: {
          mimeType: normalizeMimeType(request.mimeType),
          data: request.imageBase64,
        },
      },
    ];
  }

  if (!request.text) {
    throw new Error("Missing text");
  }

  return [
    {
      text: `${metadata}\nUser meal description: ${request.text}`,
    },
  ];
}

function formatPersonalExample(
  example: NonNullable<MealInterpretationRequest["personalExamples"]>[number],
): string {
  const amount = typeof example.defaultAmount === "number" && Number.isFinite(example.defaultAmount)
    ? example.defaultAmount.toFixed(example.defaultAmount % 1 === 0 ? 0 : 1)
    : null;
  const unit = typeof example.defaultUnit === "string" && example.defaultUnit.trim().length > 0
    ? example.defaultUnit.trim()
    : null;
  const macros = [
    typeof example.kcal === "number" && Number.isFinite(example.kcal)
      ? `${Math.round(example.kcal)} kcal`
      : null,
    typeof example.protein === "number" && Number.isFinite(example.protein)
      ? `${Math.round(example.protein)}p`
      : null,
    typeof example.carbs === "number" && Number.isFinite(example.carbs)
      ? `${Math.round(example.carbs)}c`
      : null,
    typeof example.fat === "number" && Number.isFinite(example.fat)
      ? `${Math.round(example.fat)}f`
      : null,
  ].filter(Boolean).join(", ");

  const details = [
    amount != null && unit != null ? `${amount} ${unit}` : null,
    macros || null,
    example.sourceLabel?.trim() ? `source: ${example.sourceLabel.trim()}` : null,
  ].filter(Boolean).join(" | ");

  return details.length === 0
    ? `- ${example.title.trim()}`
    : `- ${example.title.trim()} -> ${details}`;
}

function normalizeMimeType(mimeType: string | undefined): string {
  const normalized = (mimeType || "").trim().toLowerCase();
  switch (normalized) {
    case "image/png":
    case "image/webp":
    case "image/gif":
    case "image/heic":
    case "image/heif":
    case "image/jpeg":
      return normalized;
    default:
      return "image/jpeg";
  }
}

function extractStructuredResponse(payload: any): MealInterpretationResponse {
  const candidates = Array.isArray(payload?.candidates) ? payload.candidates : [];
  for (const candidate of candidates) {
    const parts = Array.isArray(candidate?.content?.parts)
      ? candidate.content.parts
      : [];
    for (const part of parts) {
      if (typeof part?.text === "string" && part.text.trim().startsWith("{")) {
        return JSON.parse(part.text);
      }
    }
  }

  throw new Error("Structured response missing candidate text");
}

export function normalizeDraftResponse(
  data: MealInterpretationResponse,
  request: MealInterpretationRequest,
  model: string,
  usageMetadata?: any,
) {
  const usage = normalizeUsageMetadata(usageMetadata);
  const estimatedCostUsd = estimateGeminiCostUsd(usage);

  const items = data.items.map((item, index) => ({
    id: item.id || `item_${index + 1}`,
    label: item.label,
    amount: toPositiveNumber(item.amount, 1),
    unit: normalizeUnit(item.unit),
    kcal: toPositiveNumber(item.kcal, 0),
    carbs: toPositiveNumber(item.carbs, 0),
    fat: toPositiveNumber(item.fat, 0),
    protein: toPositiveNumber(item.protein, 0),
    confidenceBand: normalizeConfidence(item.confidenceBand),
    editable: item.editable ?? true,
  }));

  const totals = {
    kcal: round1(data.totals?.kcal ?? sum(items.map((item) => item.kcal))),
    carbs: round1(data.totals?.carbs ?? sum(items.map((item) => item.carbs))),
    fat: round1(data.totals?.fat ?? sum(items.map((item) => item.fat))),
    protein: round1(
      data.totals?.protein ?? sum(items.map((item) => item.protein)),
    ),
  };

  return {
    draftId: crypto.randomUUID(),
    sourceType: request.mode,
    inputText: request.mode === "text" ? request.text ?? null : null,
    title: data.title?.trim() ||
        (request.mode === "text" ? request.text : "Photo meal"),
    summary: data.summary?.trim() || "Estimated meal interpretation.",
    confidenceBand: normalizeConfidence(data.confidenceBand),
    processing: {
      processedRemotely: true,
      stored: false,
      retentionSeconds: 0,
      provider: "gemini",
      model,
      usage,
      estimatedCostUsd,
    },
    totals,
    items,
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
  };
}

function normalizeUsageMetadata(usageMetadata: any) {
  const promptTokens = toNonNegativeInt(usageMetadata?.promptTokenCount);
  const outputTokens = toNonNegativeInt(usageMetadata?.candidatesTokenCount);
  const totalTokens = toNonNegativeInt(
    usageMetadata?.totalTokenCount,
    promptTokens + outputTokens,
  );
  return {
    promptTokenCount: promptTokens,
    candidatesTokenCount: outputTokens,
    totalTokenCount: totalTokens,
  };
}

function toNonNegativeInt(value: unknown, fallback = 0): number {
  const numberValue = typeof value === "number"
    ? value
    : typeof value === "string"
    ? Number(value)
    : NaN;
  if (!Number.isFinite(numberValue) || numberValue < 0) {
    return fallback;
  }
  return Math.round(numberValue);
}

function estimateGeminiCostUsd(
  usage: { promptTokenCount: number; candidatesTokenCount: number },
): number {
  const inputPer1M = Number(
    Deno.env.get("GEMINI_INPUT_TOKEN_USD_PER_1M") ?? "0.075",
  );
  const outputPer1M = Number(
    Deno.env.get("GEMINI_OUTPUT_TOKEN_USD_PER_1M") ?? "0.30",
  );
  const safeInputPer1M = Number.isFinite(inputPer1M) && inputPer1M >= 0
    ? inputPer1M
    : 0;
  const safeOutputPer1M = Number.isFinite(outputPer1M) && outputPer1M >= 0
    ? outputPer1M
    : 0;

  const inputCost = (usage.promptTokenCount / 1_000_000) * safeInputPer1M;
  const outputCost = (usage.candidatesTokenCount / 1_000_000) * safeOutputPer1M;
  return round6(inputCost + outputCost);
}

function round6(value: number): number {
  return Math.round(value * 1_000_000) / 1_000_000;
}

function normalizeUnit(unit: string | undefined): string {
  const normalized = (unit || "").trim().toLowerCase();
  switch (normalized) {
    case "g":
    case "gram":
    case "grams":
      return "g";
    case "ml":
      return "ml";
    case "g/ml":
      return "g/ml";
    case "oz":
      return "oz";
    case "fl.oz":
    case "fl oz":
      return "fl oz";
    case "serving":
    default:
      return "serving";
  }
}

function normalizeConfidence(
  value: string | undefined,
): "low" | "medium" | "high" {
  switch ((value || "").toLowerCase()) {
    case "low":
      return "low";
    case "high":
      return "high";
    default:
      return "medium";
  }
}

function toPositiveNumber(value: unknown, fallback: number): number {
  const parsed = typeof value === "number"
    ? value
    : typeof value === "string"
    ? Number(value)
    : NaN;

  if (!Number.isFinite(parsed) || parsed < 0) {
    return fallback;
  }

  return round1(parsed);
}

function round1(value: number): number {
  return Math.round(value * 10) / 10;
}

function sum(values: number[]): number {
  return values.reduce((total, value) => total + value, 0);
}
