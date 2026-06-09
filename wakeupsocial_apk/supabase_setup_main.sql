-- ============================================================
-- WakeUpSocial - Supabase Database Setup
-- Jalankan file ini di: Supabase Dashboard > SQL Editor > Run
-- ============================================================

-- ============================================================
-- STEP 1: ENUM TYPES
-- ============================================================

CREATE TYPE public.order_status AS ENUM (
    'pending',
    'processing',
    'ready',
    'delivered',
    'cancelled'
);

CREATE TYPE public.payment_method AS ENUM (
    'cash',
    'transfer'
);

CREATE TYPE public.payment_status AS ENUM (
    'unpaid',
    'paid'
);

-- ============================================================
-- STEP 2: TABLES
-- ============================================================

-- 2a. Profiles (extends auth.users 1:1)
CREATE TABLE public.profiles (
    id          UUID        NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name        TEXT        NOT NULL,
    phone       TEXT,
    avatar_url  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE public.profiles IS 'Stores public profile data for each authenticated user.';

-- 2b. Menu Categories
CREATE TABLE public.menu_categories (
    id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name        TEXT        NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE public.menu_categories IS 'Categories for menu items (e.g., Food, Drinks).';

-- 2c. Menu Items
CREATE TABLE public.menu_items (
    id           UUID           NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    category_id  UUID           REFERENCES public.menu_categories(id) ON DELETE SET NULL,
    name         TEXT           NOT NULL,
    description  TEXT,
    price        NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    image_url    TEXT,
    is_available BOOLEAN        NOT NULL DEFAULT true,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT now()
);
COMMENT ON TABLE public.menu_items IS 'Catalog of food and drink items.';

-- 2d. Orders
CREATE TABLE public.orders (
    id             UUID                    NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id        UUID                    REFERENCES auth.users(id) ON DELETE SET NULL,
    status         public.order_status     NOT NULL DEFAULT 'pending',
    payment_method public.payment_method   NOT NULL,
    payment_status public.payment_status   NOT NULL DEFAULT 'unpaid',
    total_price    NUMERIC(10, 2)          NOT NULL CHECK (total_price >= 0),
    notes          TEXT,
    table_number   TEXT,                   -- For dine-in
    created_at     TIMESTAMPTZ             NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ             NOT NULL DEFAULT now()
);
COMMENT ON TABLE public.orders IS 'Customer orders (dine-in model).';

-- 2e. Order Items (detail per pesanan)
CREATE TABLE public.order_items (
    id           UUID           NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id     UUID           NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    menu_item_id UUID           REFERENCES public.menu_items(id) ON DELETE SET NULL,
    name         TEXT           NOT NULL,  -- snapshot nama saat order dibuat
    price        NUMERIC(10, 2) NOT NULL,  -- snapshot harga saat order dibuat
    quantity     INT            NOT NULL CHECK (quantity > 0),
    subtotal     NUMERIC(10, 2) GENERATED ALWAYS AS (price * quantity) STORED
);
COMMENT ON TABLE public.order_items IS 'Line items for each order (price/name snapshotted at time of order).';

-- ============================================================
-- STEP 3: INDEXES (for query performance)
-- ============================================================

CREATE INDEX idx_menu_items_category ON public.menu_items (category_id);
CREATE INDEX idx_menu_items_available ON public.menu_items (is_available);
CREATE INDEX idx_orders_user_id ON public.orders (user_id);
CREATE INDEX idx_orders_status ON public.orders (status);
CREATE INDEX idx_order_items_order_id ON public.order_items (order_id);

-- ============================================================
-- STEP 4: TRIGGERS
-- ============================================================

-- Helper function: otomatis update kolom updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

-- Trigger: update updated_at pada profiles
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger: update updated_at pada menu_items
CREATE TRIGGER set_menu_items_updated_at
    BEFORE UPDATE ON public.menu_items
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger: update updated_at pada orders
CREATE TRIGGER set_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-create profile saat user baru mendaftar (via Auth)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, name, phone, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'phone',
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- STEP 5: ROW LEVEL SECURITY (RLS)
-- ============================================================

-- --- profiles ---
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Admin web (via service_role) bisa baca semua
CREATE POLICY "Service role can read all profiles"
    ON public.profiles FOR SELECT
    TO service_role
    USING (true);

-- --- menu_categories ---
ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;

-- Semua orang (termasuk anon/tamu) bisa membaca kategori
CREATE POLICY "Anyone can view categories"
    ON public.menu_categories FOR SELECT
    TO public
    USING (true);

-- Hanya service_role (admin web) yang bisa mengubah
CREATE POLICY "Service role full access on categories"
    ON public.menu_categories FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- --- menu_items ---
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;

-- User app hanya melihat menu yang tersedia
CREATE POLICY "Anyone can view available menu items"
    ON public.menu_items FOR SELECT
    TO public
    USING (is_available = true);

-- Service_role (admin web) bisa baca semua (termasuk yang sold out) dan edit
CREATE POLICY "Service role full access on menu_items"
    ON public.menu_items FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- --- orders ---
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- User hanya bisa melihat order miliknya sendiri
CREATE POLICY "Users can view their own orders"
    ON public.orders FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- User bisa membuat order baru atas nama dirinya sendiri
CREATE POLICY "Users can create their own orders"
    ON public.orders FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Service_role (admin web) bisa akses dan update semua order (untuk ubah status)
CREATE POLICY "Service role full access on orders"
    ON public.orders FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- --- order_items ---
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- User hanya bisa melihat item dari order miliknya
CREATE POLICY "Users can view their own order items"
    ON public.order_items FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- User bisa menambah item saat membuat order
CREATE POLICY "Users can insert items for their own orders"
    ON public.order_items FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Service_role full access
CREATE POLICY "Service role full access on order_items"
    ON public.order_items FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================
-- STEP 6: SEED DATA (Contoh data awal untuk testing)
-- ============================================================

-- Insert Kategori Menu
INSERT INTO public.menu_categories (id, name, description) VALUES
    ('11111111-0000-0000-0000-000000000001', 'Makanan', 'Hidangan utama dan makanan berat'),
    ('11111111-0000-0000-0000-000000000002', 'Minuman', 'Minuman segar dan hangat'),
    ('11111111-0000-0000-0000-000000000003', 'Snack', 'Cemilan dan makanan ringan');

-- Insert Menu Items (contoh)
INSERT INTO public.menu_items (name, description, price, image_url, category_id, is_available) VALUES
    ('Nasi Goreng Spesial', 'Nasi goreng dengan telur, ayam, dan sayuran segar', 25000, null, '11111111-0000-0000-0000-000000000001', true),
    ('Mie Goreng Jumbo', 'Mie goreng porsi besar dengan topping lengkap', 22000, null, '11111111-0000-0000-0000-000000000001', true),
    ('Ayam Bakar', 'Ayam bakar bumbu kecap dengan lalapan segar', 35000, null, '11111111-0000-0000-0000-000000000001', true),
    ('Es Teh Manis', 'Teh manis dingin yang menyegarkan', 8000, null, '11111111-0000-0000-0000-000000000002', true),
    ('Jus Alpukat', 'Jus alpukat segar dengan susu', 18000, null, '11111111-0000-0000-0000-000000000002', true),
    ('Kopi Susu', 'Kopi susu ala kafe dengan biji kopi pilihan', 20000, null, '11111111-0000-0000-0000-000000000002', true),
    ('Es Jeruk', 'Jeruk peras segar, manis dan menyegarkan', 12000, null, '11111111-0000-0000-0000-000000000002', true),
    ('Kentang Goreng', 'Kentang goreng crispy dengan saus pilihan', 15000, null, '11111111-0000-0000-0000-000000000003', true),
    ('Pisang Goreng Crispy', 'Pisang goreng renyah dengan taburan coklat atau keju', 12000, null, '11111111-0000-0000-0000-000000000003', true);
