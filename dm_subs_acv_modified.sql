-- source for https://datastudio.google.com/reporting/a3c8f7d2-33f5-47cc-a64c-f9121d936f23/page/p_9j8fywt3ld/edit 
-- log pre-modification 5 jul
with
dim_subs as (
  select
    subscription_id,
    customer_domain_name,
    affiliates_email_name,
    affiliate_country,
    customer_managed_partner_owner_name,
  from
    `wati-analytics-prod.dw_wati.dim_subscription` ds
  left join
    `wati-analytics-prod.dw_wati.dim_customer` dc
    on ds.customer_sk=dc.customer_sk
  where
    ds.expired_timestamp is null
    and
    ds.subscription_spam_flag is false
    and
    dc.customer_internal_account_flag is false
)

,team_region_mapping as (
select
  case when user_name = 'Felix' then 'Felix Chau' else user_name end as user_name,
  team_region
from
`wati-analytics-prod.gs_wati.calendly_user_list`
where
  team_region is not null
  -- and
  -- team_name = 'partnership'
)

,topup as (
  select
    month_date,
    subscription_id,
    sum(topup_amt) as topup_amount_usd,
  from
    team-data-engineering.pt_core.gtm_topup_daily_view
  where topup_category in ('topup by manual (subscription level)','topup by system')
    group by 1,2 

)

select
  acv_subs.* except(customer_managed_partner_owner_name),
  dim_subs.customer_domain_name,
  dim_subs.affiliates_email_name,
  dim_subs.affiliate_country,
  dim_subs.customer_managed_partner_owner_name,
  team_region_mapping.team_region team_region_partner,
  topup_amount_usd
from
  `team-data-engineering.pt_core.dm_subs_acv_monthly` acv_subs
left join
  dim_subs
  on acv_subs.subscription_id = dim_subs.subscription_id
left join
  team_region_mapping
  on lower(user_name) = lower(dim_subs.customer_managed_partner_owner_name)
left join
  topup
  on topup.subscription_id = acv_subs.subscription_id
  and topup.month_date = acv_subs.month_date
  
