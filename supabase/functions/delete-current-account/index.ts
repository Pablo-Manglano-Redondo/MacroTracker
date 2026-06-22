import { createClient } from "npm:@supabase/supabase-js@2.48.1";
import { resolveRequestLocale, t } from "../_shared/i18n.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const serviceClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

Deno.serve(async (request) => {
  const locale = resolveRequestLocale(request);

  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: corsHeaders(),
    });
  }
  if (request.method !== "POST") {
    return json({ error: t(locale, "common.methodNotAllowed") }, 405);
  }
  if (!supabaseUrl || !serviceRoleKey) {
    return json({
      error: t(locale, "deleteCurrentAccount.serverAuthNotConfigured"),
    }, 500);
  }

  const authHeader = request.headers.get("authorization");
  if (!authHeader || !/^Bearer\s+/i.test(authHeader)) {
    return json({
      error: t(locale, "common.authenticationRequired"),
    }, 401);
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  const { data: authData, error: authError } = await serviceClient.auth.getUser(
    token,
  );
  if (authError || !authData.user) {
    return json({
      error: t(locale, "common.invalidAuthentication"),
    }, 401);
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
            error: t(locale, "deleteCurrentAccount.blockedByConstraints"),
          },
          500,
        );
      }
      console.error("[delete-current-account] deleteUser failed", deleteError);
      return json({ error: t(locale, "deleteCurrentAccount.deleteFailed") }, 500);
    }

    return json({ success: true, userId });
  } catch (error) {
    console.error("[delete-current-account] unexpected failure", error);
    return json(
      {
        error: t(locale, "deleteCurrentAccount.deleteFailed"),
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
