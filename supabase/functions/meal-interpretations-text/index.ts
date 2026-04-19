import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { buildMealInterpretationDraft } from "../_shared/meal_interpretation.ts";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const body = await request.json();
    const text = typeof body?.text === "string" ? body.text.trim() : "";

    if (text.length < 2) {
      return jsonResponse({ error: "text must contain at least 2 characters" }, 400);
    }
    if (text.length > 800) {
      return jsonResponse({ error: "text is too long" }, 400);
    }

    const draft = await buildMealInterpretationDraft({
      mode: "text",
      text,
      locale: typeof body?.locale === "string" ? body.locale : "en-US",
      unitSystem:
        typeof body?.unitSystem === "string" ? body.unitSystem : "metric",
      mealTypeHint:
        typeof body?.mealTypeHint === "string" ? body.mealTypeHint : null,
    });

    return jsonResponse(draft);
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Unexpected error",
      },
      500,
    );
  }
});
