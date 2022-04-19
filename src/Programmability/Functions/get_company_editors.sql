create or replace function get_company_editors(_company_id uuid) returns setof uuid as
$$
select user_id
from company_staff
where company_id = $1
  and (role = 'write' or role = 'admin' or role = 'super_admin')
$$ stable language sql
   security definer;