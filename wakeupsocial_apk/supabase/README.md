# Supabase Migrations — Wake Up Social Blueprint

Run these SQL files **in order** in the Supabase Dashboard → SQL Editor:

1. `supabase_setup_main.sql` (existing base schema — skip if already applied)
2. `migrations/001_blueprint_schema.sql` — profiles loyalty fields, sessions, coupons, order columns
3. `migrations/002_rpc_functions.sql` — all business logic RPCs
4. `migrations/003_rls_policies.sql` — role-aware RLS
5. `migrations/004_pg_cron.sql` — stale order cron (requires pg_cron extension)

## Cashier promotion

```sql
UPDATE public.profiles SET role = 'CASHIER' WHERE email = 'cashier@example.com';
```

## Test QR codes

| Table | QR Code |
|-------|---------|
| 1 | WUS-TABLE-001 |
| 2 | WUS-TABLE-002 |
| 3 | WUS-TABLE-003 |

## Edge Function (FCM)

Configure a Database Webhook on `orders` UPDATE → `send-fcm` after deploying the function.
