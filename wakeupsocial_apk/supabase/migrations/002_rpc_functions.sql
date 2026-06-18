-- ============================================================
-- WakeUpSocial RPC Functions
-- Business logic previously in NestJS, now in Postgres.
-- ============================================================

-- ── Helpers ─────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.is_cashier()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'CASHIER'
    );
$$;

CREATE OR REPLACE FUNCTION public.calculate_discount(p_subtotal INT, p_coupon_id UUID)
RETURNS INT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_coupon public.coupons%ROWTYPE;
    v_raw    INT;
BEGIN
    IF p_coupon_id IS NULL THEN RETURN 0; END IF;

    SELECT * INTO v_coupon FROM public.coupons WHERE id = p_coupon_id;
    IF NOT FOUND THEN RETURN 0; END IF;

    IF v_coupon.discount_type = 'FIXED_AMOUNT' THEN
        RETURN LEAST(p_subtotal, v_coupon.discount_value);
    END IF;

    v_raw := FLOOR((p_subtotal * v_coupon.discount_value) / 100.0);
    RETURN LEAST(v_raw, COALESCE(v_coupon.max_value, v_raw));
END;
$$;

CREATE OR REPLACE FUNCTION public.generate_coupon_code()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_chars  TEXT := 'ABCDEFGHJKLMNPQRTUVWXYZ2346789';
    v_code   TEXT;
    v_i      INT;
    v_exists BOOLEAN;
BEGIN
    LOOP
        v_code := '';
        FOR v_i IN 1..6 LOOP
            v_code := v_code || substr(v_chars, floor(random() * length(v_chars) + 1)::int, 1);
        END LOOP;
        SELECT EXISTS(SELECT 1 FROM public.coupons WHERE code = v_code) INTO v_exists;
        EXIT WHEN NOT v_exists;
    END LOOP;
    RETURN v_code;
END;
$$;

CREATE OR REPLACE FUNCTION public.issue_milestone_coupon(p_user_id UUID)
RETURNS public.coupons
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_coupon public.coupons;
BEGIN
    INSERT INTO public.coupons (
        user_id, code, source, status,
        discount_type, discount_value, expires_at
    ) VALUES (
        p_user_id,
        public.generate_coupon_code(),
        'MILESTONE_AUTO',
        'AVAILABLE',
        'FIXED_AMOUNT',
        32000,
        now() + interval '30 days'
    )
    RETURNING * INTO v_coupon;

    RETURN v_coupon;
END;
$$;

-- ── create_session ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.create_session(p_table_id UUID)
RETURNS public.table_sessions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid      UUID := auth.uid();
    v_session  public.table_sessions;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.restaurant_tables WHERE id = p_table_id) THEN
        RAISE EXCEPTION 'Table not found';
    END IF;

    SELECT * INTO v_session
    FROM public.table_sessions
    WHERE user_id = v_uid AND table_id = p_table_id AND status = 'ACTIVE'
    LIMIT 1;

    IF FOUND THEN RETURN v_session; END IF;

    INSERT INTO public.table_sessions (user_id, table_id, status)
    VALUES (v_uid, p_table_id, 'ACTIVE')
    RETURNING * INTO v_session;

    RETURN v_session;
END;
$$;

CREATE OR REPLACE FUNCTION public.resolve_table_by_qr(p_qr_code TEXT)
RETURNS public.restaurant_tables
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_table public.restaurant_tables;
BEGIN
    SELECT * INTO v_table FROM public.restaurant_tables WHERE qr_code = p_qr_code;
    IF NOT FOUND THEN RAISE EXCEPTION 'Invalid QR code'; END IF;
    RETURN v_table;
END;
$$;

-- ── validate_coupon ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.validate_coupon(p_code TEXT, p_subtotal INT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid      UUID := auth.uid();
    v_coupon   public.coupons%ROWTYPE;
    v_discount INT;
BEGIN
    SELECT * INTO v_coupon
    FROM public.coupons
    WHERE code = upper(trim(p_code))
      AND status = 'AVAILABLE'
      AND expires_at > now()
      AND (v_uid IS NULL OR user_id = v_uid);

    IF NOT FOUND THEN
        RETURN jsonb_build_object('valid', false, 'discounted_total', p_subtotal);
    END IF;

    v_discount := public.calculate_discount(p_subtotal, v_coupon.id);
    RETURN jsonb_build_object(
        'valid', true,
        'coupon_id', v_coupon.id,
        'discounted_total', GREATEST(0, p_subtotal - v_discount)
    );
END;
$$;

-- ── get_wallet ──────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_wallet()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_profile public.profiles%ROWTYPE;
    v_coupons JSONB;
BEGIN
    IF v_uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    SELECT * INTO v_profile FROM public.profiles WHERE id = v_uid;

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', c.id, 'code', c.code, 'discount_type', c.discount_type,
        'discount_value', c.discount_value, 'expires_at', c.expires_at
    )), '[]'::jsonb)
    INTO v_coupons
    FROM public.coupons c
    WHERE c.user_id = v_uid AND c.status = 'AVAILABLE' AND c.expires_at > now();

    RETURN jsonb_build_object(
        'current_stamp_count', v_profile.current_stamp_count,
        'loyalty_points', v_profile.loyalty_points,
        'lifetime_points', v_profile.lifetime_points,
        'current_tier', v_profile.current_tier,
        'available_coupons', v_coupons
    );
END;
$$;

-- ── create_order ────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.create_order(
    p_idempotency_key TEXT,
    p_session_id      UUID,
    p_items           JSONB,
    p_coupon_id       UUID DEFAULT NULL,
    p_notes           TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid       UUID := auth.uid();
    v_session   public.table_sessions%ROWTYPE;
    v_order     public.orders%ROWTYPE;
    v_existing  public.orders%ROWTYPE;
    v_item      JSONB;
    v_menu      public.menu_items%ROWTYPE;
    v_subtotal  INT := 0;
    v_discount  INT := 0;
    v_total     INT;
    v_coupon    public.coupons%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    SELECT * INTO v_existing FROM public.orders WHERE idempotency_key = p_idempotency_key;
    IF FOUND THEN
        RETURN jsonb_build_object('order_id', v_existing.id, 'status', v_existing.status_v2, 'idempotent', true);
    END IF;

    SELECT * INTO v_session FROM public.table_sessions
    WHERE id = p_session_id AND user_id = v_uid AND status = 'ACTIVE';
    IF NOT FOUND THEN RAISE EXCEPTION 'Invalid or inactive session'; END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        SELECT * INTO v_menu FROM public.menu_items
        WHERE id = (v_item->>'menu_item_id')::UUID AND is_available = true;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Menu item unavailable: %', v_item->>'menu_item_id';
        END IF;
        v_subtotal := v_subtotal + v_menu.price_int * (v_item->>'quantity')::INT;
    END LOOP;

    IF p_coupon_id IS NOT NULL THEN
        SELECT * INTO v_coupon FROM public.coupons WHERE id = p_coupon_id FOR UPDATE;
        IF NOT FOUND OR v_coupon.user_id != v_uid THEN
            RAISE EXCEPTION 'Coupon not found';
        END IF;
        IF v_coupon.status = 'RESERVED'
           AND v_coupon.reserved_by_idempotency_key IS DISTINCT FROM p_idempotency_key THEN
            RAISE EXCEPTION 'Coupon is currently locked by another session.' USING ERRCODE = '23505';
        END IF;
        v_discount := public.calculate_discount(v_subtotal, p_coupon_id);
        UPDATE public.coupons
        SET status = 'RESERVED', reserved_by_idempotency_key = p_idempotency_key
        WHERE id = p_coupon_id;
    END IF;

    v_total := GREATEST(0, v_subtotal - v_discount);

    INSERT INTO public.orders (
        user_id, session_id, table_id, idempotency_key,
        status_v2, coupon_id, subtotal, discount_amount, total_amount,
        total_price, payment_method, payment_status, notes
    ) VALUES (
        v_uid, p_session_id, v_session.table_id, p_idempotency_key,
        'SUBMITTED', p_coupon_id, v_subtotal, v_discount, v_total,
        v_total, 'cash', 'unpaid', p_notes
    )
    RETURNING * INTO v_order;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        SELECT * INTO v_menu FROM public.menu_items WHERE id = (v_item->>'menu_item_id')::UUID;
        INSERT INTO public.order_items (order_id, menu_item_id, name, price, unit_price, quantity)
        VALUES (
            v_order.id, v_menu.id, v_menu.name, v_menu.price_int, v_menu.price_int,
            (v_item->>'quantity')::INT
        );
    END LOOP;

    RETURN jsonb_build_object(
        'order_id', v_order.id,
        'status', v_order.status_v2,
        'total_amount', v_order.total_amount,
        'idempotent', false
    );

EXCEPTION
    WHEN unique_violation THEN
        SELECT * INTO v_existing FROM public.orders WHERE idempotency_key = p_idempotency_key;
        RETURN jsonb_build_object('order_id', v_existing.id, 'status', v_existing.status_v2, 'idempotent', true);
END;
$$;

-- ── cancel_order ────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.cancel_order(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid   UUID := auth.uid();
    v_order public.orders%ROWTYPE;
BEGIN
    SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Order not found'; END IF;
    IF v_order.user_id != v_uid THEN RAISE EXCEPTION 'Forbidden'; END IF;
    IF v_order.status_v2 != 'SUBMITTED' THEN
        RAISE EXCEPTION 'Order cannot be cancelled in status %', v_order.status_v2;
    END IF;

    IF v_order.coupon_id IS NOT NULL THEN
        UPDATE public.coupons
        SET status = 'AVAILABLE', reserved_by_idempotency_key = NULL
        WHERE id = v_order.coupon_id
          AND reserved_by_idempotency_key = v_order.idempotency_key;
    END IF;

    UPDATE public.orders SET status_v2 = 'CANCELLED' WHERE id = p_order_id;
    RETURN jsonb_build_object('order_id', p_order_id, 'status', 'CANCELLED');
END;
$$;

-- ── review_order ────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.review_order(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order public.orders%ROWTYPE;
BEGIN
    IF NOT public.is_cashier() THEN RAISE EXCEPTION 'Cashier role required'; END IF;

    SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Order not found'; END IF;
    IF v_order.status_v2 NOT IN ('SUBMITTED', 'REVIEWING') THEN
        RAISE EXCEPTION 'Order in invalid state';
    END IF;

    UPDATE public.orders
    SET status_v2 = 'REVIEWING', locked_until = now() + interval '2 minutes'
    WHERE id = p_order_id;

    RETURN jsonb_build_object('order_id', p_order_id, 'status', 'REVIEWING');
END;
$$;

-- ── confirm_order ───────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.confirm_order(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_cashier_id  UUID := auth.uid();
    v_order       public.orders%ROWTYPE;
    v_profile     public.profiles%ROWTYPE;
    v_coupon      public.coupons%ROWTYPE;
    v_points      INT;
    v_new_tier    public.tier_name;
    v_milestone   public.coupons;
    v_tier_changed BOOLEAN := false;
    v_old_tier    public.tier_name;
BEGIN
    IF NOT public.is_cashier() THEN RAISE EXCEPTION 'Cashier role required'; END IF;

    SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Order not found'; END IF;
    IF v_order.status_v2 NOT IN ('SUBMITTED', 'REVIEWING') THEN
        RAISE EXCEPTION 'Order in invalid state';
    END IF;

    SELECT * INTO v_profile FROM public.profiles WHERE id = v_order.user_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;

    IF v_order.coupon_id IS NOT NULL THEN
        SELECT * INTO v_coupon FROM public.coupons WHERE id = v_order.coupon_id FOR UPDATE;
        IF v_coupon.reserved_by_idempotency_key IS DISTINCT FROM v_order.idempotency_key THEN
            RAISE EXCEPTION 'Coupon reservation mismatch' USING ERRCODE = '23505';
        END IF;
        UPDATE public.coupons SET status = 'USED' WHERE id = v_order.coupon_id;
    END IF;

    UPDATE public.orders
    SET status_v2 = 'CONFIRMED', cashier_id = v_cashier_id, locked_until = NULL
    WHERE id = p_order_id;

    v_profile.purchase_count := v_profile.purchase_count + 1;
    v_profile.current_stamp_count := v_profile.purchase_count % 10;
    v_points := FLOOR(v_order.total_amount / 1000.0);
    v_profile.loyalty_points := v_profile.loyalty_points + v_points;
    v_profile.lifetime_points := v_profile.lifetime_points + v_points;

    v_old_tier := v_profile.current_tier;
    SELECT tc.tier_name INTO v_new_tier
    FROM public.tier_config tc
    WHERE v_profile.lifetime_points >= tc.threshold
    ORDER BY tc.threshold DESC
    LIMIT 1;
    v_new_tier := COALESCE(v_new_tier, 'BRONZE');
    IF v_new_tier != v_profile.current_tier THEN
        v_tier_changed := true;
        v_profile.current_tier := v_new_tier;
    END IF;

    UPDATE public.profiles SET
        purchase_count = v_profile.purchase_count,
        current_stamp_count = v_profile.current_stamp_count,
        loyalty_points = v_profile.loyalty_points,
        lifetime_points = v_profile.lifetime_points,
        current_tier = v_profile.current_tier
    WHERE id = v_profile.id;

    INSERT INTO public.loyalty_transactions (user_id, order_id, delta, reason)
    VALUES (v_profile.id, p_order_id, v_points, 'PURCHASE');

    IF v_profile.current_stamp_count = 0 THEN
        v_milestone := public.issue_milestone_coupon(v_profile.id);
    END IF;

    RETURN jsonb_build_object(
        'order_id', p_order_id,
        'status', 'CONFIRMED',
        'current_stamp_count', v_profile.current_stamp_count,
        'loyalty_points', v_profile.loyalty_points,
        'tier_upgraded', v_tier_changed,
        'new_tier', CASE WHEN v_tier_changed THEN v_new_tier::text ELSE NULL END,
        'milestone_coupon', CASE WHEN v_profile.current_stamp_count = 0 THEN v_milestone.code ELSE NULL END
    );
END;
$$;

-- ── mark_order_ready ────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.mark_order_ready(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order public.orders%ROWTYPE;
BEGIN
    IF NOT public.is_cashier() THEN RAISE EXCEPTION 'Cashier role required'; END IF;

    SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
    IF v_order.status_v2 != 'CONFIRMED' THEN RAISE EXCEPTION 'Order in invalid state'; END IF;

    UPDATE public.orders SET status_v2 = 'READY' WHERE id = p_order_id;
    RETURN jsonb_build_object('order_id', p_order_id, 'status', 'READY');
END;
$$;

-- ── complete_order ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.complete_order(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order public.orders%ROWTYPE;
BEGIN
    IF NOT public.is_cashier() THEN RAISE EXCEPTION 'Cashier role required'; END IF;

    SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
    IF v_order.status_v2 != 'READY' THEN RAISE EXCEPTION 'Order in invalid state'; END IF;

    UPDATE public.orders SET status_v2 = 'COMPLETED' WHERE id = p_order_id;
    RETURN jsonb_build_object('order_id', p_order_id, 'status', 'COMPLETED');
END;
$$;

-- ── Cron helpers ────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.release_stale_review_locks()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE public.orders
    SET status_v2 = 'SUBMITTED', locked_until = NULL
    WHERE status_v2 = 'REVIEWING' AND locked_until < now();
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.expire_stale_orders()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order public.orders%ROWTYPE;
    v_count INT := 0;
BEGIN
    FOR v_order IN
        SELECT * FROM public.orders
        WHERE status_v2 = 'SUBMITTED'
          AND updated_at < now() - interval '30 minutes'
        FOR UPDATE SKIP LOCKED
    LOOP
        IF v_order.coupon_id IS NOT NULL THEN
            UPDATE public.coupons
            SET status = 'AVAILABLE', reserved_by_idempotency_key = NULL
            WHERE id = v_order.coupon_id
              AND reserved_by_idempotency_key = v_order.idempotency_key;
        END IF;
        UPDATE public.orders SET status_v2 = 'EXPIRED' WHERE id = v_order.id;
        v_count := v_count + 1;
    END LOOP;
    RETURN v_count;
END;
$$;

-- ── update_fcm_token ────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.update_fcm_token(p_token TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
    UPDATE public.profiles SET fcm_token = p_token WHERE id = auth.uid();
END;
$$;

-- ── set_menu_availability (cashier) ─────────────────────────

CREATE OR REPLACE FUNCTION public.set_menu_availability(p_menu_item_id UUID, p_available BOOLEAN)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT public.is_cashier() THEN RAISE EXCEPTION 'Cashier role required'; END IF;
    UPDATE public.menu_items SET is_available = p_available WHERE id = p_menu_item_id;
END;
$$;

-- Grants
GRANT EXECUTE ON FUNCTION public.create_session(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_table_by_qr(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.validate_coupon(TEXT, INT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_wallet() TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_order(TEXT, UUID, JSONB, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_order(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.review_order(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_order(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_order_ready(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_order(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_fcm_token(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_menu_availability(UUID, BOOLEAN) TO authenticated;
