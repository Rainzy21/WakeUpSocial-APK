-- ============================================================
-- WakeUpSocial Blueprint Schema Migration
-- Run after supabase_setup_main.sql on existing projects.
-- ============================================================

-- ── New ENUM types ──────────────────────────────────────────

DO $$ BEGIN
    CREATE TYPE public.user_role AS ENUM ('CUSTOMER', 'CASHIER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.tier_name AS ENUM ('BRONZE', 'SILVER', 'GOLD');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.session_status AS ENUM ('ACTIVE', 'CLOSED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.coupon_source AS ENUM ('MANUAL', 'MILESTONE_AUTO', 'STORE_REDEMPTION');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.coupon_status AS ENUM ('AVAILABLE', 'RESERVED', 'USED', 'EXPIRED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.discount_type AS ENUM ('FIXED_AMOUNT', 'PERCENTAGE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.coupon_applies_to AS ENUM ('ORDER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.loyalty_reason AS ENUM ('PURCHASE', 'REDEMPTION', 'ADMIN_ADJUST', 'REFUND');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.order_status_v2 AS ENUM (
        'SUBMITTED', 'REVIEWING', 'CONFIRMED', 'READY',
        'COMPLETED', 'CANCELLED', 'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ── Extend profiles ─────────────────────────────────────────

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS role                public.user_role NOT NULL DEFAULT 'CUSTOMER',
    ADD COLUMN IF NOT EXISTS fcm_token           TEXT,
    ADD COLUMN IF NOT EXISTS loyalty_points      INT              NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS lifetime_points     INT              NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS current_tier        public.tier_name NOT NULL DEFAULT 'BRONZE',
    ADD COLUMN IF NOT EXISTS purchase_count      INT              NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS current_stamp_count INT              NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (
        id, name, phone, avatar_url,
        role, loyalty_points, lifetime_points, current_tier,
        purchase_count, current_stamp_count
    )
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            split_part(NEW.email, '@', 1)
        ),
        NEW.raw_user_meta_data->>'phone',
        NEW.raw_user_meta_data->>'avatar_url',
        'CUSTOMER', 0, 0, 'BRONZE', 0, 0
    );
    RETURN NEW;
END;
$$;

-- ── Restaurant tables (QR registry) ─────────────────────────

CREATE TABLE IF NOT EXISTS public.restaurant_tables (
    id           UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    table_number INT         NOT NULL UNIQUE,
    qr_code      TEXT        NOT NULL UNIQUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Table sessions ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.table_sessions (
    id         UUID                  NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    UUID                  NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    table_id   UUID                  NOT NULL REFERENCES public.restaurant_tables(id),
    status     public.session_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ           NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_table_sessions_user_status
    ON public.table_sessions (user_id, status);

-- ── Tier config ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.tier_config (
    id          UUID             NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    tier_name   public.tier_name NOT NULL UNIQUE,
    threshold   INT              NOT NULL,
    description TEXT             NOT NULL
);

INSERT INTO public.tier_config (tier_name, threshold, description) VALUES
    ('BRONZE', 0,    'Default tier'),
    ('SILVER', 1000, 'Points required for Silver Tier'),
    ('GOLD',   5000, 'Points required for Gold Tier')
ON CONFLICT (tier_name) DO NOTHING;

-- ── Coupons ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.coupons (
    id                          UUID                     NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id                     UUID                     NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    code                        TEXT                     NOT NULL UNIQUE,
    source                      public.coupon_source     NOT NULL,
    status                      public.coupon_status     NOT NULL DEFAULT 'AVAILABLE',
    discount_type               public.discount_type     NOT NULL,
    discount_value              INT                      NOT NULL,
    max_value                   INT,
    applies_to                  public.coupon_applies_to NOT NULL DEFAULT 'ORDER',
    reserved_by_idempotency_key TEXT,
    expires_at                  TIMESTAMPTZ              NOT NULL,
    created_at                  TIMESTAMPTZ              NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_coupons_user_status
    ON public.coupons (user_id, status);

-- ── Loyalty transactions (append-only) ──────────────────────

CREATE TABLE IF NOT EXISTS public.loyalty_transactions (
    id         UUID                  NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    UUID                  NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    order_id   UUID,
    delta      INT                   NOT NULL,
    reason     public.loyalty_reason NOT NULL,
    created_at TIMESTAMPTZ           NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_loyalty_tx_user
    ON public.loyalty_transactions (user_id);

-- ── Menu: add category text + price_int ─────────────────────

ALTER TABLE public.menu_items
    ADD COLUMN IF NOT EXISTS category  TEXT,
    ADD COLUMN IF NOT EXISTS price_int INT;

UPDATE public.menu_items mi
SET category = mc.name
FROM public.menu_categories mc
WHERE mi.category_id = mc.id AND mi.category IS NULL;

UPDATE public.menu_items
SET price_int = ROUND(price)::INT
WHERE price_int IS NULL;

-- ── Orders: blueprint columns ───────────────────────────────

ALTER TABLE public.orders
    ADD COLUMN IF NOT EXISTS idempotency_key  TEXT UNIQUE,
    ADD COLUMN IF NOT EXISTS session_id       UUID REFERENCES public.table_sessions(id),
    ADD COLUMN IF NOT EXISTS table_id         UUID REFERENCES public.restaurant_tables(id),
    ADD COLUMN IF NOT EXISTS coupon_id        UUID REFERENCES public.coupons(id),
    ADD COLUMN IF NOT EXISTS subtotal         INT,
    ADD COLUMN IF NOT EXISTS discount_amount  INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_amount     INT,
    ADD COLUMN IF NOT EXISTS locked_until     TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS cashier_id       UUID REFERENCES auth.users(id),
    ADD COLUMN IF NOT EXISTS status_v2        public.order_status_v2;

UPDATE public.orders SET status_v2 = CASE status::text
    WHEN 'pending'    THEN 'SUBMITTED'::public.order_status_v2
    WHEN 'processing' THEN 'REVIEWING'::public.order_status_v2
    WHEN 'ready'      THEN 'READY'::public.order_status_v2
    WHEN 'delivered'  THEN 'COMPLETED'::public.order_status_v2
    WHEN 'cancelled'  THEN 'CANCELLED'::public.order_status_v2
    ELSE 'SUBMITTED'::public.order_status_v2
END
WHERE status_v2 IS NULL;

UPDATE public.orders
SET
    subtotal     = COALESCE(subtotal, ROUND(total_price)::INT),
    total_amount = COALESCE(total_amount, ROUND(total_price)::INT)
WHERE subtotal IS NULL OR total_amount IS NULL;

ALTER TABLE public.order_items
    ADD COLUMN IF NOT EXISTS unit_price INT;

UPDATE public.order_items
SET unit_price = ROUND(price)::INT
WHERE unit_price IS NULL;

CREATE INDEX IF NOT EXISTS idx_orders_status_updated
    ON public.orders (status_v2, updated_at);

CREATE INDEX IF NOT EXISTS idx_orders_user_status_v2
    ON public.orders (user_id, status_v2);

-- ── Seed QR tables ──────────────────────────────────────────

INSERT INTO public.restaurant_tables (table_number, qr_code) VALUES
    (1, 'WUS-TABLE-001'),
    (2, 'WUS-TABLE-002'),
    (3, 'WUS-TABLE-003'),
    (4, 'WUS-TABLE-004'),
    (5, 'WUS-TABLE-005')
ON CONFLICT (qr_code) DO NOTHING;
