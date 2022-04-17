-- STORAGE
create policy "Restricted Access"
    on storage.objects for select
    using (
            bucket_id = 'sneaker'
        and auth.role() = 'authenticated'
    );

-- TODO: ADD RLS POLICIES

-- COMPANY_USER
alter table public.company_user enable row level security;

-- PERSONAL_USER
alter table public.personal_user enable row level security;

-- PRODUCT_SOURCE
alter table public.product_source enable row level security;

-- PRODUCT_BARCODE
alter table public.product_barcode enable row level security;

-- PRODUCT_SKU
alter table public.product_sku enable row level security;

-- COMPANY
alter table public.company enable row level security;

-- COMPANY_STAFF
alter table public.company_staff enable row level security;