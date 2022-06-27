-- CREATE STORAGE BUCKETS
insert into storage.buckets (id, name)
values ('sneaker', 'sneaker');

-- CREATE COMPANY USER TABLE
create table public.company_user
(
    id         uuid    not null,
    email      varchar not null,
    first_name varchar not null,
    last_name  varchar not null,
    primary key (id)
);

-- CREATE PERSONAL USER TABLE
create table public.personal_user
(
    id        uuid references auth.users not null,
    phone     varchar                    not null,
    stripe_id varchar                    not null,
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

-- CREATE PRODUCT SKU TABLE
create table public.product_sku
(
    sku          varchar     not null,
    name         varchar     not null,
    style        varchar     not null,
    gender       varchar     not null check (gender = 'M' or gender = 'W' or gender = 'GS' or gender = 'PS' or
                                             gender = 'TD' or gender = 'KID' or gender = 'INFANT'),
    brand        varchar     not null,
    nickname     varchar     not null default '',
    release_date int4,
    image_url    varchar     not null,
    created_at   timestamptz not null default now(),
    verified     boolean     not null default false,
    source_id    uuid        not null,

    constraint fk_product_source foreign key (source_id) references public.product_source (source_id),
    primary key (sku)
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
    constraint fk_product_sku foreign key (sku) references public.product_sku (sku),
    primary key (barcode)
);

-- CREATE COMPANY TABLE
create table public.company
(
    company_id          uuid        not null default uuid_generate_v4(),
    company_name        varchar     not null,
    address_line1       varchar     not null,
    address_line2       varchar,
    address_postal_code varchar,
    address_city        varchar     not null,
    address_country     varchar     not null,
    created_at          timestamptz not null default now(),
    stripe_id           varchar     not null,
    svix_app_id         varchar     not null,
    primary key (company_id)
);

-- CREATE COMPANY INVITE TABLE
create table public.company_invite
(
    id         uuid        not null default uuid_generate_v4(),
    email      varchar     not null,
    role       varchar     not null check (role = 'super_admin' or role = 'admin' or role = 'write' or role = 'read'),
    company_id uuid        not null,
    created_at timestamptz not null default now(),

    constraint fk_company foreign key (company_id) references public.company (company_id),
    unique (email, company_id),
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

-- CREATE COMPANY INVENTORY ITEM TABLE
create table public.company_inventory_item
(
    inventory_id uuid    not null default uuid_generate_v4(),
    batch_id     uuid    not null,
    company_id   uuid    not null,
    barcode      varchar not null,
    nano_id      varchar not null,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    constraint fk_product_barcode foreign key (barcode) references public.product_barcode (barcode),
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
    constraint fk_product_barcode foreign key (barcode) references public.product_barcode (barcode),
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
    id                   varchar             not null,
    company_id           uuid                not null,
    status               subscription_status not null,
    metadata             jsonb               not null default '{}'::jsonb,
    price_id             varchar             not null,
    cancel_at_period_end bool,
    created              int4                not null,
    current_period_start int4                not null,
    current_period_end   int4                not null,
    ended_at             int4,
    cancel_at            int4,
    canceled_at          int4,
    trial_start          int4,
    trial_end            int4,
    subscription_item_id varchar             not null,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    constraint fk_stripe_price foreign key (price_id) references public.stripe_price (id),
    primary key (id)
);

-- CREATE PERSONAL SUBSCRIPTION TABLE
create table public.personal_subscription
(
    id                   varchar             not null,
    user_id              uuid                not null,
    status               subscription_status not null,
    metadata             jsonb               not null default '{}'::jsonb,
    price_id             varchar             not null,
    cancel_at_period_end bool,
    created              int4                not null,
    current_period_start int4                not null,
    current_period_end   int4                not null,
    ended_at             int4,
    cancel_at            int4,
    canceled_at          int4,
    trial_start          int4,
    trial_end            int4,
    subscription_item_id varchar             not null,

    constraint fk_personal_user foreign key (user_id) references public.personal_user (id),
    primary key (id)
);

-- CREATE STRIPE PRODUCT TABLE
create table public.stripe_product
(
    id          varchar not null,
    active      bool    not null,
    name        varchar not null,
    description varchar not null,
    metadata    jsonb   not null default '{}'::jsonb,
    primary key (id)
);

-- CREATE STRIPE PRODUCT TABLE
create table public.stripe_price
(
    id         varchar      not null,
    nickname   varchar      not null,
    active     bool         not null,
    currency   varchar      not null,
    product_id varchar      not null,
    type       pricing_type not null default 'recurring',
    amount     int4         not null,
    metadata   jsonb        not null default '{}'::jsonb,

    constraint fk_stripe_product foreign key (product_id) references public.stripe_product (id),
    primary key (id)
);

-- CREATE COMPANY INVOICE
create table public.company_invoice
(
    id          varchar not null,
    stripe_id   varchar not null,
    invoice_pdf varchar not null,
    currency    varchar not null,
    nickname    varchar not null,
    company_id  uuid    not null,
    amount_paid int4    not null,
    paid_at     int4    not null,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (id)
);

-- CREATE PERSONAL INVOICE
create table public.personal_invoice
(
    id          varchar not null,
    stripe_id   varchar not null,
    invoice_pdf varchar not null,
    currency    varchar not null,
    nickname    varchar not null,
    user_id     uuid    not null,
    amount_paid int4    not null,
    paid_at     int4    not null,

    constraint fk_user foreign key (user_id) references public.personal_user (id),
    primary key (id)
);

-- CREATE RESTOCK_SKUS
create table public.restock_sku
(
    sku        varchar     not null,
    created_at timestamptz not null default now(),
    scraped    boolean     not null default false,

    primary key (sku)
);

-- CREATE COMPANY_WEBHOOK
create table public.company_webhook
(
    endpoint_id varchar not null,
    company_id  uuid    not null,
    endpoint    varchar not null,
    disabled    boolean not null,

    constraint fk_company foreign key (company_id) references public.company (company_id),
    primary key (endpoint_id)
);
