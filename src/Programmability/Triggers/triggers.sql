-- ON_AUTH_USER_CREATED TRIGGER
create or replace function public.handle_new_user()
    returns trigger
    language plpgsql
    security definer set search_path = public
as
$$
begin
    if new.phone is null then
        insert into public.company_user (id, email, first_name, last_name)
        values (new.id, new.email, new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'last_name');

        return new;
    else
        insert into public.personal_user (id, phone, stripe_id)
        values (new.id, new.phone, '');

        insert into public.product_source (source_id, name)
        values (new.id, new.id);

        return new;
    end if;
end;
$$;

-- ON_AUTH_USER_UPDATED TRIGGER
create or replace function public.handle_update_user()
    returns trigger
    language plpgsql
    security definer set search_path = public
as
$$
begin
    if new.phone is null then
        update public.company_user
        set (first_name, last_name) = (new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'last_name')
        where id = new.id;
        return new;
    else
        update public.personal_user
        set phone = new.phone
        where id = new.id;
        return new;
    end if;
end;
$$;

-- ON_AUTH_USER_UPDATED TRIGGER
create or replace function public.handle_delete_company_staff()
    returns trigger
    language plpgsql
    security definer set search_path = public
as
$$
begin
    delete
    from auth.users
    where id = old.user_id;
    return new;
end;
$$;

-- ON_HANDLE_CREATE_COMPANY_INVITE
create or replace function public.handle_create_company_invite()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

declare
    _company_name varchar;

begin
    select company_name from company where company.company_id = new.company_id into _company_name;

    perform
    from http((
               'POST',
               'https://api.postmarkapp.com/email/withTemplate',
               ARRAY [http_header('X-Postmark-Server-Token', '9af49833-2904-41a4-800f-ca843d43e844')],
               'application/json',
               jsonb_build_object('From', 'contact@kickscan.com', 'To', new.email, 'TemplateId', '27355732',
                                  'TemplateModel',
                                  jsonb_build_object('company_name', _company_name, 'action_url',
                                                     concat('https://business.kickscan.com/invite?id=', new.id),
                                                     'support_email', 'contact@kickscan.com'))
        )::http_request);

    return new;
end;
$$;

-- ON_HANDLE_CREATE_INVENTORY_ITEM
create or replace function public.handle_create_inventory_item()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

declare
    _uuid         uuid;
    _size         varchar;
    _size_region  varchar;
    _svix_app_id  varchar;
    _sku          varchar;
    _name         varchar;
    _style        varchar;
    _gender       varchar;
    _brand        varchar;
    _nickname     varchar;
    _release_date int4;
    _image_url    varchar;

begin
    select uuid_generate_v4() into _uuid;
    select svix_app_id from public.company where company.company_id = new.company_id into _svix_app_id;

    select pb.size,
           pb.size_region,
           ps.sku,
           ps.name,
           ps.style,
           ps.gender,
           ps.brand,
           ps.nickname,
           ps.release_date,
           ps.image_url
    into _size, _size_region, _sku, _name, _style, _gender, _brand, _nickname, _release_date, _image_url
    from public.product_barcode as pb
             inner join public.product_sku as ps on pb.sku = ps.sku
    where barcode = new.barcode;

    perform
    from http((
               'POST',
               concat('https://api.svix.com/api/v1/app/', _svix_app_id, '/msg/'),
               ARRAY [
                   http_header('Authorization', 'Bearer testsk_qsN2E1o7CDSTuB6jx9INIJPc3etc5TBT'),
                   http_header('accept', 'application/json'),
                   http_header('Content-Type', 'application/json'),
                   http_header('idempotency-key', cast(_uuid as varchar))
                   ],
               'application/json',
               jsonb_build_object('eventType', 'item.added', 'payload',
                                  jsonb_build_object('id', new.nano_id, 'size', _size, 'size_region', _size_region,
                                                     'sku', _sku,
                                                     'image_url', _image_url, 'name', _name, 'style', _style, 'gender',
                                                     _gender, 'brand',
                                                     _brand, 'nickname', _nickname, 'release_date', _release_date))
        )::http_request);

    return new;
end;
$$;

-- ON_HANDLE_DELETE_INVENTORY_ITEM
create or replace function public.handle_delete_inventory_item()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

declare
    _uuid         uuid;
    _size         varchar;
    _size_region  varchar;
    _svix_app_id  varchar;
    _sku          varchar;
    _name         varchar;
    _style        varchar;
    _gender       varchar;
    _brand        varchar;
    _nickname     varchar;
    _release_date int4;
    _image_url    varchar;

begin
    select uuid_generate_v4() into _uuid;
    select svix_app_id from public.company where company.company_id = old.company_id into _svix_app_id;

    select pb.size,
           pb.size_region,
           ps.sku,
           ps.name,
           ps.style,
           ps.gender,
           ps.brand,
           ps.nickname,
           ps.release_date,
           ps.image_url
    into _size, _size_region, _sku, _name, _style, _gender, _brand, _nickname, _release_date, _image_url
    from public.product_barcode as pb
             inner join public.product_sku as ps on pb.sku = ps.sku
    where barcode = old.barcode;

    perform
    from http((
               'POST',
               concat('https://api.svix.com/api/v1/app/', _svix_app_id, '/msg/'),
               ARRAY [
                   http_header('Authorization', 'Bearer testsk_qsN2E1o7CDSTuB6jx9INIJPc3etc5TBT'),
                   http_header('accept', 'application/json'),
                   http_header('Content-Type', 'application/json'),
                   http_header('idempotency-key', cast(_uuid as varchar))
                   ],
               'application/json',
               jsonb_build_object('eventType', 'item.deleted', 'payload',
                                  jsonb_build_object('id', old.nano_id, 'size', _size, 'size_region',
                                                     _size_region,
                                                     'sku', _sku,
                                                     'image_url', _image_url, 'name', _name, 'style',
                                                     _style, 'gender',
                                                     _gender, 'brand',
                                                     _brand, 'nickname', _nickname, 'release_date',
                                                     _release_date))
        )::http_request);

    return old;
end;
$$;

-- TRIGGER
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert
    on auth.users
    for each row
execute procedure public.handle_new_user();

-- TRIGGER
drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
    after update
    on auth.users
    for each row
execute procedure public.handle_update_user();

-- TRIGGER
drop trigger if exists on_company_staff_deleted on public.company_staff;
create trigger on_company_staff_deleted
    after delete
    on public.company_staff
    for each row
execute procedure public.handle_delete_company_staff();

-- TRIGGER
drop trigger if exists on_company_invite_created on public.company_invite;
create trigger on_company_invite_created
    after insert
    on public.company_invite
    for each row
execute procedure public.handle_create_company_invite();

-- TRIGGER
drop trigger if exists on_company_inventory_created on public.company_inventory_item;
create trigger on_company_inventory_created
    after insert
    on public.company_inventory_item
    for each row
execute procedure public.handle_create_inventory_item();

-- TRIGGER
drop trigger if exists on_company_inventory_deleted on public.company_inventory_item;
create trigger on_company_inventory_deleted
    after delete
    on public.company_inventory_item
    for each row
execute procedure public.handle_delete_inventory_item();
