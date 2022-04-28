create
    or replace function update_user_password(current_plain_password varchar, new_plain_password varchar)
    returns json
    language plpgsql
    security definer
as
$$
DECLARE
    _uid    uuid; -- for checking by 'is not found'
    user_id uuid; -- to store the user id from the request
BEGIN
    -- First of all check the new password rules
    -- not empty
    IF
        (new_plain_password = '') IS NOT FALSE THEN
        RAISE EXCEPTION 'New password is empty';
        -- minimum 8 chars
    ELSIF
        char_length(new_plain_password) < 8 THEN
        RAISE EXCEPTION 'Password must be at least 8 characters';
    END IF;

    -- Get user by his current auth.uid and current password
    user_id
        := auth.uid();
    SELECT id
    INTO _uid
    FROM auth.users
    WHERE id = user_id
      AND encrypted_password =
          crypt(current_plain_password::text
              , auth.users.encrypted_password);

    -- Check the current password
    IF
        NOT FOUND THEN
        RAISE EXCEPTION 'Incorrect password';
    END IF;

    -- Then set the new password
    UPDATE auth.users
    SET encrypted_password =
            crypt(new_plain_password, gen_salt('bf'))
    WHERE id = user_id;

    RETURN '{"data":true}';
END;
$$