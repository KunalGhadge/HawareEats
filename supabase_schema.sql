-- ==============================================================================
-- HAWAREEATS PRODUCTION SUPABASE DATABASE SCHEMA
-- Execute this script in your Supabase SQL Editor:
-- (Supabase Dashboard -> Project -> SQL Editor -> New Query -> Paste & Click Run)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUMS
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('customer', 'restaurantOwner', 'driver', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('placed', 'confirmed', 'preparing', 'readyForPickup', 'onTheWay', 'delivered', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. PROFILES TABLE (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT NOT NULL DEFAULT '',
    nickname TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    avatar_url TEXT DEFAULT 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
    date_of_birth DATE DEFAULT '1998-01-01',
    gender TEXT DEFAULT 'Male',
    wallet_balance NUMERIC(10,2) DEFAULT 25.00,
    loyalty_points INT DEFAULT 100,
    is_vip BOOLEAN DEFAULT TRUE,
    role user_role DEFAULT 'customer',
    security_pin TEXT DEFAULT '1234',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. FOOD CATEGORIES
CREATE TABLE IF NOT EXISTS public.categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    icon_emoji TEXT NOT NULL,
    image_url TEXT NOT NULL,
    item_count INT DEFAULT 24,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. RESTAURANTS TABLE
CREATE TABLE IF NOT EXISTS public.restaurants (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    merchant_code TEXT UNIQUE,
    kitchen_pin TEXT DEFAULT '5555',
    logo_url TEXT NOT NULL,
    banner_url TEXT NOT NULL,
    description TEXT DEFAULT '',
    cuisines TEXT[] NOT NULL DEFAULT '{}',
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION DEFAULT 19.0335,
    longitude DOUBLE PRECISION DEFAULT 73.0295,
    rating NUMERIC(2,1) DEFAULT 4.8,
    review_count INT DEFAULT 120,
    price_tier TEXT DEFAULT '$$',
    avg_prep_time_minutes INT DEFAULT 20,
    delivery_fee NUMERIC(5,2) DEFAULT 2.49,
    min_order_amount NUMERIC(6,2) DEFAULT 10.00,
    is_open BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    discount_tag TEXT DEFAULT 'Free Delivery',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. MENU ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.menu_items (
    id TEXT PRIMARY KEY,
    restaurant_id TEXT REFERENCES public.restaurants(id) ON DELETE CASCADE,
    category_id TEXT REFERENCES public.categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    image_url TEXT NOT NULL,
    base_price NUMERIC(6,2) NOT NULL,
    discounted_price NUMERIC(6,2),
    calories INT DEFAULT 450,
    prep_time_minutes INT DEFAULT 15,
    is_veg BOOLEAN DEFAULT FALSE,
    is_bestseller BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    rating NUMERIC(2,1) DEFAULT 4.8,
    ingredients TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. CUSTOMIZER GROUPS & OPTIONS
CREATE TABLE IF NOT EXISTS public.customizer_groups (
    id TEXT PRIMARY KEY,
    menu_item_id TEXT REFERENCES public.menu_items(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    min_selection INT DEFAULT 0,
    max_selection INT DEFAULT 1,
    is_required BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS public.customizer_options (
    id TEXT PRIMARY KEY,
    group_id TEXT REFERENCES public.customizer_groups(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    price_delta NUMERIC(5,2) DEFAULT 0.00,
    is_default BOOLEAN DEFAULT FALSE
);

-- 8. USER DELIVERY ADDRESSES
CREATE TABLE IF NOT EXISTS public.delivery_addresses (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    label TEXT NOT NULL, -- Home, Work, Apartment, Parents, Other
    full_address TEXT NOT NULL,
    apartment_suite TEXT DEFAULT '',
    landmark TEXT DEFAULT '',
    latitude DOUBLE PRECISION DEFAULT 19.0335,
    longitude DOUBLE PRECISION DEFAULT 73.0295,
    is_default BOOLEAN DEFAULT FALSE,
    delivery_notes TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. DELIVERY DRIVERS TABLE
CREATE TABLE IF NOT EXISTS public.drivers (
    id TEXT PRIMARY KEY, -- e.g. HERO01, HERO02
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    driver_pin TEXT DEFAULT '7777',
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    avatar_url TEXT NOT NULL,
    vehicle_type TEXT DEFAULT 'Motorcycle',
    vehicle_model TEXT NOT NULL,
    license_plate TEXT NOT NULL,
    rating NUMERIC(2,1) DEFAULT 4.9,
    total_trips INT DEFAULT 0,
    total_deliveries INT DEFAULT 0,
    current_latitude DOUBLE PRECISION DEFAULT 19.0330,
    current_longitude DOUBLE PRECISION DEFAULT 73.0290,
    is_online BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.orders (
    id TEXT PRIMARY KEY,
    order_number TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    restaurant_id TEXT REFERENCES public.restaurants(id) ON DELETE SET NULL,
    driver_id TEXT REFERENCES public.drivers(id) ON DELETE SET NULL,
    delivery_address JSONB NOT NULL,
    status order_status DEFAULT 'placed',
    payment_method TEXT NOT NULL,
    subtotal NUMERIC(7,2) NOT NULL,
    delivery_fee NUMERIC(5,2) DEFAULT 0.00,
    service_fee NUMERIC(5,2) DEFAULT 1.50,
    discount_amount NUMERIC(6,2) DEFAULT 0.00,
    driver_tip NUMERIC(5,2) DEFAULT 0.00,
    total_amount NUMERIC(7,2) NOT NULL,
    promo_code TEXT DEFAULT '',
    items JSONB NOT NULL,
    cancellation_reason TEXT,
    estimated_delivery_time TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. PROMOTIONS & VOUCHERS
CREATE TABLE IF NOT EXISTS public.promotions_vouchers (
    id TEXT PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    discount_percent NUMERIC(4,1) NOT NULL,
    max_discount NUMERIC(6,2),
    min_order NUMERIC(6,2) DEFAULT 15.00,
    expiry_date TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. PARTNER APPLICATIONS (Merchant & Driver Onboarding)
CREATE TABLE IF NOT EXISTS public.partner_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_type TEXT NOT NULL, -- 'restaurant' or 'driver'
    business_name TEXT,
    applicant_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    address TEXT,
    vehicle_model TEXT,
    license_number TEXT,
    status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. CHAT MESSAGES
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id TEXT REFERENCES public.orders(id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    sender_role TEXT NOT NULL, -- 'user', 'driver', 'restaurant', 'support'
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- AUTOMATIC PROFILE CREATION TRIGGER ON AUTH SIGNUP
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, phone, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'phone', ''),
        'customer'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customizer_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customizer_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions_vouchers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Public Read Policies (Allow Customers to Browse Food Catalog)
CREATE POLICY "Public Read Categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Public Read Restaurants" ON public.restaurants FOR SELECT USING (true);
CREATE POLICY "Public Read Menu Items" ON public.menu_items FOR SELECT USING (true);
CREATE POLICY "Public Read Customizers" ON public.customizer_groups FOR SELECT USING (true);
CREATE POLICY "Public Read Customizer Options" ON public.customizer_options FOR SELECT USING (true);
CREATE POLICY "Public Read Vouchers" ON public.promotions_vouchers FOR SELECT USING (true);
CREATE POLICY "Public Read Drivers" ON public.drivers FOR SELECT USING (true);

-- User-scoped Policies
CREATE POLICY "Users Can Read/Update Own Profile" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users Can Manage Own Addresses" ON public.delivery_addresses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users Can Manage Own Orders" ON public.orders FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users Can Send Partner Applications" ON public.partner_applications FOR INSERT WITH CHECK (true);
CREATE POLICY "Users Can Read/Send Chat Messages" ON public.chat_messages FOR ALL USING (true);

-- ==============================================================================
-- SEED DATA (INITIAL CATEGORIES, RESTAURANTS & PROMOTIONS)
-- ==============================================================================

-- Categories
INSERT INTO public.categories (id, name, slug, icon_emoji, image_url, item_count) VALUES
('cat_burger', 'Burgers', 'burgers', '🍔', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', 36),
('cat_pizza', 'Pizza', 'pizza', '🍕', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400', 28),
('cat_asian', 'Asian Bowls', 'asian-bowls', '🍜', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400', 42),
('cat_dessert', 'Desserts', 'desserts', '🍰', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400', 19),
('cat_drink', 'Drinks', 'drinks', '🥤', 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400', 30),
('cat_mexican', 'Mexican', 'mexican', '🌮', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400', 22)
ON CONFLICT (id) DO NOTHING;

-- Restaurants
INSERT INTO public.restaurants (id, name, slug, merchant_code, kitchen_pin, logo_url, banner_url, description, cuisines, address, latitude, longitude, rating, review_count, price_tier, avg_prep_time_minutes, delivery_fee, min_order_amount, is_open, is_featured, discount_tag) VALUES
('resto_1', 'Haware Gourmet Burger Lab', 'haware-burger-lab', 'RESTO101', '5555', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800', 'Artisanal brioche smash burgers and loaded truffle fries.', ARRAY['Gourmet Burgers', 'American', 'Fast Food'], 'Shop 4, Haware Grand Heritage, Sector 21', 19.0335, 73.0295, 4.9, 382, '$$', 15, 1.99, 10.00, true, true, '30% OFF (HAWARE30)'),
('resto_2', 'Woodfire Napoli Pizzeria', 'woodfire-napoli', 'RESTO102', '6666', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800', 'Authentic Neapolitan sourdough pizzas baked in 450°C stone oven.', ARRAY['Authentic Italian', 'Woodfire Pizza', 'Pasta'], 'Haware Centurion Mall, Sector 19', 19.0340, 73.0305, 4.8, 294, '$$', 20, 2.49, 12.00, true, true, 'Free Delivery'),
('resto_3', 'Tokyo Ramen & Sushi Bar', 'tokyo-ramen-sushi', 'RESTO103', '7777', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400', 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800', '18-hour slow-cooked tonkotsu ramen and fresh sashimi rolls.', ARRAY['Japanese', 'Sushi', 'Ramen & Bowls'], 'Sector 15, Kharghar Food Street', 19.0320, 73.0280, 4.9, 512, '$$$', 25, 2.99, 15.00, true, false, 'Chef Special')
ON CONFLICT (id) DO NOTHING;

-- Drivers
INSERT INTO public.drivers (id, driver_pin, name, phone, avatar_url, vehicle_type, vehicle_model, license_plate, rating, total_trips, total_deliveries, current_latitude, current_longitude, is_online) VALUES
('HERO01', '7777', 'Rahul Sharma', '+91 98201 11223', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'Motorcycle', 'Honda Activa 6G (Black)', 'MH-43-AK-9821', 4.9, 342, 342, 19.0330, 73.0290, true),
('HERO02', '8888', 'Vikram Singh', '+91 98202 33445', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', 'Motorcycle', 'TVS Jupiter (Grey)', 'MH-43-BM-4412', 4.8, 189, 189, 19.0345, 73.0310, true)
ON CONFLICT (id) DO NOTHING;

-- Promotions & Vouchers
INSERT INTO public.promotions_vouchers (id, code, title, description, discount_percent, max_discount, min_order, expiry_date, is_active) VALUES
('v_haware30', 'HAWARE30', '30% OFF Welcome Bonus', 'Enjoy 30% discount on all gourmet dishes.', 30.0, 10.00, 15.00, '31 Dec 2026', true),
('v_freeship', 'FREESHIP', 'Zero Delivery Fees', 'Free delivery on all orders over $15.', 100.0, 5.00, 15.00, '31 Dec 2026', true)
ON CONFLICT (id) DO NOTHING;
