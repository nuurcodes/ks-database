create or replace function get_company_staff(_company_id uuid) returns setof uuid as
$$
select user_id
from company_staff
where company_id = $1
$$ stable language sql
   security definer;