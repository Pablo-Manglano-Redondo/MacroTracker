import {
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
