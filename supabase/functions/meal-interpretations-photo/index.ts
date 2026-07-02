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
    const startedAt = performance.now();
    const body = await request.json();
    locale = resolveRequestLocale(request, body);
    const imageBase64 = typeof body?.imageBase64 === "string"
      ? body.imageBase64.trim().replace(/^data:image\/[a-zA-Z0-9.+-]+;base64,/, "")
      : "";
    const mimeType = resolveMimeType(body?.mimeType, body?.fileName);

    if (imageBase64.length < 32) {
      return jsonResponse({
        error: t(locale, "mealInterpretationsPhoto.missingImageBase64"),
      }, 400, corsHeaders);
    }
    if (imageBase64.length > 20_000_000) {
      return jsonResponse({
        error: t(locale, "mealInterpretationsPhoto.imageTooLarge"),
      }, 400, corsHeaders);
    }

    const draft = await buildMealInterpretationDraft({
      mode: "photo",
      imageBase64,
      mimeType,
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

    const diagnostics = draft?.processing?.diagnostics;
    console.log(
      JSON.stringify({
        tag: "meal-interpretations-photo",
        edgeTotalMs: Math.round(performance.now() - startedAt),
        inputImageBytes: diagnostics?.inputImageBytes ?? null,
        promptChars: diagnostics?.promptChars ?? null,
        geminiFetchMs: diagnostics?.geminiFetchMs ?? null,
        responseParseMs: diagnostics?.responseParseMs ?? null,
        normalizeMs: diagnostics?.normalizeMs ?? null,
        personalExamplesCount: diagnostics?.personalExamplesCount ?? null,
        correctionExamplesCount: diagnostics?.correctionExamplesCount ?? null,
        modelAttempts: diagnostics?.modelAttempts ?? null,
        fallbackUsed: diagnostics?.fallbackUsed ?? null,
      }),
    );

    return jsonResponse(draft, 200, corsHeaders);
  } catch (error) {
    console.error("[meal-interpretations-photo] failed", error);
    return jsonResponse(
      {
        error: t(locale, "mealInterpretationsPhoto.processingFailed"),
      },
      500,
      corsHeaders,
    );
  }
});

function resolveMimeType(rawMimeType: unknown, rawFileName: unknown): string {
  if (typeof rawMimeType === "string") {
    const normalized = rawMimeType.trim().toLowerCase();
    if (normalized === "image/jpeg" ||
        normalized === "image/png" ||
        normalized === "image/webp" ||
        normalized === "image/heic" ||
        normalized === "image/heif" ||
        normalized === "image/gif") {
      return normalized;
    }
  }

  if (typeof rawFileName === "string") {
    const extension = rawFileName.split(".").pop()?.toLowerCase();
    switch (extension) {
      case "png":
        return "image/png";
      case "webp":
        return "image/webp";
      case "gif":
        return "image/gif";
      case "heic":
        return "image/heic";
      case "heif":
        return "image/heif";
      case "jpg":
      case "jpeg":
      default:
        return "image/jpeg";
    }
  }

  return "image/jpeg";
}
