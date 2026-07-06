with

good_downgrade as (
-- select
--   *
-- from
--   team-data-engineering.pt_core.downgrade_revenue_breakdown_view
-- where
--   upgrade_downgrade_plan_sub_type_2 = '03. Same Plan Downgrade'
--   and
--   mrr_month >= date'2025-01-01'

-- WATI-25442 Fix CSM 1:1 "Good Downgrade" Exclusion
select
  mrr_month,
  subscription_id
from (
select
  mrr_month,
  subscription_id,
  upgrade_downgrade_plan_sub_type_2,
  count(subscription_id) over(partition by mrr_month,subscription_id) as downgrade_cnt
from
  `team-data-engineering.pt_core.downgrade_revenue_breakdown_view`
)
where
  upgrade_downgrade_plan_sub_type_2 = '03. Same Plan Downgrade'
  and
  downgrade_cnt = 1
  and
  mrr_month >= date'2025-01-01'
)

,manual_deals as (
  select
    *
  from
    team-data-engineering.pt_core.gcr_manual_add_deals
)

,manual_exclude_subs as (
  select
    *
  from
    team-data-engineering.pt_core.gcr_manual_exclude_subs
)

,manual_customer_list as ( 
  select  
    * 
  from 
    `wati-analytics-prod.gs_wati.gcr_partnership_china_customer_list_manual`
  where 
    revops_approval is true
    AND NOT ( 
      mrr_month IS NULL OR 
      customer_id IS NULL OR 
      customer_email IS NULL OR 
      is_affiliate IS NULL OR 
      partner_owner IS NULL OR 
      partner_email IS NULL OR 
      deal_won_date IS NULL OR 
       revops_approval IS NULL
    )
)

-- ,hb_deals as (
--   select
--     *
--   from
--     team-data-engineering.pt_core.gcr_deals_raw_view
-- )

,sales_email as (
  select
    user_email sales_email,
    user_name,
    team_name,
    team_region
  from
    wati-analytics-prod.gs_wati.calendly_user_list
  where
    team_region = 'GCR' 
)

,sales_deals as (
  select
    *,
    user_name
  from
    team-data-engineering.pt_core.mrr_sales_spif_monthly_annual_churn_from_q2_2025 t1
  join
    sales_email t2 on t2.sales_email = t1.attributed_to_rep_email
  where
    attainment_status = 'APPROVED'
  and
    mrr_month >= date'2026-04-01'
)

-- ,sales_deals as (
--   select
--     *,
--     user_name
--   from
--     wati-analytics-prod.dm_wati_core.dm_sales_attainment_monthly t1
--   join
--     sales_email t2 on t2.sales_email = t1.sales_rep_email
--   where
--     attainment_status = 'APPROVED'
--   and
--     mrr_month >= date'2026-04-01'
-- )


,double_att as (
  select
    *
  from team-data-engineering.pt_core.gs_double_attribution_farida
)

,onbaording as (
  select
    *
  from
    team-data-engineering.pt_core.onboarding_tracker_subscription_info_v2
)

, usage AS (
SELECT distinct
  month_date,
  subscription_id,
  coalesce(net_usage_revenue,0) net_usage_revenue_usd,
  coalesce(prev_net_usage_revenue,0) prev_net_usage_revenue,
  coalesce(net_usage_revenue,0) - coalesce(prev_net_usage_revenue,0) as net_new_usage_revenue ,
  acv_more_than_3k_past_3m,
  projected_acv,
  acv,
  acv_tier,
  projected_acv_tier
FROM `team-data-engineering.pt_core.dm_subs_acv_monthly`
where
  month_date >= date'2026-01-01'
)

,raw as (
  select distinct
    t1.* except(mrr_impact),
    coalesce(md.deal_owner_email,sd.attributed_to_rep_email,da.sales_email) sales_agent_email,
    attainment_status,
    ob.activated_within_30days,
    case when ob.first_30_days_message>=100 or ob.first_30_days_chatbot_session>=20 then 1 else 0 end is_active_within_30d,
    activated_date,
    case
      when t1.partner_owner in ('Felix Chau','James Chan') then 'Farida Chan'
      when t1.partner_owner is null and manual.referral_subscription_id is not null then manual.partner_owner
      when t1.partner_owner is null and cust.customer_id is not null then cust.partner_owner
      else t1.partner_owner
    end as partner_owner_adjusted,
    case  
      when t1.partner_owner is null and manual.referral_subscription_id is not null then 'Managed Partner' 
      when t1.partner_owner is null and cust.customer_id is not null then 'Managed Partner' 
      else t1.partner_type 
      end as partner_filter_channel_adjusted,

    ob.subscription_wati_db_name,
    coalesce(md.new_mrr_impact, t1.mrr_impact) mrr_impact,

    COALESCE(net_usage_revenue_usd, 0) as net_usage,
    COALESCE(net_new_usage_revenue, 0) as nn_usage,
    COALESCE(net_new_usage_revenue, 0) + coalesce(md.new_mrr_impact, t1.mrr_impact,0) nnmrr_all,
    case when da.subscription_id is not null then 1 else 0 end is_double_att
  from
    team-data-engineering.pt_core.mrr_sales_csm_am_attribution_shopify t1
  left join
    good_downgrade t2
    on t1.subscription_id = t2.subscription_id
      and t1.mrr_month = t2.mrr_month
      and t1.mrr_type = 'Downgrade MRR'
  left join
    manual_deals md
    on md.mrr_month = t1.mrr_month
    and md.subscription_id = t1.subscription_id
  left join
    sales_deals sd
    on sd.mrr_month = t1.mrr_month
    and sd.subscription_id = t1.subscription_id
  left join
    onbaording ob
    on ob.subscription_id = t1.subscription_id
  left join
    `team-data-engineering.pt_core.gcr_key_metrics_partner_manual_attribution` as manual
    on t1.subscription_id = manual.referral_subscription_id and manual.partner_type = 'Managed Affiliate'
  left join 
    manual_customer_list as cust 
    on t1.customer_id = cust.customer_id 
    and t1.mrr_month = cust.mrr_month
  left join
    manual_exclude_subs mes
    on mes.mrr_month = t1.mrr_month
    and mes.subscription_id = t1.subscription_id
  LEFT JOIN usage as u
    on t1.mrr_month = u.month_date
    and t1.subscription_id = u.subscription_id
  LEFT JOIN double_att as da
    on t1.mrr_month = da.mrr_month
    and t1.subscription_id = da.subscription_id
  where
    (t1.attributed_country_region in ('SEA (HK+MY+SG+ID)', 'China') or md.subscription_id is not null or sd.subscription_id is not null or da.subscription_id is not null)
    and 
    t1.mrr_month >= date'2026-04-01'
    and
    t2.subscription_id is null
    and
    mes.subscription_id is null
    and
    subscription_internal_account_flag is false
)

select
  *,
  case when is_double_att = 1 then 'Y'
    when sales_agent_email is not null
      and coalesce(partner_filter_channel_adjusted,'na') not in ('Managed Agency','Managed Affiliate','Managed Partner')
      and sales_agent_email not in ('jamie@clare.ai','wanfu@clare.ai','janet@clare.ai') then 'Y'
        
      when sales_agent_email is not null
      and coalesce(partner_filter_channel_adjusted,'na') not in ('Managed Agency')
      and sales_agent_email in ('jamie@clare.ai','wanfu@clare.ai','janet@clare.ai') then 'Y'
      else 'N' end is_attributed_to_sales, 
  mrr_impact*12 arr_subs

from raw
