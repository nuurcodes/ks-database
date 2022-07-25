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

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/invite_created',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('record',
                                  jsonb_build_object('id', new.id, 'company_id', new.company_id, 'email', new.email))
        )::http_request);

    return new;
end ;
$$;

-- ON_HANDLE_CREATE_INVENTORY_ITEM
create or replace function public.handle_create_inventory_item()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/inventory_added',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('record',
                                  jsonb_build_object('nano_id', new.nano_id, 'company_id', new.company_id, 'barcode',
                                                     new.barcode))
        )::http_request);

    return new;
end ;
$$;

-- ON_HANDLE_DELETE_INVENTORY_ITEM
create or replace function public.handle_delete_inventory_item()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/inventory_deleted',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('old_record',
                                  jsonb_build_object('nano_id', old.nano_id, 'company_id', old.company_id, 'barcode',
                                                     old.barcode))
        )::http_request);

    return old;
end ;
$$;

-- ON_HANDLE_CREATE_COMPANY_USAGE
create or replace function public.handle_create_company_usage()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/usage_company_created',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('record',
                                  jsonb_build_object('company_id', new.company_id))
        )::http_request);
    return new;
end ;
$$;

-- ON_HANDLE_CREATE_PERSONAL_USAGE
create or replace function public.handle_create_personal_usage()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/usage_personal_created',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('record',
                                  jsonb_build_object('user_id', new.user_id))
        )::http_request);
    return new;
end ;
$$;

-- ON_HANDLE_CREATE_PERSONAL_USAGE
create or replace function public.handle_create_company_user_delete_request()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/company_user_delete_request',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('old_record',
                                  jsonb_build_object('email', old.email))
        )::http_request);
    return new;
end ;
$$;

-- ON_HANDLE_CREATE_PERSONAL_USAGE
create or replace function public.handle_create_personal_user_delete_request()
    returns trigger
    language plpgsql
    security definer set search_path = extensions, public
as
$$

begin
    perform
    from http((
               'POST',
               'https://staging.business.kickscan.com/api/supabase/personal_user_delete_request',
               ARRAY [http_header('Authorization', 'Basic bnV1cmNvZGVzOnZCKjBnYmpVQjdLejRFN14mZHhITV5acg==')],
               'application/json',
               jsonb_build_object('old_record',
                                  jsonb_build_object('email', old.email))
        )::http_request);
    return new;
end ;
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

-- TRIGGER
drop trigger if exists on_company_usage_created on public.company_usage;
create trigger on_company_usage_created
    after insert
    on public.company_usage
    for each row
execute procedure public.handle_create_company_usage();

-- TRIGGER
drop trigger if exists on_personal_usage_created on public.personal_usage;
create trigger on_personal_usage_created
    after insert
    on public.personal_usage
    for each row
execute procedure public.handle_create_personal_usage();

-- TRIGGER
drop trigger if exists on_company_user_delete_request on public.company_user_delete_request;
create trigger on_company_user_delete_request
    after insert
    on public.company_user_delete_request
    for each row
execute procedure public.handle_create_company_user_delete_request();

-- TRIGGER
drop trigger if exists on_personal_user_delete_request on public.personal_user_delete_request;
create trigger on_personal_user_delete_request
    after insert
    on public.personal_user_delete_request
    for each row
execute procedure public.handle_create_personal_user_delete_request();
