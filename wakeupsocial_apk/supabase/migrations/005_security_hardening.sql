-- ============================================================
-- Security hardening: profile privilege escalation + guest orders
-- ============================================================

-- Prevent authenticated users from self-modifying privileged profile columns.
CREATE OR REPLACE FUNCTION public.protect_profile_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF COALESCE(
    current_setting('request.jwt.claims', true)::json->>'role',
    ''
  ) = 'service_role' THEN
    RETURN NEW;
  END IF;

  NEW.role := OLD.role;
  NEW.loyalty_points := OLD.loyalty_points;
  NEW.lifetime_points := OLD.lifetime_points;
  NEW.current_tier := OLD.current_tier;
  NEW.purchase_count := OLD.purchase_count;
  NEW.current_stamp_count := OLD.current_stamp_count;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_profile_columns ON public.profiles;
CREATE TRIGGER protect_profile_columns
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_profile_privileged_columns();

-- Replace broad anon SELECT with RPC-gated guest order lookup.
DROP POLICY IF EXISTS "Anonymous users can view orders" ON public.orders;

CREATE OR REPLACE FUNCTION public.get_public_order(p_order_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT to_jsonb(o.*) || jsonb_build_object(
    'order_items', COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(oi.*) ORDER BY oi.created_at)
        FROM public.order_items oi
        WHERE oi.order_id = o.id
      ),
      '[]'::jsonb
    )
  )
  INTO result
  FROM public.orders o
  WHERE o.id = p_order_id
    AND o.user_id IS NULL;

  IF result IS NULL THEN
    RAISE EXCEPTION 'Order not found or not accessible';
  END IF;

  RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_public_order(UUID) TO anon, authenticated;
