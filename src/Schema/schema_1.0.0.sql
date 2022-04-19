-- CREATE STORAGE BUCKETS
insert into storage.buckets (id, name)
values ('sneaker', 'sneaker');

-- CREATE COMPANY USER TABLE
create table public.company_user
(
    id         uuid references auth.users not null,
    email      varchar                    not null,
    first_name varchar                    not null,
    last_name  varchar                    not null,
    primary key (id)
);

-- CREATE PERSONAL USER TABLE
create table public.personal_user
(
    id    uuid references auth.users not null,
    phone varchar                    not null,
    primary key (id)
);

-- CREATE PRODUCT_SOURCE TABLE
create table public.product_source
(
    source_id  uuid        not null default uuid_generate_v4(),
    name       varchar     not null,
    created_at timestamptz not null default now(),
    primary key (source_id)
);

-- CREATE PRODUCT BARCODE TABLE
create table public.product_barcode
(
    barcode     varchar     not null,
    verified    bool        not null default false,
    sku         varchar     not null,
    size        varchar     not null,
    size_region varchar     not null,
    created_at  timestamptz not null default now(),
    source_id   uuid,

    constraint fk_product_source foreign key (source_id) references public.product_source (source_id),
    primary key (barcode)
);

-- CREATE PRODUCT SKU TABLE
create table public.product_sku
(
    sku          varchar     not null,
    name         varchar     not null,
    style        varchar     not null,
    gender       varchar     not null check (gender = 'men' or gender = 'women' or gender = 'kids'),
    brand        varchar     not null,
    nickname     varchar     not null default '',
    release_date timestamptz,
    image_url    varchar     not null,
    created_at   timestamptz not null default now(),
    verified     boolean     not null default false,
    source_id    uuid        not null,

    constraint fk_product_source foreign key (source_id) references public.product_source (source_id),
    primary key (sku)
);

-- CREATE COMPANY TABLE
create table public.company
(
    company_id          uuid        not null default uuid_generate_v4(),
    company_email       varchar     not null,
    company_name        varchar     not null,
    address_line1       varchar     not null,
    address_line2       varchar,
    address_postal_code varchar,
    address_city        varchar     not null,
    address_country     varchar     not null,
    created_at          timestamptz not null default now(),
    stripe_id           varchar,
    svix_app_id         varchar,
    primary key (company_id)
);

-- CREATE COMPANY INVITE TABLE
create table public.company_invite
(
    id           uuid    not null default uuid_generate_v4(),
    company_id   uuid    not null,
    invite_token varchar not null,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (id)
);

-- CREATE COMPANY STAFF TABLE
create table public.company_staff
(
    id         uuid    not null default uuid_generate_v4(),
    user_id    uuid    not null unique,
    role       varchar not null check (role = 'super_admin' or role = 'admin' or role = 'write' or role = 'read'),
    company_id uuid    not null,

    constraint fk_company_user foreign key (user_id) references public.company_user (id),
    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (id)
);

-- CREATE COMPANY INVENTORY TABLE
create table public.company_inventory
(
    batch_id   uuid        not null default uuid_generate_v4(),
    user_id    uuid        not null,
    company_id uuid        not null,
    created_at timestamptz not null default now(),
    nano_id    varchar     not null,

    constraint fk_company_user foreign key (user_id) references public.company_user (id),
    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (batch_id)
);

-- TODO: Move to different file
-- USED FOR WEBHOOKS
alter table "company_inventory"
    replica identity full;

-- CREATE COMPANY INVENTORY ITEM TABLE
create table public.company_inventory_item
(
    inventory_id uuid    not null default uuid_generate_v4(),
    batch_id     uuid    not null,
    company_id   uuid    not null,
    barcode      varchar not null,
    nano_id      varchar not null,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    constraint fk_company_inventory foreign key (batch_id) references public.company_inventory (batch_id) on delete cascade,
    primary key (inventory_id)
);

-- CREATE PERSONAL INVENTORY TABLE
create table public.personal_inventory
(
    batch_id   uuid        not null default uuid_generate_v4(),
    user_id    uuid        not null,
    created_at timestamptz not null default now(),
    nano_id    varchar     not null,

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),
    primary key (batch_id)
);

-- CREATE COMPANY INVENTORY ITEM TABLE
create table public.personal_inventory_item
(
    inventory_id uuid    not null default uuid_generate_v4(),
    user_id      uuid    not null,
    batch_id     uuid    not null,
    barcode      varchar not null,
    nano_id      varchar not null,

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),
    constraint fk_personal_inventory foreign key (batch_id) references public.personal_inventory (batch_id) on delete cascade,
    primary key (inventory_id)
);

-- CREATE COMPANY USAGE TABLE
create table public.company_usage
(
    id         uuid        not null default uuid_generate_v4(),
    user_id    uuid        not null,
    company_id uuid        not null,
    created_at timestamptz not null default now(),

    constraint fk_company_user foreign key (user_id) references public.company_user (id),
    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (id)
);

-- CREATE PERSONAL USAGE TABLE
create table public.personal_usage
(
    id         uuid        not null default uuid_generate_v4(),
    user_id    uuid        not null,
    created_at timestamptz not null default now(),

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),
    primary key (id)
);

-- CREATE COMPANY SUBSCRIPTION TABLE
create table public.company_subscription
(
    id                   uuid not null default uuid_generate_v4(),
    company_id           uuid not null,
    free_limit           int2 not null default 20,
    subscription_limit   int2 not null default 0,
    subscription_status  varchar,
    current_period_start int2,
    current_period_end   int2,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (id)
);

-- CREATE PERSONAL SUBSCRIPTION TABLE
create table public.personal_subscription
(
    id                   uuid not null default uuid_generate_v4(),
    user_id              uuid not null,
    free_limit           int2 not null default 50,
    subscription_limit   int2 not null default 0,
    subscription_status  varchar,
    current_period_start int2,
    current_period_end   int2,

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),
    primary key (id)
);
