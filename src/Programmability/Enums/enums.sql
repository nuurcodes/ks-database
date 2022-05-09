create type pricing_plan_interval as enum('day', 'month', 'week', 'year');
create type pricing_type as enum('one_time', 'recurring');
create type subscription_status as enum('active', 'canceled', 'incomplete', 'incomplete_expired', 'past_due', 'trialing', 'unpaid');