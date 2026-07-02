import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { getCorsHeaders } from "./cors.ts";
import { authenticateUser, getSupabaseClient } from "./auth.ts";

Deno.test("getCorsHeaders allows * by default if no request or origin is present", () => {
  const headers = getCorsHeaders();
  assertEquals(headers["Access-Control-Allow-Origin"], "*");
});

Deno.test("getCorsHeaders allows exact origin if in the standard allowlist", () => {
  const request = new Request("http://localhost:3000", {
    headers: { origin: "http://localhost:3000" },
  });
  const headers = getCorsHeaders(request);
  assertEquals(headers["Access-Control-Allow-Origin"], "http://localhost:3000");
});

Deno.test("getCorsHeaders rejects disallowed origins", () => {
  const request = new Request("http://localhost:3000", {
    headers: { origin: "http://malicious.com" },
  });
  const headers = getCorsHeaders(request);
  assertEquals(headers["Access-Control-Allow-Origin"], undefined);
});

Deno.test("getCorsHeaders respects ALLOWED_ORIGINS environment variable", () => {
  Deno.env.set("ALLOWED_ORIGINS", "https://my-prod-portal.com, https://another-portal.com");
  try {
    const request1 = new Request("http://localhost:3000", {
      headers: { origin: "https://my-prod-portal.com" },
    });
    const headers1 = getCorsHeaders(request1);
    assertEquals(headers1["Access-Control-Allow-Origin"], "https://my-prod-portal.com");

    const request2 = new Request("http://localhost:3000", {
      headers: { origin: "https://another-portal.com" },
    });
    const headers2 = getCorsHeaders(request2);
    assertEquals(headers2["Access-Control-Allow-Origin"], "https://another-portal.com");
  } finally {
    Deno.env.delete("ALLOWED_ORIGINS");
  }
});

Deno.test({
  name: "authenticateUser fails when authorization header is missing",
  sanitizeOps: false,
  sanitizeResources: false,
  fn: async () => {
    const request = new Request("http://localhost:3000");
    try {
      const result = await authenticateUser(request, "en", {});
      assertEquals(result.user, undefined);
      assertEquals(result.errorResponse !== undefined, true);
      assertEquals(result.errorResponse?.status, 401);

      const body = await result.errorResponse?.json();
      assertEquals(body.error, "Authentication is required");
    } catch (err) {
      console.error("ERROR IN TEST:", err);
      throw err;
    }
  },
});

Deno.test({
  name: "authenticateUser fails when authorization header is malformed",
  sanitizeOps: false,
  sanitizeResources: false,
  fn: async () => {
    const request = new Request("http://localhost:3000", {
      headers: { authorization: "Basic abc:123" },
    });
    const result = await authenticateUser(request, "en", {});
    assertEquals(result.user, undefined);
    assertEquals(result.errorResponse !== undefined, true);
    assertEquals(result.errorResponse?.status, 401);
  },
});

Deno.test({
  name: "authenticateUser fails when JWT is invalid",
  sanitizeOps: false,
  sanitizeResources: false,
  fn: async () => {
    const request = new Request("http://localhost:3000", {
      headers: { authorization: "Bearer invalid-token" },
    });

    // Mock getSupabaseClient().auth.getUser
    const client = getSupabaseClient();
    const originalGetUser = client.auth.getUser;
    client.auth.getUser = () => {
      return Promise.resolve({
        data: { user: null },
        error: { message: "Invalid JWT", status: 400, name: "AuthException" } as any,
      });
    };

    try {
      const result = await authenticateUser(request, "en", {});
      assertEquals(result.user, undefined);
      assertEquals(result.errorResponse !== undefined, true);
      assertEquals(result.errorResponse?.status, 401);
      const body = await result.errorResponse?.json();
      assertEquals(body.error, "Invalid authentication");
    } finally {
      client.auth.getUser = originalGetUser;
    }
  },
});

Deno.test({
  name: "authenticateUser succeeds when JWT is valid",
  sanitizeOps: false,
  sanitizeResources: false,
  fn: async () => {
    const request = new Request("http://localhost:3000", {
      headers: { authorization: "Bearer valid-token" },
    });

    const mockUser = {
      id: "test-user-id",
      email: "test@example.com",
    };

    // Mock getSupabaseClient().auth.getUser
    const client = getSupabaseClient();
    const originalGetUser = client.auth.getUser;
    client.auth.getUser = (token: string) => {
      assertEquals(token, "valid-token");
      return Promise.resolve({
        data: { user: mockUser as any },
        error: null,
      });
    };

    try {
      const result = await authenticateUser(request, "en", {});
      assertEquals(result.errorResponse, undefined);
      assertEquals(result.user?.id, "test-user-id");
      assertEquals(result.user?.email, "test@example.com");
    } finally {
      client.auth.getUser = originalGetUser;
    }
  },
});
