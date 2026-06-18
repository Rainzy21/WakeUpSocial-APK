-- ============================================================
-- WakeUpSocial RLS Policies (Blueprint)
-- Replaces direct table writes with RPC-gated access where needed.
-- ============================================================

-- ── restaurant_tables ───────────────────────────────────────

ALTER TABLE public.restaurant_tables ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view restaurant tables" ON public.restaurant_tables;
CREATE POLICY "Anyone can view restaurant tables"
    ON public.restaurant_tables FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "Service role full access restaurant_tables" ON public.restaurant_tables;
CREATE POLICY "Service role full access restaurant_tables"
    ON public.restaurant_tables FOR ALL TO service_role USING (true) WITH CHECK (true);

-- ── table_sessions ──────────────────────────────────────────

ALTER TABLE public.table_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users view own sessions" ON public.table_sessions;
CREATE POLICY "Users view own sessions"
    ON public.table_sessions FOR SELECT TO authenticated
    USING (auth.uid() = user_id OR public.is_cashier());

DROP POLICY IF EXISTS "Service role sessions" ON public.table_sessions;
CREATE POLICY "Service role sessions"
    ON public.table_sessions FOR ALL TO service_role USING (true) WITH CHECK (true);

-- ── tier_config ─────────────────────────────────────────────

ALTER TABLE public.tier_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view tier config" ON public.tier_config;
CREATE POLICY "Anyone can view tier config"
    ON public.tier_config FOR SELECT TO authenticated USING (true);

-- ── coupons ─────────────────────────────────────────────────

ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users view own coupons" ON public.coupons;
CREATE POLICY "Users view own coupons"
    ON public.coupons FOR SELECT TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role coupons" ON public.coupons;
CREATE POLICY "Service role coupons"
    ON public.coupons FOR ALL TO service_role USING (true) WITH CHECK (true);

-- ── loyalty_transactions ────────────────────────────────────

ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users view own loyalty tx" ON public.loyalty_transactions;
CREATE POLICY "Users view own loyalty tx"
    ON public.loyalty_transactions FOR SELECT TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role loyalty tx" ON public.loyalty_transactions;
CREATE POLICY "Service role loyalty tx"
    ON public.loyalty_transactions FOR ALL TO service_role USING (true) WITH CHECK (true);

-- ── profiles: cashier can read all (for order display) ─────

DROP POLICY IF EXISTS "Cashiers can view all profiles" ON public.profiles;
CREATE POLICY "Cashiers can view all profiles"
    ON public.profiles FOR SELECT TO authenticated
    USING (public.is_cashier());

-- ── orders: cashiers can view all active orders ───────────────

DROP POLICY IF EXISTS "Cashiers can view all orders" ON public.orders;
CREATE POLICY "Cashiers can view all orders"
    ON public.orders FOR SELECT TO authenticated
    USING (public.is_cashier());

DROP POLICY IF EXISTS "Cashiers can view all order items" ON public.order_items;
CREATE POLICY "Cashiers can view all order items"
    ON public.order_items FOR SELECT TO authenticated
    USING (public.is_cashier());

-- ── menu_items: cashier can update availability ───────────────

DROP POLICY IF EXISTS "Cashiers view all menu items" ON public.menu_items;
CREATE POLICY "Cashiers view all menu items"
    ON public.menu_items FOR SELECT TO authenticated
    USING (public.is_cashier() OR is_available = true);

DROP POLICY IF EXISTS "Cashiers update menu availability" ON public.menu_items;
CREATE POLICY "Cashiers update menu availability"
    ON public.menu_items FOR UPDATE TO authenticated
    USING (public.is_cashier())
    WITH CHECK (public.is_cashier());
