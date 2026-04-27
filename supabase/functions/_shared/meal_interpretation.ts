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
  ) ?? "gemini-2.5-flash-lite";
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
  return normalizeDraftResponse(parsed, request, model);
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
    mode === "photo"
      ? "For photos, describe the dish and visible ingredients only. Do not claim certainty about hidden ingredients."
      : "For text input, parse the foods the user actually described and choose reasonable defaults for ambiguous portions.",
    "summary should be a short natural sentence describing the interpretation.",
  ].join(" ");
}

function buildUserParts(request: MealInterpretationRequest) {
  const metadata = [
    buildSystemPrompt(request.mode),
    `Locale: ${request.locale || "unknown"}`,
    `Unit system: ${request.unitSystem || "metric"}`,
    `Meal type hint: ${request.mealTypeHint || "none"}`,
    "Output JSON only.",
  ].join("\n");

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

function normalizeMimeType(mimeType: string | undefined): string {
  const normalized = (mimeType || "").trim().toLowerCase();
  switch (normalized) {
    case "image/png":
    case "image/webp":
    case "image/gif":
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
) {
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
    },
    totals,
    items,
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
  };
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
