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
        insert into public.personal_user (id, phone)
        values (new.id, new.phone);

        insert into public.personal_subscription (user_id)
        values (new.id);

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
    delete from auth.users
    where id = old.user_id;
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


