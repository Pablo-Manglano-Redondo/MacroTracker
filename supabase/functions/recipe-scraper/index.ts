import { corsHeaders, jsonResponse } from "../_shared/cors.ts";

const recipeScraperSchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "title",
    "servings",
    "prepTimeMinutes",
    "cookTimeMinutes",
    "ingredients",
    "instructions",
    "estimatedMacros",
  ],
  properties: {
    title: { type: "string" },
    servings: { type: "number", minimum: 1 },
    prepTimeMinutes: { type: "number", minimum: 0 },
    cookTimeMinutes: { type: "number", minimum: 0 },
    ingredients: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "name",
          "amount",
          "unit",
          "kcal100",
          "carbs100",
          "fat100",
          "protein100",
        ],
        properties: {
          name: { type: "string" },
          amount: { type: "number", minimum: 0 },
          unit: { type: "string" },
          kcal100: {
            type: "number",
            minimum: 0,
            description:
              "Calories per 100g (for g/ml units) or per 100 units (for other units like piece/serving)",
          },
          carbs100: {
            type: "number",
            minimum: 0,
            description: "Carbs per 100g or per 100 units",
          },
          fat100: {
            type: "number",
            minimum: 0,
            description: "Fat per 100g or per 100 units",
          },
          protein100: {
            type: "number",
            minimum: 0,
            description: "Protein per 100g or per 100 units",
          },
        },
      },
    },
    instructions: {
      type: "array",
      items: { type: "string" },
    },
    estimatedMacros: {
      type: "object",
      additionalProperties: false,
      required: ["kcal", "carbs", "fat", "protein"],
      properties: {
        kcal: { type: "number", minimum: 0 },
        carbs: { type: "number", minimum: 0 },
        fat: { type: "number", minimum: 0 },
        protein: { type: "number", minimum: 0 },
      },
    },
  },
};

function cleanHtmlToText(html: string): string {
  let text = html;
  // Remove script and style blocks completely
  text = text.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "");
  text = text.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, "");
  // Strip all HTML tags
  text = text.replace(/<[^>]+>/g, " ");
  // Unescape common HTML entities
  text = text
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
  // Clean up whitespace
  text = text.replace(/\s+/g, " ").trim();
  // Limit text length to avoid token limits (e.g. 50,000 characters is plenty for a recipe page)
  if (text.length > 50000) {
    text = text.substring(0, 50000);
  }
  return text;
}

function calculateEstimatedCost(usageMetadata?: {
  promptTokenCount?: number;
  candidatesTokenCount?: number;
}) {
  if (!usageMetadata) return 0;
  const promptTokens = usageMetadata.promptTokenCount ?? 0;
  const candidatesTokens = usageMetadata.candidatesTokenCount ?? 0;
  return (promptTokens * 0.075 / 1000000) + (candidatesTokens * 0.30 / 1000000);
}

const blockedHostnames = new Set([
  "localhost",
  "metadata.google.internal",
  "metadata",
  "169.254.169.254",
  "100.100.100.200",
]);
const invalidRecipeUrlErrors = new Set([
  "Invalid URL",
  "Credentialed URLs are not allowed",
  "Private or local network URLs are not allowed",
]);

function isIpv4Address(value: string): boolean {
  return /^\d{1,3}(?:\.\d{1,3}){3}$/.test(value);
}

function isBlockedIpv4(value: string): boolean {
  const parts = value.split(".").map((part) => Number(part));
  if (parts.length !== 4 || parts.some((part) => Number.isNaN(part) || part < 0 || part > 255)) {
    return true;
  }

  const [a, b] = parts;
  return a === 0 ||
    a === 10 ||
    a === 127 ||
    (a === 100 && b >= 64 && b <= 127) ||
    (a === 169 && b === 254) ||
    (a === 172 && b >= 16 && b <= 31) ||
    (a === 192 && b === 168) ||
    (a === 198 && (b === 18 || b === 19));
}

function normalizeIpv6(value: string): string {
  return value.toLowerCase().replace(/^\[|\]$/g, "");
}

function isBlockedIpv6(value: string): boolean {
  const normalized = normalizeIpv6(value);
  return normalized === "::1" ||
    normalized === "::" ||
    normalized.startsWith("fc") ||
    normalized.startsWith("fd") ||
    normalized.startsWith("fe80:") ||
    normalized === "2001:db8::" ||
    normalized.startsWith("::ffff:127.") ||
    normalized.startsWith("::ffff:10.") ||
    normalized.startsWith("::ffff:192.168.") ||
    normalized.startsWith("::ffff:169.254.") ||
    /^::ffff:172\.(1[6-9]|2\d|3[0-1])\./.test(normalized);
}

async function assertPublicRecipeUrl(rawUrl: string): Promise<URL> {
  let parsedUrl: URL;
  try {
    parsedUrl = new URL(rawUrl);
  } catch {
    throw new Error("Invalid URL");
  }

  if (parsedUrl.protocol !== "http:" && parsedUrl.protocol !== "https:") {
    throw new Error("Invalid URL");
  }

  if (parsedUrl.username || parsedUrl.password) {
    throw new Error("Credentialed URLs are not allowed");
  }

  const hostname = parsedUrl.hostname.toLowerCase();
  if (
    blockedHostnames.has(hostname) ||
    hostname.endsWith(".local") ||
    hostname.endsWith(".internal")
  ) {
    throw new Error("Private or local network URLs are not allowed");
  }

  if (isIpv4Address(hostname) && isBlockedIpv4(hostname)) {
    throw new Error("Private or local network URLs are not allowed");
  }

  if (hostname.includes(":") && isBlockedIpv6(hostname)) {
    throw new Error("Private or local network URLs are not allowed");
  }

  const recordTypes: Deno.RecordType[] = ["A", "AAAA"];
  for (const recordType of recordTypes) {
    try {
      const records = await Deno.resolveDns(hostname, recordType);
      for (const record of records) {
        if (
          isBlockedIpv4(record) ||
          isBlockedIpv6(record)
        ) {
          throw new Error("Private or local network URLs are not allowed");
        }
      }
    } catch (error) {
      if (error instanceof Error &&
          error.message === "Private or local network URLs are not allowed") {
        throw error;
      }
    }
  }

  return parsedUrl;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const body = await request.json();
    const url = typeof body?.url === "string" ? body.url.trim() : "";
    const locale = typeof body?.locale === "string" ? body.locale : "en-US";

    const parsedUrl = await assertPublicRecipeUrl(url);

    // Fetch the webpage content
    const fetchResponse = await fetch(parsedUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      },
    });

    if (!fetchResponse.ok) {
      return jsonResponse(
        { error: `Failed to fetch the webpage: status ${fetchResponse.status}` },
        400,
      );
    }

    const html = await fetchResponse.text();
    const cleanText = cleanHtmlToText(html);

    if (cleanText.length < 50) {
      return jsonResponse({ error: "Webpage has insufficient text content" }, 400);
    }

    // Call Gemini API
    const model = Deno.env.get("GEMINI_RECIPE_MODEL") ?? "gemini-2.5-flash-lite";
    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      throw new Error("Missing GEMINI_API_KEY in environment");
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
          parts: [
            {
              text:
                `You are an expert recipe extractor. Extract the recipe details (title, servings, prep/cook time, ingredients list, step-by-step instructions, and estimated macros) from the provided webpage text content. Always respond with text fields (title, ingredients names, instructions) translated to language: ${locale}. Estimate calories and macronutrients if not clearly stated on the webpage. For each ingredient, estimate kcal100, carbs100, fat100, protein100 per 100g (for g/ml) or per 100 units (for servings/pieces, e.g., if 1 egg has 78 kcal, its kcal100 is 7800).`,
            },
          ],
        },
        contents: [
          {
            role: "user",
            parts: [{ text: cleanText }],
          },
        ],
        generationConfig: {
          temperature: 0.1,
          responseMimeType: "application/json",
          responseJsonSchema: recipeScraperSchema,
        },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      return jsonResponse({ error: `Gemini error: ${errorText}` }, 500);
    }

    const payload = await response.json();
    const candidates = payload?.candidates;
    if (!candidates || candidates.length === 0) {
      return jsonResponse({ error: "No recipe suggestions found" }, 500);
    }

    const textResult = candidates[0]?.content?.parts[0]?.text;
    if (!textResult) {
      return jsonResponse({ error: "Invalid text result from Gemini" }, 500);
    }

    const result = JSON.parse(textResult);

    return jsonResponse({
      recipe: result,
      estimatedCostUsd: calculateEstimatedCost(payload?.usageMetadata),
    });
  } catch (error) {
    if (error instanceof Error && invalidRecipeUrlErrors.has(error.message)) {
      return jsonResponse(
        {
          error: error.message,
        },
        400,
      );
    }
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Unexpected error",
      },
      500,
    );
  }
});
