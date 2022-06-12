-- ROW LEVEL SECURITY

--------------------------------------------------------------------------------------

-- STORAGE POLICY
create policy "Restricted Access"
    on storage.objects for select
    using (
            bucket_id = 'sneaker'
        and auth.role() = 'authenticated'
    );

--------------------------------------------------------------------------------------

-- COMPANY
alter table public.company
    enable row level security;

create policy "Enable select for company staff"
    on public.company
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

create policy "Enable insert for public"
    on public.company
    for insert with check (true);

--------------------------------------------------------------------------------------

-- COMPANY INVENTORY
alter table public.company_inventory
    enable row level security;

create policy "Enable select for company staff"
    on public.company_inventory
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

create policy "Enable insert for company editors"
    on public.company_inventory
    for insert with check (auth.uid() in (select get_company_editors
                                          from get_company_editors(company_id)));

create policy "Enable delete for company editors"
    on public.company_inventory
    for delete using (auth.uid() in (select get_company_editors
                                     from get_company_editors(company_id)));

--------------------------------------------------------------------------------------

-- COMPANY INVENTORY ITEM
alter table public.company_inventory_item
    enable row level security;

create policy "Enable select for company staff"
    on public.company_inventory_item
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

create policy "Enable insert for company editors"
    on public.company_inventory_item
    for insert with check (auth.uid() in (select get_company_editors
                                          from get_company_editors(company_id)));

create policy "Enable delete for company editors"
    on public.company_inventory_item
    for delete using (auth.uid() in (select get_company_editors
                                     from get_company_editors(company_id)));

--------------------------------------------------------------------------------------

-- COMPANY INVITE
alter table public.company_invite
    enable row level security;

create policy "Enable select for company staff"
    on public.company_invite
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

create policy "Enable insert for company admins"
    on public.company_invite
    for insert with check (auth.uid() in (select get_company_admins
                                          from get_company_admins(company_id)));

create policy "Enable delete for company admins"
    on public.company_invite
    for delete using (auth.uid() in (select get_company_admins
                                     from get_company_admins(company_id)));

--------------------------------------------------------------------------------------

-- COMPANY STAFF
alter table public.company_staff
    enable row level security;

create policy "Enable select for company staff"
    on public.company_staff
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

create policy "Enable insert for company admins"
    on public.company_staff
    for insert with check (auth.uid() in (select get_company_admins
                                          from get_company_admins(company_id)));

create policy "Enable delete for company admins"
    on public.company_staff
    for delete using (auth.uid() in (select get_company_admins
                                     from get_company_admins(company_id)));

--------------------------------------------------------------------------------------

-- COMPANY SUBSCRIPTIONS
alter table public.company_subscription
    enable row level security;

create policy "Enable select for company staff"
    on public.company_subscription
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

--------------------------------------------------------------------------------------

-- COMPANY USAGE
alter table public.company_usage
    enable row level security;

create policy "Enable select for company staff"
    on public.company_usage
    for select using (auth.uid() in (select get_company_staff
                                     from get_company_staff(company_id)));

create policy "Enable insert for company admins"
    on public.company_usage
    for insert with check (auth.uid() in (select get_company_editors
                                          from get_company_editors(company_id)));

--------------------------------------------------------------------------------------

-- COMPANY USER
alter table public.company_user
    enable row level security;

create policy "Enable select for authenticated users"
    on public.company_user
    for select using (auth.role() = 'authenticated');

-- TODO: UPDATE POLICY TO ONLY SELECT COMPANY_USER IN THE INVOKERS COMPANY

--------------------------------------------------------------------------------------

-- PERSONAL INVENTORY
alter table public.personal_inventory
    enable row level security;

create policy "Enable select for self"
    on public.personal_inventory
    for select using (auth.uid() = user_id);

create policy "Enable insert for self"
    on public.personal_inventory
    for insert with check (auth.uid() = user_id);

create policy "Enable delete for self"
    on public.personal_inventory
    for delete using (auth.uid() = user_id);

--------------------------------------------------------------------------------------

-- PERSONAL INVENTORY ITEM

alter table public.personal_inventory_item
    enable row level security;

create policy "Enable select for self"
    on public.personal_inventory_item
    for select using (auth.uid() = user_id);

create policy "Enable insert for self"
    on public.personal_inventory_item
    for insert with check (auth.uid() = user_id);

create policy "Enable delete for self"
    on public.personal_inventory_item
    for delete using (auth.uid() = user_id);

--------------------------------------------------------------------------------------

-- PERSONAL SUBSCRIPTION
alter table public.personal_subscription
    enable row level security;

create policy "Enable select self"
    on public.personal_subscription
    for select using (auth.uid() = user_id);

--------------------------------------------------------------------------------------

-- PERSONAL USAGE
alter table public.personal_usage
    enable row level security;

create policy "Enable select for self"
    on public.personal_usage
    for select using (auth.uid() = user_id);

create policy "Enable insert for self"
    on public.personal_usage
    for insert with check (auth.uid() = user_id);

--------------------------------------------------------------------------------------

-- PERSONAL USER
alter table public.personal_user
    enable row level security;

create policy "Enable select for company staff"
    on public.personal_user
    for select using (auth.uid() = id);

--------------------------------------------------------------------------------------

-- PERSONAL BARCODE
alter table public.product_barcode
    enable row level security;

create policy "Enable select for authenticated users"
    on public.product_barcode
    for select using (auth.role() = 'authenticated');

create policy "Enable insert for authenticated users"
    on public.product_barcode
    for insert with check (auth.role() = 'authenticated');

--------------------------------------------------------------------------------------

-- PRODUCT SKU
alter table public.product_sku
    enable row level security;

create policy "Enable select for authenticated users"
    on public.product_sku
    for select using (auth.role() = 'authenticated');

create policy "Enable insert for authenticated users"
    on public.product_sku
    for insert with check (auth.role() = 'authenticated');

--------------------------------------------------------------------------------------

-- PRODUCT SOURCE
alter table public.product_source
    enable row level security;

--------------------------------------------------------------------------------------

-- STRIPE_PRODUCT
alter table public.stripe_product
    enable row level security;

create policy "Enable select for public"
    on public.stripe_product
    for select using (true);

--------------------------------------------------------------------------------------

-- STRIPE_PRICE
alter table public.stripe_price
    enable row level security;

create policy "Enable select for public"
    on public.stripe_price
    for select using (true);

--------------------------------------------------------------------------------------

-- COMPANY_INVOICE
alter table public.company_invoice
    enable row level security;

create policy "Enable select for company admins"
    on public.company_invoice
    for select using (auth.uid() in (select get_company_admins
                                     from get_company_admins(company_id)));

--------------------------------------------------------------------------------------

-- PERSONAL_INVOICE
alter table public.personal_invoice
    enable row level security;

create policy "Enable select for self"
    on public.personal_invoice
    for select using (auth.uid() = user_id);

--------------------------------------------------------------------------------------

-- RESTOCK_SKU
alter table public.restock_sku
    enable row level security;