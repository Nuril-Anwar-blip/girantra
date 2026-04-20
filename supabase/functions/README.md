## Supabase Edge Functions (Girantra / Proyek Akhir)

Functions:
- `midtrans-snap`: create Midtrans SNAP token and update transaction pending data.
- `midtrans-check-status`: check Midtrans status by `order_id`.
- `midtrans-webhook`: receive Midtrans callback, verify signature, update transaction status realtime.

### Required env vars
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `MIDTRANS_SERVER_KEY`
- `MIDTRANS_IS_PRODUCTION` (`true` / `false`)

### Deploy
```bash
supabase functions deploy midtrans-snap
supabase functions deploy midtrans-check-status
supabase functions deploy midtrans-webhook
```

### Set secrets
```bash
supabase secrets set SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="YOUR_SERVICE_ROLE_KEY"
supabase secrets set MIDTRANS_SERVER_KEY="SB-Mid-server-xxxx"
supabase secrets set MIDTRANS_IS_PRODUCTION="false"
```

### Midtrans webhook URL
Set in Midtrans Dashboard:
- `https://YOUR_PROJECT_REF.functions.supabase.co/midtrans-webhook`
