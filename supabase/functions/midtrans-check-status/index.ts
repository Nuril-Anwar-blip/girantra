import { corsHeaders } from "../_shared/cors.ts";

const isProduction = Deno.env.get("MIDTRANS_IS_PRODUCTION") === "true";
const midtransServerKey = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";
const MIDTRANS_API_BASE = isProduction
  ? "https://api.midtrans.com/v2"
  : "https://api.sandbox.midtrans.com/v2";

function jsonResponse(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);
  if (!midtransServerKey) return jsonResponse({ error: "MIDTRANS_SERVER_KEY is missing" }, 500);

  try {
    const { order_id } = await req.json();
    if (!order_id) return jsonResponse({ error: "order_id is required" }, 400);

    const auth = btoa(`${midtransServerKey}:`);
    const res = await fetch(`${MIDTRANS_API_BASE}/${order_id}/status`, {
      headers: { Authorization: `Basic ${auth}` },
    });
    const data = await res.json();
    return jsonResponse(data, res.status);
  } catch (error) {
    return jsonResponse({ error: String(error) }, 500);
  }
});
