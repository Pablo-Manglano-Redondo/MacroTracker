import { getCorsHeaders, jsonResponse } from "../_shared/cors.ts";
import { buildMealInterpretationDraft } from "../_shared/meal_interpretation.ts";
import { resolveRequestLocale, t } from "../_shared/i18n.ts";
import { authenticateUser } from "../_shared/auth.ts";

Deno.serve(async (request) => {
  const corsHeaders = getCorsHeaders(request);
  let locale = resolveRequestLocale(request);

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: t(locale, "common.methodNotAllowed") }, 405, corsHeaders);
  }

  const { errorResponse } = await authenticateUser(request, locale, corsHeaders);
  if (errorResponse) {
    return errorResponse;
  }

  try {
    const body = await request.json();
    locale = resolveRequestLocale(request, body);
    const text = typeof body?.text === "string" ? body.text.trim() : "";

    if (text.length < 2) {
      return jsonResponse({
        error: t(locale, "mealInterpretationsText.minChars"),
      }, 400, corsHeaders);
    }
    if (text.length > 800) {
      return jsonResponse({
        error: t(locale, "mealInterpretationsText.tooLong"),
      }, 400, corsHeaders);
    }

    const draft = await buildMealInterpretationDraft({
      mode: "text",
      text,
      locale: typeof body?.locale === "string" ? body.locale : "en-US",
      unitSystem:
        typeof body?.unitSystem === "string" ? body.unitSystem : "metric",
      mealTypeHint:
        typeof body?.mealTypeHint === "string" ? body.mealTypeHint : null,
      analysisContext:
        typeof body?.analysisContext === "string" ? body.analysisContext : null,
      personalExamples: Array.isArray(body?.personalExamples)
        ? body.personalExamples
        : null,
    });

    return jsonResponse(draft, 200, corsHeaders);
  } catch (error) {
    console.error("[meal-interpretations-text] failed", error);
    return jsonResponse(
      {
        error: t(locale, "mealInterpretationsText.processingFailed"),
      },
      500,
      corsHeaders,
    );
  }
});
