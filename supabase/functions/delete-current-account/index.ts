import { createClient } from "npm:@supabase/supabase-js@2.48.1";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const serviceClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: corsHeaders(),
    });
  }
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }
  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Server auth is not configured" }, 500);
  }

  const authHeader = request.headers.get("authorization");
  if (!authHeader || !/^Bearer\s+/i.test(authHeader)) {
    return json({ error: "Authentication is required" }, 401);
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  const { data: authData, error: authError } = await serviceClient.auth.getUser(
    token,
  );
  if (authError || !authData.user) {
    return json({ error: "Invalid authentication" }, 401);
  }

  const userId = authData.user.id;

  try {
    const { error: deleteError } = await serviceClient.auth.admin.deleteUser(
      userId,
      false,
    );
    if (deleteError) {
      const details = deleteError.message.toLowerCase();
      if (details.includes("violates foreign key constraint")) {
        return json(
          {
            error:
              "Account deletion is blocked by database constraints. Apply the latest Supabase migrations before deploying this function.",
          },
          500,
        );
      }
      return json({ error: deleteError.message }, 500);
    }

    return json({ success: true, userId });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : "Unexpected error",
      },
      500,
    );
  }
});

function json(body: unknown, status = 200) {
  return Response.json(body, {
    status,
    headers: corsHeaders(),
  });
}

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}
