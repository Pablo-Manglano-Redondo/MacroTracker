import { createClient, User } from "npm:@supabase/supabase-js@2.48.1";
import { RequestLocale, t } from "./i18n.ts";
import { jsonResponse } from "./cors.ts";

let _supabaseClient: ReturnType<typeof createClient> | null = null;

export function getSupabaseClient() {
  if (!_supabaseClient) {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "https://placeholder-project.supabase.co";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "placeholder-key";
    _supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      auth: { persistSession: false },
    });
  }
  return _supabaseClient;
}

/**
 * Validates the Authorization header in the request.
 * If authentication fails, returns an errorResponse.
 * If authentication succeeds, returns the authenticated user.
 */
export async function authenticateUser(
  request: Request,
  locale: RequestLocale,
  corsHeaders: Record<string, string>,
): Promise<{ user?: User; errorResponse?: Response }> {
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !/^Bearer\s+/i.test(authHeader)) {
    return {
      errorResponse: jsonResponse(
        { error: t(locale, "common.authenticationRequired") },
        401,
        corsHeaders,
      ),
    };
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  const client = getSupabaseClient();
  const { data: authData, error: authError } = await client.auth.getUser(
    token,
  );

  if (authError || !authData.user) {
    return {
      errorResponse: jsonResponse(
        { error: t(locale, "common.invalidAuthentication") },
        401,
        corsHeaders,
      ),
    };
  }

  return { user: authData.user };
}
