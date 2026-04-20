import { corsHeaders } from "../_shared/cors.ts";

const MIDTRANS_BASE_URL =
  Deno.env.get("MIDTRANS_IS_PRODUCTION") === "true"
    ? "https://app.midtrans.com/snap/v1/transactions"
    : "https://app.sandbox.midtrans.com/snap/v1/transactions";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const midtransServerKey = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";

function jsonResponse(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function updateTransactionPending(
  transactionCode: string,
  snapToken: string,
  snapUrl: string,
) {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) return;

  await fetch(`${SUPABASE_URL}/rest/v1/transactions?transaction_code=eq.${transactionCode}`, {
    method: "PATCH",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "return=minimal",
    },
    body: JSON.stringify({
      payment_provider: "midtrans",
      payment_token: snapToken,
      payment_url: snapUrl,
      payment_status: "pending",
      payment_method: "transfer",
    }),
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);
  if (!midtransServerKey) return jsonResponse({ error: "MIDTRANS_SERVER_KEY is missing" }, 500);

  try {
    const body = await req.json();
    const {
      order_id,
      gross_amount,
      customer_name,
      customer_email,
      customer_phone,
      item_name,
      item_price,
      item_quantity,
    } = body ?? {};

    if (!order_id || !gross_amount || !customer_name || !customer_email) {
      return jsonResponse({ error: "Missing required payload" }, 400);
    }

    const auth = btoa(`${midtransServerKey}:`);
    const response = await fetch(MIDTRANS_BASE_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${auth}`,
      },
      body: JSON.stringify({
        transaction_details: {
          order_id,
          gross_amount: Number(gross_amount),
        },
        customer_details: {
          first_name: customer_name,
          email: customer_email,
          phone: customer_phone ?? "",
        },
        item_details: [
          {
            id: order_id,
            name: item_name ?? "Produk",
            price: Number(item_price ?? gross_amount),
            quantity: Number(item_quantity ?? 1),
          },
        ],
      }),
    });

    const data = await response.json();
    if (!response.ok) {
      return jsonResponse(
        { error: data?.status_message ?? "Failed create Midtrans transaction" },
        response.status,
      );
    }

    await updateTransactionPending(order_id, data?.token ?? "", data?.redirect_url ?? "");
    return jsonResponse(data, 200);
  } catch (error) {
    return jsonResponse({ error: String(error) }, 500);
  }
});
