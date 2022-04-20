alter table company_usage
    replica identity full;

alter table company_subscription
    replica identity full;

alter table personal_usage
    replica identity full;

alter table personal_subscription
    replica identity full;