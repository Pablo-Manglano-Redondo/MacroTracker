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
    const imageBase64 = typeof body?.imageBase64 === "string"
      ? body.imageBase64.trim().replace(/^data:image\/[a-zA-Z0-9.+-]+;base64,/, "")
      : "";

    if (imageBase64.length < 32) {
      return jsonResponse({ error: "imageBase64 payload is missing" }, 400);
    }
    if (imageBase64.length > 14_000_000) {
      return jsonResponse({ error: "image payload is too large" }, 400);
    }

    const draft = await buildMealInterpretationDraft({
      mode: "photo",
      imageBase64,
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
