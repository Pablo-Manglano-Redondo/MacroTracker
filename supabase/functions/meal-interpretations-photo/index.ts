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
    const mimeType = resolveMimeType(body?.mimeType, body?.fileName);

    if (imageBase64.length < 32) {
      return jsonResponse({ error: "imageBase64 payload is missing" }, 400);
    }
    if (imageBase64.length > 14_000_000) {
      return jsonResponse({ error: "image payload is too large" }, 400);
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

function resolveMimeType(rawMimeType: unknown, rawFileName: unknown): string {
  if (typeof rawMimeType === "string") {
    const normalized = rawMimeType.trim().toLowerCase();
    if (normalized === "image/jpeg" ||
        normalized === "image/png" ||
        normalized === "image/webp" ||
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
      case "jpg":
      case "jpeg":
      default:
        return "image/jpeg";
    }
  }

  return "image/jpeg";
}
