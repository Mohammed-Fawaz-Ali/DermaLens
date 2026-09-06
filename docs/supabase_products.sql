create table if not exists public.products (
  id text primary key,
  name text not null,
  description text not null default '',
  price numeric(10, 2) not null check (price >= 0),
  category text not null,
  diseases jsonb not null default '[]'::jsonb,
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.products enable row level security;

drop policy if exists "Anyone can read active products" on public.products;
drop policy if exists "Anyone can read products" on public.products;

create policy "Anyone can read products"
on public.products for select
using (true);

insert into public.products (id, name, description, price, category, diseases, image_url)
values
('p1', 'Gentle Cleanser', 'A gentle, non-irritating cleanser suitable for sensitive skin.', 262.99, 'Cleansers', '["Acne", "Eczema", "Rosacea"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/gentle_cleanser.jpg'),
('p2', 'Moisturizing Lotion', 'Hydrating lotion with ceramides to restore skin barrier.', 265.99, 'Moisturizers', '["Eczema", "Psoriasis", "Vitiligo"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/moisturizing_lotion.jpg'),
('p3', 'Acne Treatment Gel', 'Benzoyl peroxide gel for treating acne breakouts.', 268.99, 'Treatments', '["Acne"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/acne_treatment_gel.jpg'),
('p4', 'Antifungal Cream', 'Clotrimazole cream for treating fungal skin infections.', 263.99, 'Antifungals', '["Tinea", "Candidiasis"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/antifungal_cream.jpg'),
('p5', 'Sunscreen SPF 50', 'Broad-spectrum sunscreen to protect against UV damage.', 266.99, 'Sun care', '["Sun_Sunlight_Damage", "Actinic_Keratosis"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/sunscreen_spf50.jpg'),
('p6', 'Soothing Aloe Gel', 'Pure aloe vera gel to soothe irritated skin.', 261.99, 'Soothing', '["Eczema", "Psoriasis", "Sun_Sunlight_Damage"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/soothing_aloe_gel.jpg'),
('p7', 'Vitamin C Serum', 'Antioxidant serum to brighten and even skin tone.', 272.99, 'Serums', '["Sun_Sunlight_Damage", "Vitiligo"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/vitamin_c_serum.jpg'),
('p8', 'Calamine Lotion', 'Calamine lotion for relieving itching and irritation.', 259.99, 'Treatments', '["Chickenpox", "Poison Ivy", "Insect Bites"]', 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product-images/calamine_lotion.jpg')
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  category = excluded.category,
  diseases = excluded.diseases,
  image_url = excluded.image_url,
  is_active = excluded.is_active,
  updated_at = now();