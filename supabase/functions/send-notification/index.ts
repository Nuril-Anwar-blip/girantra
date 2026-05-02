// import { corsHeaders } from "../_shared/cors.ts";

// // ============================================================================
// // Supabase Edge Function: Send Notification
// // ============================================================================
// // Fungsi ini dipanggil dari Flutter app untuk mengirim notifikasi push (FCM)
// // dan menyimpan notifikasi ke tabel 'notifications' di Supabase.
// //
// // Flow:
// // 1. Validasi input (user_id, title, message wajib)
// // 2. Simpan notifikasi ke database (tabel notifications)
// // 3. Ambil semua FCM token milik user dari user_fcm_tokens
// // 4. Kirim push notification ke semua device user (paralel dengan Promise.all)
// // 5. Return hasil pengiriman FCM
// //
// // Environment Variables:
// // - SUPABASE_URL: URL instance Supabase
// // - SUPABASE_SERVICE_ROLE_KEY: Service role key (server-side only)
// // - FCM_SERVER_KEY: Firebase Cloud Messaging server key
// // ============================================================================

// // ── Konfigurasi environment variables ─────────────────────────────────────────
// // SUPABASE_URL: URL instance Supabase (contoh: https://xxx.supabase.co)
// // SUPABASE_SERVICE_ROLE_KEY: Service role key untuk akses API (jangan di-commit!)
// // FCM_SERVER_KEY: Firebase Cloud Messaging server key untuk push notification
// const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
// const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
// const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY") ?? "";

// // ── Handler utama untuk Edge Function ─────────────────────────────────────────
// // Fungsi ini dipanggil dari Flutter aplikasi untuk mengirim notifikasi
// Deno.serve(async (req) => {
//   // Handle preflight CORS request
//   if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

//   try {
//     // ── 1. Parse dan validasi input JSON ──────────────────────────────────────
//     const { user_id, title, message, notification_type, related_id } = await req.json();

//     // Validasi field wajib
//     if (!user_id || !title || !message) {
//       return new Response(JSON.stringify({ error: "Missing required fields: user_id, title, message" }), {
//         status: 400,
//         headers: { ...corsHeaders, "Content-Type": "application/json" },
//       });
//     }

//     // ── 2. Simpan notifikasi ke tabel 'notifications' di Supabase ───────────────
//     // Notifikasi akan tampil di dalam app (tab Notifikasi)
//     await fetch(`${SUPABASE_URL}/rest/v1/notifications`, {
//       method: "POST",
//       headers: {
//         apikey: SUPABASE_SERVICE_ROLE_KEY,
//         Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
//         "Content-Type": "application/json",
//       },
//       body: JSON.stringify({ user_id, title, message, notification_type, related_id }),
//     });

//     // ── 3. Ambil semua FCM token milik user ────────────────────────────────────
//     // FCM token digunakan untuk mengirim push notification ke device user
//     const tokenRes = await fetch(
//       `${SUPABASE_URL}/rest/v1/user_fcm_tokens?user_id=eq.${user_id}&select=fcm_token`,
//       {
//         headers: {
//           apikey: SUPABASE_SERVICE_ROLE_KEY,
//           Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
//         },
//       }
//     );
//     const tokens = await tokenRes.json();

//     // ── 4. Kirim push notification ke semua device user (paralel) ───────────────
//     // Menggunakan Promise.all untuk mengirim ke semua token secara bersamaan
//     const fcmPromises = tokens.map(({ fcm_token }: { fcm_token: string }) =>
//       fetch("https://fcm.googleapis.com/fcm/send", {
//         method: "POST",
//         headers: {
//           Authorization: `key=${FCM_SERVER_KEY}`,
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({
//           to: fcm_token,
//           notification: { title, body: message },
//           data: { notification_type, related_id: String(related_id ?? "") },
//         }),
//       }).catch(err => {
//         // Log error tapi jangan stop pengiriman ke token lain
//         console.error(`Failed to send FCM to token ${fcm_token}:`, err);
//         return null;
//       })
//       .then(res => ({ token: fcm_token, success: res?.status === 200 }))
//     );

//     const results = await Promise.all(fcmPromises);
//     console.log("FCM send results:", results);

//     return new Response(JSON.stringify({ ok: true, fcm_results: results }), {
//       headers: { ...corsHeaders, "Content-Type": "application/json" },
//     });
//   } catch (e) {
//     console.error("Send notification error:", e);
//     return new Response(JSON.stringify({ error: String(e) }), {
//       status: 500,
//       headers: { ...corsHeaders, "Content-Type": "application/json" },
//     });
//   }
// });