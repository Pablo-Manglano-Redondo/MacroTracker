export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function getCorsHeaders(request?: Request): Record<string, string> {
  const headers = {
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Origin": "*",
  };

  if (request) {
    const origin = request.headers.get("origin");
    if (origin) {
      if (isOriginAllowed(origin)) {
        headers["Access-Control-Allow-Origin"] = origin;
      } else {
        delete (headers as Partial<typeof headers>)["Access-Control-Allow-Origin"];
      }
    }
  }

  return headers;
}

function isOriginAllowed(origin: string): boolean {
  const allowedOrigins = [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8080",
  ];
  const envOrigins = Deno.env.get("ALLOWED_ORIGINS");
  if (envOrigins) {
    allowedOrigins.push(...envOrigins.split(",").map((o) => o.trim()));
  }
  return allowedOrigins.includes(origin);
}

export function jsonResponse(
  body: unknown,
  status = 200,
  headers?: Record<string, string>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...(headers ?? corsHeaders),
      "Content-Type": "application/json",
    },
  });
}
