import { createHash } from "https://deno.land/std@0.224.0/crypto/mod.ts";
import { corsHeaders } from "../_shared/cors.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const MIDTRANS_SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";

const statusMap: Record<string, { payment_status: string; order_status: string }> = {
  settlement: { payment_status: "paid", order_status: "processing" },
  capture: { payment_status: "paid", order_status: "processing" },
  pending: { payment_status: "pending", order_status: "pending" },
  deny: { payment_status: "failed", order_status: "cancelled" },
  cancel: { payment_status: "failed", order_status: "cancelled" },
  expire: { payment_status: "failed", order_status: "cancelled" },
  failure: { payment_status: "failed", order_status: "cancelled" },
  refund: { payment_status: "refunded", order_status: "cancelled" },
};

function jsonResponse(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function sha512(input: string): Promise<string> {
  const encoded = new TextEncoder().encode(input);
  const digest = await createHash("sha-512").update(encoded).digest("hex");
  return digest;
}

async function updateTransactionByCode(
  transactionCode: string,
  payload: Record<string, unknown>,
) {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Supabase env is not configured");
  }

  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/transactions?transaction_code=eq.${encodeURIComponent(transactionCode)}`,
    {
      method: "PATCH",
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=representation",
      },
      body: JSON.stringify(payload),
    },
  );

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Failed update transaction: ${err}`);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const body = await req.json();
    const orderId = body?.order_id as string | undefined;
    const statusCode = body?.status_code as string | undefined;
    const grossAmount = body?.gross_amount as string | undefined;
    const signatureKey = body?.signature_key as string | undefined;
    const transactionStatus = body?.transaction_status as string | undefined;
    const paymentType = body?.payment_type as string | undefined;

    if (!orderId || !statusCode || !grossAmount || !signatureKey || !transactionStatus) {
      return jsonResponse({ error: "Invalid webhook payload" }, 400);
    }
    if (!MIDTRANS_SERVER_KEY) {
      return jsonResponse({ error: "MIDTRANS_SERVER_KEY is missing" }, 500);
    }

    const raw = `${orderId}${statusCode}${grossAmount}${MIDTRANS_SERVER_KEY}`;
    const expectedSig = await sha512(raw);
    if (expectedSig !== signatureKey) {
      return jsonResponse({ error: "Invalid Midtrans signature" }, 401);
    }

    const mapped = statusMap[transactionStatus] ?? {
      payment_status: "pending",
      order_status: "pending",
    };

    await updateTransactionByCode(orderId, {
      payment_provider: "midtrans",
      payment_method: paymentType ?? "transfer",
      payment_status: mapped.payment_status,
      order_status: mapped.order_status,
      gateway_response: body,
      paid_at: mapped.payment_status === "paid" ? new Date().toISOString() : null,
      updated_at: new Date().toISOString(),
    });

    return jsonResponse({ ok: true, order_id: orderId });
  } catch (error) {
    return jsonResponse({ error: String(error) }, 500);
  }
});
