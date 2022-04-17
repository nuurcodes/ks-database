-- CREATE STORAGE BUCKETS
insert into storage.buckets (id, name)
values ('sneaker', 'sneaker');

-- CREATE COMPANY USER TABLE
-- TODO: ADD TRIGGER ON AUTH USER CREATE
create table public.company_user
(
    id         uuid references auth.users not null,
    email      varchar                    not null,
    first_name varchar                    not null,
    last_name  varchar                    not null,

    primary key (id)
);

-- CREATE PERSONAL USER TABLE
-- TODO: ADD TRIGGER ON AUTH USER CREATE
create table public.personal_user
(
    id    uuid references auth.users not null,
    phone varchar                    not null,

    primary key (id)
);

-- CREATE PRODUCT_SOURCE TABLE
-- TODO: ADD DEFAULT ENTRIES
create table public.product_source
(
    source_id  uuid        default uuid_generate_v4(),
    name       varchar not null,
    created_at timestamptz default now(),

    primary key (source_id)
);


-- CREATE PRODUCT BARCODE TABLE
create table public.product_barcode
(
    barcode     varchar not null,
    verified    bool        default false,
    sku         varchar not null,
    size        varchar not null,
    size_region varchar not null,
    created_at  timestamptz default now(),
    source_id   uuid,
    constraint fk_product_source foreign key (source_id) references public.product_source (source_id),

    primary key (barcode)
);

-- CREATE PRODUCT SKU TABLE
create table public.product_sku
(
    sku          varchar not null,
    name         varchar not null,
    style        varchar not null,
    gender       varchar not null,
    -- TODO: Constraint Men, Women, Kids
    brand        varchar not null,
    nickname     varchar not null,
    release_date timestamptz,
    image_url    varchar not null,
    created_at   timestamptz default now(),
    verified     boolean     default false,
    source_id    uuid,
    constraint fk_product_source foreign key (source_id) references public.product_source (source_id),

    primary key (sku)
);

-- CREATE COMPANY TABLE
create table public.company
(
    company_id          uuid        default uuid_generate_v4(),
    company_email       varchar not null,
    company_name        varchar not null,
    address_line1       varchar not null,
    address_line2       varchar,
    address_postal_code varchar,
    address_city        varchar not null,
    address_country     varchar not null,
    created_at          timestamptz default now(),
    stripe_id           varchar,
    svix_app_id         varchar,

    primary key (company_id)
);

-- CREATE COMPANY STAFF TABLE
-- TODO: INVITES USERS BY EMAIL WORKFLOW
create table public.company_staff
(
    id         uuid default uuid_generate_v4(),
    user_id    uuid not null unique,
    company_id uuid not null,
    constraint fk_company_user foreign key (user_id) references public.company_user (id),
    constraint fk_company foreign key (company_id) references public.company (company_id),

    primary key (id)
);

-- CREATE COMPANY INVENTORY TABLE
create table public.company_inventory
(
    inventory_id uuid        default uuid_generate_v4(),
    user_id      uuid    not null,
    company_id   uuid    not null,
    barcode      varchar not null,
    created_at   timestamptz default now(),
    nano_id      varchar not null,

    constraint fk_company_user foreign key (user_id) references public.company_user (id),
    constraint fk_company foreign key (company_id) references public.company (company_id),

    primary key (inventory_id)
);

-- CREATE PERSONAL INVENTORY TABLE
create table public.personal_inventory
(
    inventory_id uuid        default uuid_generate_v4(),
    user_id      uuid    not null,
    barcode      varchar not null,
    created_at   timestamptz default now(),
    nano_id      varchar not null,

    constraint fk_personal_user foreign key (user_id) references public.company_user (id),

    primary key (inventory_id)
);

-- CREATE COMPANY USAGE TABLE
create table public.company_usage
(
    id         uuid        default uuid_generate_v4(),
    user_id    uuid not null,
    company_id uuid not null,
    created_at timestamptz default now(),

    constraint fk_company_user foreign key (user_id) references public.company_user (id),
    constraint fk_company foreign key (company_id) references public.company (company_id),

    primary key (id)
);

-- CREATE COMPANY USAGE TABLE
create table public.personal_usage
(
    id         uuid        default uuid_generate_v4(),
    user_id    uuid not null,
    created_at timestamptz default now(),

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),

    primary key (id)
);

-- CREATE COMPANY SUBSCRIPTION TABLE
create table public.company_subscription
(
    id                 uuid default uuid_generate_v4(),
    company_id         uuid not null,
    free_limit         int2 default 20,
    subscription_limit int2 default 0,

    constraint fk_company foreign key (company_id) references public.company (company_id),

    primary key (id)
);

-- CREATE PERSONAL SUBSCRIPTION TABLE
create table public.personal_subscription
(
    id                 uuid default uuid_generate_v4(),
    user_id            uuid not null,
    free_limit         int2 default 50,
    subscription_limit int2 default 0,

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),

    primary key (id)
);


