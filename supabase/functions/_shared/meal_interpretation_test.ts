import {
  extractStructuredResponse,
  isUsablePhotoResponse,
  normalizeDraftResponse,
  type MealInterpretationRequest,
  type MealInterpretationResponse,
} from "./meal_interpretation.ts";

Deno.test("normalizeDraftResponse returns the app contract for text requests", () => {
  const request: MealInterpretationRequest = {
    mode: "text",
    text: "2 eggs and toast",
    locale: "en-US",
    unitSystem: "metric",
    mealTypeHint: "breakfast",
  };
  const response: MealInterpretationResponse = {
    title: "Eggs and toast",
    summary: "A breakfast meal.",
    confidenceBand: "high",
    totals: {
      kcal: 321.23,
      carbs: 24.04,
      fat: 17.05,
      protein: 18.06,
    },
    items: [
      {
        id: "eggs",
        label: "Eggs",
        amount: 100,
        unit: "grams",
        kcal: 155.04,
        carbs: 1.12,
        fat: 10.64,
        protein: 12.58,
        confidenceBand: "high",
        editable: true,
      },
    ],
  };

  const draft = normalizeDraftResponse(response, request, "test-model");

  if (draft.sourceType !== "text") {
    throw new Error(`Unexpected sourceType: ${draft.sourceType}`);
  }
  if (draft.inputText !== request.text) {
    throw new Error("Text input was not retained");
  }
  if (draft.processing.stored !== false) {
    throw new Error("Draft processing must be non-persistent");
  }
  if (draft.processing.model !== "test-model") {
    throw new Error("Model metadata was not retained");
  }
  if (draft.totals.kcal !== 321.2) {
    throw new Error(`Unexpected kcal rounding: ${draft.totals.kcal}`);
  }
  if (draft.items[0].unit !== "g") {
    throw new Error(`Unexpected normalized unit: ${draft.items[0].unit}`);
  }
});

Deno.test("normalizeDraftResponse clamps invalid item numbers and defaults photo metadata", () => {
  const request: MealInterpretationRequest = {
    mode: "photo",
    imageBase64: "base64",
    locale: "en-US",
    unitSystem: "metric",
  };
  const response: MealInterpretationResponse = {
    title: "",
    summary: "",
    confidenceBand: "medium",
    totals: {
      kcal: 0,
      carbs: 0,
      fat: 0,
      protein: 0,
    },
    items: [
      {
        id: "",
        label: "Unknown item",
        amount: -1,
        unit: "unknown",
        kcal: -1,
        carbs: Number.NaN,
        fat: 3.26,
        protein: 4.24,
        confidenceBand: "medium",
        editable: true,
      },
    ],
  };

  const draft = normalizeDraftResponse(response, request, "test-model");

  if (draft.sourceType !== "photo") {
    throw new Error(`Unexpected sourceType: ${draft.sourceType}`);
  }
  if (draft.inputText !== null) {
    throw new Error("Photo requests must not retain text input");
  }
  if (draft.title !== "Photo meal") {
    throw new Error(`Unexpected fallback title: ${draft.title}`);
  }
  if (draft.items[0].id !== "item_1") {
    throw new Error(`Unexpected fallback item id: ${draft.items[0].id}`);
  }
  if (draft.items[0].amount !== 1) {
    throw new Error(`Unexpected fallback amount: ${draft.items[0].amount}`);
  }
  if (draft.items[0].unit !== "serving") {
    throw new Error(`Unexpected fallback unit: ${draft.items[0].unit}`);
  }
  if (draft.items[0].kcal !== 0 || draft.items[0].carbs !== 0) {
    throw new Error("Invalid nutrient values were not clamped");
  }
});

Deno.test("normalizeDraftResponse tolerates incomplete photo items", () => {
  const request: MealInterpretationRequest = {
    mode: "photo",
    imageBase64: "base64",
    locale: "en-US",
    unitSystem: "metric",
  };
  const response = {
    title: "Photo meal",
    summary: "Estimated from photo.",
    totals: {
      kcal: 120,
      carbs: 10,
      fat: 4,
      protein: 8,
    },
    items: [
      {
        kcal: 120,
        carbs: 10,
        fat: 4,
        protein: 8,
      },
    ],
  } as unknown as MealInterpretationResponse;

  const draft = normalizeDraftResponse(response, request, "test-model");

  if (draft.items[0].label !== "Detected item 1") {
    throw new Error(`Unexpected fallback label: ${draft.items[0].label}`);
  }
  if (draft.items[0].unit !== "serving") {
    throw new Error(`Unexpected fallback unit: ${draft.items[0].unit}`);
  }
  if (draft.items[0].confidenceBand !== "medium") {
    throw new Error(
      `Unexpected fallback confidence: ${draft.items[0].confidenceBand}`,
    );
  }
});

Deno.test("normalizeDraftResponse localizes Spanish photo fallbacks", () => {
  const request: MealInterpretationRequest = {
    mode: "photo",
    imageBase64: "base64",
    locale: "es-ES",
    unitSystem: "metric",
  };
  const response = {
    title: "",
    summary: "",
    totals: {
      kcal: 120,
      carbs: 10,
      fat: 4,
      protein: 8,
    },
    items: [
      {
        kcal: 120,
        carbs: 10,
        fat: 4,
        protein: 8,
      },
    ],
  } as unknown as MealInterpretationResponse;

  const draft = normalizeDraftResponse(response, request, "test-model");

  if (draft.title !== "Comida por foto") {
    throw new Error(`Unexpected Spanish fallback title: ${draft.title}`);
  }
  if (draft.summary !== "Estimacion de comida generada por IA.") {
    throw new Error(`Unexpected Spanish fallback summary: ${draft.summary}`);
  }
  if (draft.items[0].label !== "Ingrediente detectado 1") {
    throw new Error(
      `Unexpected Spanish fallback label: ${draft.items[0].label}`,
    );
  }
});

Deno.test("isUsablePhotoResponse rejects placeholder zero-nutrition photo output", () => {
  const response: MealInterpretationResponse = {
    title: "Photo meal",
    summary: "Estimated from photo.",
    confidenceBand: "medium",
    totals: {
      kcal: 0,
      carbs: 0,
      fat: 0,
      protein: 0,
    },
    items: [
      {
        id: "item_1",
        label: "Detected item 1",
        amount: 1,
        unit: "serving",
        kcal: 0,
        carbs: 0,
        fat: 0,
        protein: 0,
        confidenceBand: "medium",
        editable: true,
      },
    ],
  };

  if (isUsablePhotoResponse(response)) {
    throw new Error("Placeholder zero-nutrition photo output was accepted");
  }
});

Deno.test("isUsablePhotoResponse accepts complete photo nutrition output", () => {
  const response: MealInterpretationResponse = {
    title: "Chicken rice bowl",
    summary: "Chicken with rice estimated from the photo.",
    confidenceBand: "medium",
    totals: {
      kcal: 520,
      carbs: 55,
      fat: 14,
      protein: 42,
    },
    items: [
      {
        id: "item_1",
        label: "Grilled chicken breast",
        amount: 150,
        unit: "g",
        kcal: 250,
        carbs: 0,
        fat: 6,
        protein: 46,
        confidenceBand: "medium",
        editable: true,
      },
      {
        id: "item_2",
        label: "Cooked white rice",
        amount: 200,
        unit: "g",
        kcal: 270,
        carbs: 55,
        fat: 1,
        protein: 5,
        confidenceBand: "medium",
        editable: true,
      },
    ],
  };

  if (!isUsablePhotoResponse(response)) {
    throw new Error("Complete photo nutrition output was rejected");
  }
});

Deno.test("normalizeDraftResponse uses model-aware Gemini pricing", () => {
  const request: MealInterpretationRequest = {
    mode: "photo",
    imageBase64: "base64",
    locale: "en-US",
    unitSystem: "metric",
  };
  const response: MealInterpretationResponse = {
    title: "Meal",
    summary: "Summary",
    confidenceBand: "medium",
    totals: {
      kcal: 100,
      carbs: 10,
      fat: 5,
      protein: 8,
    },
    items: [],
  };

  const flashLiteDraft = normalizeDraftResponse(
    response,
    request,
    "gemini-2.5-flash-lite",
    {
      promptTokenCount: 100000,
      candidatesTokenCount: 50000,
    },
  );
  const flashDraft = normalizeDraftResponse(
    response,
    request,
    "gemini-2.5-flash",
    {
      promptTokenCount: 100000,
      candidatesTokenCount: 50000,
    },
  );

  if (flashLiteDraft.processing.estimatedCostUsd !== 0.03) {
    throw new Error(
      `Unexpected Flash-Lite cost: ${flashLiteDraft.processing.estimatedCostUsd}`,
    );
  }

  if (flashDraft.processing.estimatedCostUsd !== 0.155) {
    throw new Error(
      `Unexpected Flash cost: ${flashDraft.processing.estimatedCostUsd}`,
    );
  }
});

Deno.test("extractStructuredResponse tolerates fenced JSON with trailing commas", () => {
  const parsed = extractStructuredResponse({
    candidates: [
      {
        content: {
          parts: [
            {
              text: [
                "```json",
                "{",
                '  "title": "Chicken bowl",',
                '  "summary": "Estimated from photo.",',
                '  "confidenceBand": "medium",',
                '  "totals": {',
                '    "kcal": 540,',
                '    "carbs": 48,',
                '    "fat": 18,',
                '    "protein": 32,',
                "  },",
                '  "items": [],',
                "}",
                "```",
              ].join("\n"),
            },
          ],
        },
      },
    ],
  });

  if (parsed.title !== "Chicken bowl") {
    throw new Error(`Unexpected parsed title: ${parsed.title}`);
  }
  if (parsed.totals.kcal !== 540) {
    throw new Error(`Unexpected parsed kcal: ${parsed.totals.kcal}`);
  }
});

Deno.test("extractStructuredResponse ignores explanatory text around JSON", () => {
  const parsed = extractStructuredResponse({
    candidates: [
      {
        content: {
          parts: [
            {
              text:
                'Here is the estimate:\n{"title":"Toast","summary":"Estimated from photo.","confidenceBand":"high","totals":{"kcal":220,"carbs":24,"fat":8,"protein":9},"items":[]}\nUse it as needed.',
            },
          ],
        },
      },
    ],
  });

  if (parsed.title !== "Toast") {
    throw new Error(`Unexpected parsed title: ${parsed.title}`);
  }
  if (parsed.confidenceBand !== "high") {
    throw new Error(
      `Unexpected parsed confidence band: ${parsed.confidenceBand}`,
    );
  }
});
