
with
target_data as (
select
  period,
  date(date) as quarter_date,
  team,
  name,
  component,
  target,
  weight,
from
  `team-data-engineering.pt_core.gcr_key_metrics_target_individual`
where
  period = 'quarter'
  and
  team = 'marketing'
  and
  date = '2026-04-01'
)

,elara as (
  select
    quarter_date,
    team,
    name,
    component,
    target,
    147 as attainment_val, -- manual add, 3 cases studies created
    147/target as attainment_percent,
    least(greatest(147/target*weight,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Elara Ren'
    and
    component = '35% Demo booked efficiency'

  union all
    select
    quarter_date,
    team,
    name,
    component,
    target,
    72 as attainment_val, -- manual add, 3 cases studies created
    72/target as attainment_percent,
    least(greatest(72/target*weight,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Elara Ren'
    and
    component = '35% Demo attanded efficiency'

  union all
    select
    quarter_date,
    team,
    name,
    component,
    target,
    1 as attainment_val, -- manual add, 3 cases studies created
    1/target as attainment_percent,
    least(greatest(1/target*weight,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Elara Ren'
    and
    component = '10% Media plan'

  union all
    select
    quarter_date,
    team,
    name,
    component,
    target,
    1 as attainment_val, -- manual add, 3 cases studies created
    1/target as attainment_percent,
    least(greatest(1/target*weight,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Elara Ren'
    and
    component = '10% Budget tracker'

  union all
    select
    quarter_date,
    team,
    name,
    component,
    target,
    1 as attainment_val, -- manual add, 3 cases studies created
    1/target as attainment_percent,
    least(greatest(1/target*weight,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Elara Ren'
    and
    component = '10% Content play'

)

,hayes as (
  select
    quarter_date,
    team,
    name,
    component,
    target,
    2342 as attainment_val, -- manual add, 3 cases studies created
    2342/target as attainment_percent,
    least(greatest(2342*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Hayes'
    and
    component = '35% Trial Sea'
  
  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    657 as attainment_val, -- manual add, 3 cases studies created
    657/target as attainment_percent,
    least(greatest(657*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Hayes'
    and
    component = '35% Demo Sea'

  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    19 as attainment_val, -- manual add, 3 cases studies created
    19/target as attainment_percent,
    least(greatest(19*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Hayes'
    and
    component = '10% Demo booked May in ID'

  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    11 as attainment_val, -- manual add, 3 cases studies created
    11/target as attainment_percent,
    least(greatest(11*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Hayes'
    and
    component = '10% Demo attanded June in ID'

  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    1 as attainment_val, -- manual add, 3 cases studies created
    1/target as attainment_percent,
    least(greatest(1*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Hayes'
    and
    component = '10% Outbond June Sea'
)

,jessica as (
  select
    quarter_date,
    team,
    name,
    component,
    target,
    2342 as attainment_val, -- manual add, 3 cases studies created
    2342/target as attainment_percent,
    least(greatest(2342*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Jessica'
    and
    component = '35% Trial Sea'
  
  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    657 as attainment_val, -- manual add, 3 cases studies created
    657/target as attainment_percent,
    least(greatest(657*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Jessica'
    and
    component = '35% Demo Sea'

  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    19 as attainment_val, -- manual add, 3 cases studies created
    19/target as attainment_percent,
    least(greatest(19*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Jessica'
    and
    component = '10% Demo booked May in ID'

  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    11 as attainment_val, -- manual add, 3 cases studies created
    11/target as attainment_percent,
    least(greatest(11*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Jessica'
    and
    component = '10% Demo attanded June in ID'

  union all
  select
    quarter_date,
    team,
    name,
    component,
    target,
    1 as attainment_val, -- manual add, 3 cases studies created
    1/target as attainment_percent,
    least(greatest(1*weight/target,0),weight) as attainment_percent_weighted,
  from
    target_data
  where
    name = 'Jessica'
    and
    component = '10% Outbond June Sea'
)

select * from elara
union all
select * from hayes
union all
select * from jessica
