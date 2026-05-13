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
  fiber?: number;
  sugar?: number;
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
    fiber?: number;
    sugar?: number;
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
      systemInstruction: {
        parts: [{ text: buildSystemPrompt(request.mode, request.locale) }],
      },
      contents: [
        {
          role: "user",
          parts: buildUserContentParts(request),
        },
      ],
      generationConfig: {
        temperature: 0.15,
        topP: 0.8,
        topK: 40,
        maxOutputTokens: 8192,
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

function buildSystemPrompt(mode: InterpretationMode, locale?: string): string {
  const responseLanguage = inferResponseLanguage(locale);

  const base = [
    "You are an expert nutrition estimation engine for a macro tracking app.",
    "Return valid JSON following the provided schema exactly.",
    "Your goal is to produce the most accurate practical estimate so the user needs minimal corrections.",
    "",
    "## Core Rules",
    "1. Use units: g, ml, serving, oz, fl oz, g/ml. Prefer g or ml when the food has a clear weight/volume. Use 'serving' only when portion is truly ambiguous.",
    "2. Estimate kcal, carbs, fat, protein per item. Totals MUST equal the sum of all items.",
    "3. Ensure macro-calorie coherence: kcal \u2248 (carbs \u00d7 4) + (protein \u00d7 4) + (fat \u00d7 9). Tolerance: \u00b110%.",
    "4. Do NOT invent brands unless the user names one explicitly.",
    `5. Respond with all text fields (title, summary, labels) in ${responseLanguage}.`,
    "",
    "## Portion Estimation Guidelines",
    "Before estimating, mentally reason about the likely portion size:",
    "- A standard home-cooked chicken breast: 120-180g cooked",
    "- A restaurant chicken breast: 180-250g cooked",
    "- A cup of cooked white rice: ~185g (\u2248240 kcal)",
    "- A standard plate of pasta (cooked): 180-250g",
    "- One large egg: ~60g (\u224878 kcal, 6g protein, 5g fat, 0.6g carbs)",
    "- A tablespoon of olive oil: ~13ml (\u2248120 kcal, 14g fat)",
    "- A slice of white bread: ~30g (\u224880 kcal)",
    "- A medium banana: ~120g edible (\u2248105 kcal)",
    "- A standard protein shake scoop: ~30g powder",
    "",
    "## Conservative Estimation for Hidden Calories",
    "- Cooking oil (unless specified): assume 5-10ml per cooked item (45-90 kcal)",
    "- Salad dressings: assume 15-20ml per serving unless visible/stated",
    "- Cheese toppings: assume 15-25g unless clearly visible as more",
    "- Sauces (mayo, ketchup, etc.): assume 15g per serving",
    "- Nut butters: assume 15-20g (1 tablespoon) unless stated otherwise",
    "- Butter on toast: assume 7-10g per slice",
    "If the user's personal context shows they typically use different amounts, prefer their pattern.",
    "",
    "## Confidence Bands",
    "- 'high': standard foods with clear portions (e.g., '2 eggs', '100g chicken breast', packaged foods)",
    "- 'medium': recognizable foods with estimated portions (e.g., 'a plate of rice', 'some chicken')",
    "- 'low': complex/mixed dishes, restaurant food, or heavily processed meals where ingredients are uncertain",
    "",
    "## Personal Context Usage",
    "When personal meal examples or correction history are provided:",
    "- If a food matches a user's saved meal (>70% name similarity), USE their portions and macros as the baseline",
    "- If the user has corrected a food before, apply their preferred portion size",
    "- Personal examples take priority over generic database estimates",
    "",
  ];

  if (mode === "photo") {
    base.push(
      "## Photo-Specific Rules",
      "- Identify ONLY visible ingredients. Do not guess hidden ingredients.",
      "- Estimate plate/bowl size to calibrate portion sizes (standard dinner plate \u2248 26cm)",
      "- If multiple items share a plate, estimate each separately",
      "- Account for visible oil sheen, sauce coverage, cheese melting as hidden calorie sources",
      "- If the photo is unclear or partially obscured, set confidenceBand to 'low'",
    );
  } else {
    base.push(
      "## Text-Specific Rules",
      "- Parse exactly what the user described \u2014 do not add ingredients they didn't mention",
      "- For ambiguous quantities ('some rice', 'a bit of cheese'), use moderate defaults",
      "- If the user says 'homemade', assume standard home portions (not restaurant-sized)",
      "- If the user specifies a brand, use that brand's actual nutritional values if known",
    );
  }

  base.push(
    "",
    "## Output",
    "- 'title': concise name for the meal (2-6 words)",
    "- 'summary': one natural sentence describing what was detected and the estimation approach",
    "- Each item should be a distinct ingredient or food component",
    "- Avoid duplicating the same ingredient as separate items",
  );

  return base.join("\n");
}

function inferResponseLanguage(locale?: string): string {
  const lang = (locale || "").split(/[-_]/)[0]?.toLowerCase();
  switch (lang) {
    case "es":
      return "Spanish (espa\u00f1ol)";
    case "fr":
      return "French (fran\u00e7ais)";
    case "de":
      return "German (Deutsch)";
    case "it":
      return "Italian (italiano)";
    case "pt":
      return "Portuguese (portugu\u00eas)";
    case "ja":
      return "Japanese (\u65e5\u672c\u8a9e)";
    case "ko":
      return "Korean (\ud55c\uad6d\uc5b4)";
    case "zh":
      return "Chinese (\u4e2d\u6587)";
    default:
      return "English";
  }
}

function buildUserContentParts(request: MealInterpretationRequest) {
  const metadataLines = [
    `Locale: ${request.locale || "unknown"}`,
    `Unit system: ${request.unitSystem || "metric"}`,
    `Meal type hint: ${request.mealTypeHint || "none"}`,
  ];

  const analysisContext = request.analysisContext?.trim();
  if (analysisContext) {
    metadataLines.push(`\nUser nutrition profile and personal data:\n${analysisContext}`);
  }

  const personalExamples = request.personalExamples
    ?.filter((example) =>
      typeof example?.title === "string" &&
      example.title.trim().length > 0 &&
      !isCorrectionExample(example)
    )
    .slice(0, 6) ?? [];
  if (personalExamples.length > 0) {
    metadataLines.push("\nUser's saved/repeated meals (use as reference when they match):");
    for (const example of personalExamples) {
      metadataLines.push(formatPersonalExample(example));
    }
  }

  const correctionExamples = request.personalExamples
    ?.filter((example) => isCorrectionExample(example))
    .slice(0, 4) ?? [];
  if (correctionExamples.length > 0) {
    metadataLines.push("\nPrevious corrections by this user (apply these preferred portions):");
    for (const example of correctionExamples) {
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
        text: `${metadata}\n\nAnalyze this meal photo and estimate its nutritional content.`,
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
      text: `${metadata}\n\nMeal description: ${request.text}`,
    },
  ];
}

function isCorrectionExample(
  example: NonNullable<MealInterpretationRequest["personalExamples"]>[number],
): boolean {
  if (typeof example?.sourceLabel !== "string") {
    return false;
  }

  const normalizedSource = normalizePromptText(example.sourceLabel);
  return normalizedSource.includes("correction") ||
    normalizedSource.includes("correccion");
}

function normalizePromptText(input: string): string {
  return input
    .toLowerCase()
    .replaceAll("\u00e1", "a")
    .replaceAll("\u00e9", "e")
    .replaceAll("\u00ed", "i")
    .replaceAll("\u00f3", "o")
    .replaceAll("\u00fa", "u")
    .replaceAll("\u00f1", "n")
    .replaceAll("Ã¡", "a")
    .replaceAll("Ã©", "e")
    .replaceAll("Ã­", "i")
    .replaceAll("Ã³", "o")
    .replaceAll("Ãº", "u")
    .replaceAll("Ã±", "n")
    .replaceAll("ÃƒÂ¡", "a")
    .replaceAll("ÃƒÂ©", "e")
    .replaceAll("ÃƒÂ­", "i")
    .replaceAll("ÃƒÂ³", "o")
    .replaceAll("ÃƒÂº", "u")
    .replaceAll("ÃƒÂ±", "n");
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
  const estimatedCostUsd = estimateGeminiCostUsd(model, usage);

  // Deduplicate items based on semantic label similarity
  const deduplicatedItems = data.items.reduce((acc, item) => {
    const normalizedItemLabel = normalizePromptText(item.label);
    const existingIndex = acc.findIndex((e) =>
      normalizePromptText(e.label) === normalizedItemLabel ||
      normalizePromptText(e.label).includes(normalizedItemLabel) ||
      normalizedItemLabel.includes(normalizePromptText(e.label))
    );

    if (existingIndex >= 0) {
      const existing = acc[existingIndex];
      existing.amount += toPositiveNumber(item.amount, 0);
      existing.kcal += toPositiveNumber(item.kcal, 0);
      existing.carbs += toPositiveNumber(item.carbs, 0);
      existing.fat += toPositiveNumber(item.fat, 0);
      existing.protein += toPositiveNumber(item.protein, 0);
      if (item.fiber != null) {
        existing.fiber = (existing.fiber || 0) + toPositiveNumber(item.fiber, 0);
      }
      if (item.sugar != null) {
        existing.sugar = (existing.sugar || 0) + toPositiveNumber(item.sugar, 0);
      }
      // If the label is more descriptive, keep the longer one
      if (item.label.length > existing.label.length) {
        existing.label = item.label;
      }
    } else {
      acc.push({ ...item });
    }
    return acc;
  }, [] as MealInterpretationItem[]);

  const items = deduplicatedItems.map((item, index) => ({
    id: item.id || `item_${index + 1}`,
    label: item.label,
    amount: toPositiveNumber(item.amount, 1),
    unit: normalizeUnit(item.unit),
    kcal: toPositiveNumber(item.kcal, 0),
    carbs: toPositiveNumber(item.carbs, 0),
    fat: toPositiveNumber(item.fat, 0),
    protein: toPositiveNumber(item.protein, 0),
    fiber: item.fiber != null ? toPositiveNumber(item.fiber, 0) : null,
    sugar: item.sugar != null ? toPositiveNumber(item.sugar, 0) : null,
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
    fiber: data.totals?.fiber != null ? round1(data.totals.fiber) :
           (items.some(i => i.fiber != null) ? round1(sum(items.map((item) => item.fiber || 0))) : null),
    sugar: data.totals?.sugar != null ? round1(data.totals.sugar) :
           (items.some(i => i.sugar != null) ? round1(sum(items.map((item) => item.sugar || 0))) : null),
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
  model: string,
  usage: { promptTokenCount: number; candidatesTokenCount: number },
): number {
  const pricing = resolveGeminiPricing(model);

  const inputCost = (usage.promptTokenCount / 1_000_000) * pricing.inputPer1M;
  const outputCost = (usage.candidatesTokenCount / 1_000_000) *
    pricing.outputPer1M;
  return round6(inputCost + outputCost);
}

function resolveGeminiPricing(model: string): {
  inputPer1M: number;
  outputPer1M: number;
} {
  const normalizedModel = model.trim().toLowerCase();

  if (normalizedModel.startsWith("gemini-2.5-flash-lite")) {
    return {
      inputPer1M: readNonNegativeEnvNumber(
        "GEMINI_25_FLASH_LITE_INPUT_TOKEN_USD_PER_1M",
        0.10,
      ),
      outputPer1M: readNonNegativeEnvNumber(
        "GEMINI_25_FLASH_LITE_OUTPUT_TOKEN_USD_PER_1M",
        0.40,
      ),
    };
  }

  if (
    normalizedModel.startsWith("gemini-2.5-flash") &&
    !normalizedModel.startsWith("gemini-2.5-flash-image") &&
    !normalizedModel.includes("tts") &&
    !normalizedModel.includes("native-audio")
  ) {
    return {
      inputPer1M: readNonNegativeEnvNumber(
        "GEMINI_25_FLASH_INPUT_TOKEN_USD_PER_1M",
        0.30,
      ),
      outputPer1M: readNonNegativeEnvNumber(
        "GEMINI_25_FLASH_OUTPUT_TOKEN_USD_PER_1M",
        2.50,
      ),
    };
  }

  return {
    inputPer1M: readNonNegativeEnvNumber(
      "GEMINI_INPUT_TOKEN_USD_PER_1M",
      0.10,
    ),
    outputPer1M: readNonNegativeEnvNumber(
      "GEMINI_OUTPUT_TOKEN_USD_PER_1M",
      0.40,
    ),
  };
}

function readNonNegativeEnvNumber(key: string, fallback: number): number {
  let raw: string | undefined;
  try {
    raw = Deno.env.get(key);
  } catch {
    return fallback;
  }
  const parsed = raw == null ? fallback : Number(raw);
  if (!Number.isFinite(parsed) || parsed < 0) {
    return fallback;
  }
  return parsed;
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
