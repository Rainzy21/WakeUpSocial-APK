-- ============================================================
-- WakeUpSocial pg_cron Jobs
-- Requires pg_cron extension enabled in Supabase dashboard.
-- Run manually if pg_cron is unavailable:
--   SELECT public.release_stale_review_locks();
--   SELECT public.expire_stale_orders();
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.unschedule(jobid)
FROM cron.job
WHERE jobname IN ('release_stale_review_locks', 'expire_stale_orders');

SELECT cron.schedule(
    'release_stale_review_locks',
    '* * * * *',
    $$SELECT public.release_stale_review_locks()$$
);

SELECT cron.schedule(
    'expire_stale_orders',
    '*/5 * * * *',
    $$SELECT public.expire_stale_orders()$$
);
