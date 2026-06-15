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

export type MealInterpretationDiagnostics = {
  edgeTotalMs: number;
  geminiFetchMs: number;
  responseParseMs: number;
  normalizeMs: number;
  promptChars: number;
  inputImageBytes?: number;
  personalExamplesCount: number;
  correctionExamplesCount: number;
  modelAttempts: number;
  fallbackUsed: boolean;
};

export async function buildMealInterpretationDraft(
  request: MealInterpretationRequest,
) {
  const totalTimer = performance.now();
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

  const primaryRequest = request.mode === "photo"
    ? buildFinalRetryRequest(request)
    : request;
  const systemPrompt = request.mode === "photo"
    ? buildFinalRetryPrompt(request.locale)
    : buildSystemPrompt(request.mode, request.locale);
  const userContentParts = buildUserContentParts(primaryRequest);
  const promptChars = systemPrompt.length +
    userContentParts.reduce((sum, part) => {
      const text = typeof part?.text === "string" ? part.text : "";
      return sum + text.length;
    }, 0);

  const primaryAttempt = await requestGeminiPayload({
    endpoint,
    apiKey,
    systemPrompt,
    userContentParts,
    generationConfig: buildGenerationConfig(request.mode),
  });

  let payload = primaryAttempt.payload;
  let geminiFetchMs = primaryAttempt.geminiFetchMs;
  let responseParseMs = primaryAttempt.responseParseMs;
  let modelAttempts = 1;
  let fallbackUsed = false;
  let parsed = tryExtractStructuredResponse(payload);
  if (request.mode === "photo" && parsed && !isUsablePhotoResponse(parsed)) {
    console.warn(
      JSON.stringify({
        tag: "meal-interpretation-semantic-fallback",
        mode: request.mode,
        attempt: "primary",
        reason: "incomplete-photo-nutrition",
        payloadSummary: summarizeGeminiPayload(payload),
      }),
    );
    parsed = null;
  }

  if (!parsed) {
    console.warn(
      JSON.stringify({
        tag: "meal-interpretation-parse-fallback",
        mode: request.mode,
        attempt: "primary",
        payloadSummary: summarizeGeminiPayload(payload),
      }),
    );

    const fallbackAttempt = await requestGeminiPayload({
      endpoint,
      apiKey,
      systemPrompt: request.mode === "photo"
        ? buildComplexPhotoFallbackPrompt(request.locale)
        : `${systemPrompt}\nReturn exactly one JSON object and nothing else.`,
      userContentParts,
      generationConfig: buildFallbackGenerationConfig(request.mode),
    });

    payload = fallbackAttempt.payload;
    geminiFetchMs += fallbackAttempt.geminiFetchMs;
    responseParseMs += fallbackAttempt.responseParseMs;
    modelAttempts += 1;
    fallbackUsed = true;
    parsed = tryExtractStructuredResponse(payload);
    if (request.mode === "photo" && parsed && !isUsablePhotoResponse(parsed)) {
      console.warn(
        JSON.stringify({
          tag: "meal-interpretation-semantic-fallback",
          mode: request.mode,
          attempt: "fallback",
          reason: "incomplete-photo-nutrition",
          payloadSummary: summarizeGeminiPayload(payload),
        }),
      );
      parsed = null;
    }

    if (!parsed) {
      const finalRetryRequest = buildFinalRetryRequest(request);
      const finalRetryPrompt = buildFinalRetryPrompt(request.locale);
      const finalRetryParts = buildUserContentParts(finalRetryRequest);
      const finalAttempt = await requestGeminiPayload({
        endpoint,
        apiKey,
        systemPrompt: finalRetryPrompt,
        userContentParts: finalRetryParts,
        generationConfig: buildFinalRetryGenerationConfig(request.mode),
      });

      payload = finalAttempt.payload;
      geminiFetchMs += finalAttempt.geminiFetchMs;
      responseParseMs += finalAttempt.responseParseMs;
      modelAttempts += 1;
      parsed = tryExtractStructuredResponse(payload);
      if (request.mode === "photo" && parsed && !isUsablePhotoResponse(parsed)) {
        throw new Error(
          `Structured response incomplete nutrition (${summarizeGeminiPayload(payload)})`,
        );
      }

      if (!parsed) {
        throw new Error(
          `Structured response missing candidate text (${summarizeGeminiPayload(payload)})`,
        );
      }
    }
  }

  const normalizeTimer = performance.now();
  const diagnostics = buildDiagnostics(request, {
    edgeTotalMs: 0,
    geminiFetchMs,
    responseParseMs,
    normalizeMs: 0,
    promptChars,
    modelAttempts,
    fallbackUsed,
  });
  const draft = normalizeDraftResponse(
    parsed,
    request,
    model,
    payload?.usageMetadata,
    diagnostics,
  );
  const normalizeMs = Math.round(performance.now() - normalizeTimer);
  draft.processing.diagnostics = buildDiagnostics(request, {
    edgeTotalMs: Math.round(performance.now() - totalTimer),
    geminiFetchMs,
    responseParseMs,
    normalizeMs,
    promptChars,
    modelAttempts,
    fallbackUsed,
  });
  return draft;
}

async function requestGeminiPayload(args: {
  endpoint: string;
  apiKey: string;
  systemPrompt: string;
  userContentParts: any[];
  generationConfig: Record<string, unknown>;
}) {
  const geminiTimer = performance.now();
  const response = await fetch(args.endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": args.apiKey,
    },
    body: JSON.stringify({
      systemInstruction: {
        parts: [{ text: args.systemPrompt }],
      },
      contents: [
        {
          role: "user",
          parts: args.userContentParts,
        },
      ],
      generationConfig: args.generationConfig,
    }),
  });
  const geminiFetchMs = Math.round(performance.now() - geminiTimer);

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini error ${response.status}: ${errorText}`);
  }

  const parseTimer = performance.now();
  const payload = await response.json();
  const responseParseMs = Math.round(performance.now() - parseTimer);

  return {
    payload,
    geminiFetchMs,
    responseParseMs,
  };
}

function buildGenerationConfig(mode: InterpretationMode) {
  if (mode === "photo") {
    return {
      temperature: 0.05,
      topP: 0.7,
      topK: 16,
      maxOutputTokens: 3072,
      responseMimeType: "application/json",
    };
  }

  return {
    temperature: 0.15,
    topP: 0.8,
    topK: 24,
    maxOutputTokens: 3072,
    responseMimeType: "application/json",
    responseJsonSchema: mealInterpretationSchema,
  };
}

function buildFallbackGenerationConfig(mode: InterpretationMode) {
  if (mode === "photo") {
    return {
      temperature: 0.1,
      topP: 0.8,
      topK: 24,
      maxOutputTokens: 3072,
      responseMimeType: "application/json",
    };
  }

  return {
    temperature: 0.15,
    topP: 0.85,
    topK: 32,
    maxOutputTokens: 3072,
    responseMimeType: "application/json",
  };
}

function buildFinalRetryGenerationConfig(mode: InterpretationMode) {
  if (mode === "photo") {
    return {
      temperature: 0.05,
      topP: 0.7,
      topK: 16,
      maxOutputTokens: 4096,
      responseMimeType: "application/json",
    };
  }

  return {
    temperature: 0.1,
    topP: 0.8,
    topK: 24,
    maxOutputTokens: 4096,
    responseMimeType: "application/json",
  };
}

function buildSystemPrompt(mode: InterpretationMode, locale?: string): string {
  const responseLanguage = inferResponseLanguage(locale);

  if (mode === "photo") {
    return [
      "You estimate macros for a meal tracking app.",
      "Return valid JSON matching the provided schema exactly.",
      `Respond with all text fields in ${responseLanguage}.`,
      "Keep JSON keys, unit values, and confidenceBand enum values exactly as specified; translate only user-visible values: title, summary, and item.label.",
      "Use units: g, ml, serving, oz, fl oz, g/ml.",
      "Identify only visible foods. Do not invent hidden ingredients.",
      "Estimate practical portions from plate size, visible density, oil sheen, sauces, cheese, and cooking method.",
      "Totals must equal the sum of all items.",
      "Keep kcal coherent with carbs*4 + protein*4 + fat*9 within 10 percent.",
      "Use high confidence for clear standard portions, medium for estimated portions, low for unclear or complex dishes.",
      "Prefer user-specific examples when they clearly match the detected meal.",
      "Output a concise title, one short summary sentence, and distinct ingredient items.",
    ].join("\n");
  }

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
    "6. Keep JSON keys, unit values, and confidenceBand enum values exactly as specified; translate only user-visible values.",
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

  if (mode !== "photo") {
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

function buildFinalRetryPrompt(locale?: string): string {
  const responseLanguage = inferResponseLanguage(locale);
  return [
    "Estimate visible meal nutrition for a calorie tracker, including complex plates.",
    "Return exactly one valid JSON object and nothing else.",
    `All text fields must be in ${responseLanguage}.`,
    "Keep JSON keys, unit values, and confidenceBand enum values exactly as specified; translate only user-visible values: title, summary, and item.label.",
    "Use 2-6 visible food components. Do not return placeholder item names.",
    "For complex plates, group foods into macro-relevant components instead of listing every tiny topping: protein, starch/grain, vegetables/salad, sauces/fats, extras.",
    "For mixed dishes, use a real label such as 'Mixed rice and chicken', 'Creamy pasta with toppings', or 'Mixed tapas plate'.",
    "Every item must include: id, label, amount, unit, kcal, carbs, fat, protein, confidenceBand, editable.",
    "Use practical units: g, ml, serving, oz, fl oz, or g/ml.",
    "Prefer g or ml for recognizable foods. Use serving only when weight is truly unclear.",
    "Every item must have amount > 0 and realistic kcal/macros. Do not use zero kcal unless the visible item is water or a zero-calorie drink.",
    "If exact ingredients are uncertain, estimate the main visible components with low confidence. Do not fail by returning zero nutrition.",
    "Totals must equal the sum of items.",
    "Keep title and summary short.",
    "JSON shape: {\"title\":\"...\",\"summary\":\"...\",\"confidenceBand\":\"low|medium|high\",\"totals\":{\"kcal\":0,\"carbs\":0,\"fat\":0,\"protein\":0},\"items\":[{\"id\":\"item_1\",\"label\":\"food name\",\"amount\":100,\"unit\":\"g\",\"kcal\":0,\"carbs\":0,\"fat\":0,\"protein\":0,\"confidenceBand\":\"low|medium|high\",\"editable\":true}]}",
  ].join("\n");
}

function buildComplexPhotoFallbackPrompt(locale?: string): string {
  const responseLanguage = inferResponseLanguage(locale);
  return [
    "You are estimating a complex meal photo for a calorie tracker.",
    "Return exactly one compact valid JSON object and nothing else.",
    `All text fields must be in ${responseLanguage}.`,
    "Keep JSON keys, unit values, and confidenceBand enum values exactly as specified; translate only user-visible values: title, summary, and item.label.",
    "Do not try to identify every small ingredient. Group the plate into 3-5 macro components.",
    "Use these component types when useful: main protein, carb base, vegetables/salad, sauce or cooking fat, calorie-dense extras.",
    "Each item label must be a real food/component name, never 'Detected item' or 'Meal item'.",
    "Each item must include a realistic amount, unit, kcal, carbs, fat, protein, confidenceBand, and editable=true.",
    "Use low confidence when uncertain, but still produce a realistic editable estimate.",
    "Use g for solid components and ml for sauces/drinks when possible.",
    "Totals must equal the sum of the items.",
    "If the whole plate is inseparable, return 2-3 broad real components plus one 'Mixed dish estimate' component with realistic macros.",
    "JSON shape: {\"title\":\"...\",\"summary\":\"...\",\"confidenceBand\":\"low|medium|high\",\"totals\":{\"kcal\":0,\"carbs\":0,\"fat\":0,\"protein\":0},\"items\":[{\"id\":\"item_1\",\"label\":\"main protein\",\"amount\":120,\"unit\":\"g\",\"kcal\":220,\"carbs\":0,\"fat\":8,\"protein\":32,\"confidenceBand\":\"low\",\"editable\":true}]}",
  ].join("\n");
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

function localizedFallbackTitle(request: MealInterpretationRequest): string {
  if (request.mode === "text") {
    return request.text || localizedPhotoMealTitle(request.locale);
  }
  return localizedPhotoMealTitle(request.locale);
}

function localizedPhotoMealTitle(locale?: string): string {
  return isSpanishLocale(locale) ? "Comida por foto" : "Photo meal";
}

function localizedEstimatedSummary(locale?: string): string {
  return isSpanishLocale(locale)
    ? "Estimacion de comida generada por IA."
    : "Estimated meal interpretation.";
}

function isSpanishLocale(locale?: string): boolean {
  return (locale || "").split(/[-_]/)[0]?.toLowerCase() === "es";
}

function buildUserContentParts(request: MealInterpretationRequest) {
  const metadataLines = [
    `Locale: ${request.locale || "unknown"}`,
    `Unit system: ${request.unitSystem || "metric"}`,
    `Meal type hint: ${request.mealTypeHint || "none"}`,
  ];

  const analysisContext = request.analysisContext?.trim();
  const normalizedAnalysisContext = request.mode === "photo"
    ? analysisContext?.slice(0, 900)
    : analysisContext;
  if (normalizedAnalysisContext) {
    metadataLines.push(`\nUser nutrition profile and personal data:\n${normalizedAnalysisContext}`);
  }

  const personalExamples = request.personalExamples
    ?.filter((example) =>
      typeof example?.title === "string" &&
      example.title.trim().length > 0 &&
      !isCorrectionExample(example)
    )
    .slice(0, request.mode === "photo" ? 2 : 6) ?? [];
  if (personalExamples.length > 0) {
    metadataLines.push("\nUser's saved/repeated meals (use as reference when they match):");
    for (const example of personalExamples) {
      metadataLines.push(formatPersonalExample(example));
    }
  }

  const correctionExamples = request.personalExamples
    ?.filter((example) => isCorrectionExample(example))
    .slice(0, request.mode === "photo" ? 2 : 4) ?? [];
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
        text:
          `${metadata}\n\nAnalyze this meal photo and estimate its nutritional content.`,
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

function buildFinalRetryRequest(
  request: MealInterpretationRequest,
): MealInterpretationRequest {
  return {
    ...request,
    analysisContext: null,
    personalExamples: null,
  };
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

function normalizePromptText(input: unknown): string {
  const safeInput = typeof input === "string" ? input : "";
  return safeInput
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

export function extractStructuredResponse(payload: any): MealInterpretationResponse {
  const parsed = tryExtractStructuredResponse(payload);
  if (parsed) {
    return parsed;
  }

  throw new Error("Structured response missing candidate text");
}

function tryExtractStructuredResponse(payload: any): MealInterpretationResponse | null {
  const candidates = Array.isArray(payload?.candidates) ? payload.candidates : [];
  for (const candidate of candidates) {
    const parts = Array.isArray(candidate?.content?.parts)
      ? candidate.content.parts
      : [];
    for (const part of parts) {
      if (typeof part?.text === "string") {
        const parsed = tryParseStructuredResponse(part.text);
        if (parsed) {
          return parsed;
        }
      }
    }
  }

  return null;
}

function tryParseStructuredResponse(text: string): MealInterpretationResponse | null {
  const trimmed = text.trim();
  if (!trimmed) {
    return null;
  }

  const variants = new Set<string>([
    trimmed,
    stripCodeFences(trimmed),
  ]);

  const extracted = extractLargestJsonObject(stripCodeFences(trimmed));
  if (extracted) {
    variants.add(extracted);
    variants.add(sanitizeAlmostJson(extracted));
  }

  variants.add(sanitizeAlmostJson(stripCodeFences(trimmed)));

  for (const candidate of variants) {
    const normalized = candidate.trim();
    if (!normalized.startsWith("{") || !normalized.endsWith("}")) {
      continue;
    }

    try {
      return JSON.parse(normalized);
    } catch {
      // Keep trying sanitized variants before failing hard.
    }
  }

  return null;
}

function stripCodeFences(text: string): string {
  return text
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
}

function extractLargestJsonObject(text: string): string | null {
  const start = text.indexOf("{");
  if (start === -1) {
    return null;
  }

  let depth = 0;
  let inString = false;
  let escaping = false;

  for (let index = start; index < text.length; index += 1) {
    const char = text[index];

    if (escaping) {
      escaping = false;
      continue;
    }

    if (char === "\\") {
      escaping = true;
      continue;
    }

    if (char === "\"") {
      inString = !inString;
      continue;
    }

    if (inString) {
      continue;
    }

    if (char === "{") {
      depth += 1;
    } else if (char === "}") {
      depth -= 1;
      if (depth === 0) {
        return text.slice(start, index + 1);
      }
    }
  }

  return null;
}

function sanitizeAlmostJson(text: string): string {
  return text
    .replace(/,\s*([}\]])/g, "$1")
    .replace(/^\uFEFF/, "")
    .trim();
}

function summarizeGeminiPayload(payload: any): string {
  const candidates = Array.isArray(payload?.candidates) ? payload.candidates : [];
  const finishReasons = candidates
    .map((candidate) => candidate?.finishReason)
    .filter((value) => typeof value === "string");
  const textParts = candidates.reduce((count, candidate) => {
    const parts = Array.isArray(candidate?.content?.parts)
      ? candidate.content.parts
      : [];
    return count + parts.filter((part: any) => typeof part?.text === "string").length;
  }, 0);
  const promptBlockReason = payload?.promptFeedback?.blockReason;
  const firstTextPreview = candidates
    .flatMap((candidate) => {
      const parts = Array.isArray(candidate?.content?.parts)
        ? candidate.content.parts
        : [];
      return parts
        .map((part: any) => typeof part?.text === "string" ? part.text : null)
        .filter(Boolean);
    })[0];
  return JSON.stringify({
    candidates: candidates.length,
    finishReasons,
    textParts,
    promptBlockReason: typeof promptBlockReason === "string"
      ? promptBlockReason
      : null,
    firstTextPreview: typeof firstTextPreview === "string"
      ? firstTextPreview.slice(0, 180)
      : null,
  });
}

export function isUsablePhotoResponse(data: MealInterpretationResponse): boolean {
  const items = Array.isArray(data?.items) ? data.items : [];
  if (items.length === 0) {
    return false;
  }

  const itemKcal = items.reduce(
    (total, item) => total + toPositiveNumber(item?.kcal, 0),
    0,
  );
  const totalKcal = toPositiveNumber(data?.totals?.kcal, 0);
  if (itemKcal <= 0 && totalKcal <= 0) {
    return false;
  }

  const hasAtLeastOneNutrientfulItem = items.some((item) =>
    toPositiveNumber(item?.kcal, 0) > 0 ||
    toPositiveNumber(item?.carbs, 0) > 0 ||
    toPositiveNumber(item?.fat, 0) > 0 ||
    toPositiveNumber(item?.protein, 0) > 0
  );
  if (!hasAtLeastOneNutrientfulItem) {
    return false;
  }

  return items.every((item) => {
    const label = typeof item?.label === "string" ? item.label.trim() : "";
    const unit = typeof item?.unit === "string" ? item.unit.trim() : "";
    const hasUsableLabel = label.length > 0 &&
      !/^detected item \d+$/i.test(label) &&
      !/^meal item \d+$/i.test(label);
    const hasAmount = toPositiveNumber(item?.amount, 0) > 0;
    const hasUnit = unit.length > 0;
    return hasUsableLabel && hasAmount && hasUnit;
  });
}

export function normalizeDraftResponse(
  data: MealInterpretationResponse,
  request: MealInterpretationRequest,
  model: string,
  usageMetadata?: any,
  diagnostics?: MealInterpretationDiagnostics,
) {
  const usage = normalizeUsageMetadata(usageMetadata);
  const estimatedCostUsd = estimateGeminiCostUsd(model, usage);

  // Deduplicate items based on semantic label similarity
  const responseItems = Array.isArray(data?.items) ? data.items : [];
  const deduplicatedItems = responseItems.reduce((acc, item, index) => {
    const safeLabel = typeof item?.label === "string" && item.label.trim().length > 0
      ? item.label.trim()
      : buildFallbackItemLabel(request.mode, index, request.locale);
    const normalizedItemLabel = normalizePromptText(safeLabel);
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
      if (safeLabel.length > existing.label.length) {
        existing.label = safeLabel;
      }
    } else {
      acc.push({
        ...item,
        label: safeLabel,
      });
    }
    return acc;
  }, [] as MealInterpretationItem[]);

  const items = deduplicatedItems.map((item, index) => ({
    id: item.id || `item_${index + 1}`,
    label: typeof item.label === "string" && item.label.trim().length > 0
      ? item.label.trim()
      : buildFallbackItemLabel(request.mode, index, request.locale),
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
        localizedFallbackTitle(request),
    summary: data.summary?.trim() || localizedEstimatedSummary(request.locale),
    confidenceBand: normalizeConfidence(data.confidenceBand),
    processing: {
      processedRemotely: true,
      stored: false,
      retentionSeconds: 0,
      provider: "gemini",
      model,
      usage,
      estimatedCostUsd,
      diagnostics,
    },
    totals,
    items,
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
  };
}

function buildDiagnostics(
  request: MealInterpretationRequest,
  base: {
    edgeTotalMs: number;
    geminiFetchMs: number;
    responseParseMs: number;
    normalizeMs: number;
    promptChars: number;
    modelAttempts: number;
    fallbackUsed: boolean;
  },
): MealInterpretationDiagnostics {
  const personalExamples = request.personalExamples
    ?.filter((example) =>
      typeof example?.title === "string" &&
      example.title.trim().length > 0 &&
      !isCorrectionExample(example)
    ).length ?? 0;
  const correctionExamples = request.personalExamples
    ?.filter((example) => isCorrectionExample(example)).length ?? 0;

  return {
    ...base,
    inputImageBytes: request.imageBase64
      ? Math.round((request.imageBase64.length * 3) / 4)
      : undefined,
    personalExamplesCount: personalExamples,
    correctionExamplesCount: correctionExamples,
    modelAttempts: base.modelAttempts,
    fallbackUsed: base.fallbackUsed,
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
  const normalizedModel = typeof model === "string"
    ? model.trim().toLowerCase()
    : "";

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

function normalizeUnit(unit: unknown): string {
  const normalized = typeof unit === "string"
    ? unit.trim().toLowerCase()
    : "";
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
  value: unknown,
): "low" | "medium" | "high" {
  const normalized = typeof value === "string" ? value.toLowerCase() : "";
  switch (normalized) {
    case "low":
      return "low";
    case "high":
      return "high";
    default:
      return "medium";
  }
}

function buildFallbackItemLabel(
  mode: InterpretationMode,
  index: number,
  locale?: string,
): string {
  if (isSpanishLocale(locale)) {
    return mode === "photo"
      ? `Ingrediente detectado ${index + 1}`
      : `Elemento de comida ${index + 1}`;
  }
  return mode === "photo"
    ? `Detected item ${index + 1}`
    : `Meal item ${index + 1}`;
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
