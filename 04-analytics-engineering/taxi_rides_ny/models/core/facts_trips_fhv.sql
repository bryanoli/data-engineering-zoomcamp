{{ config(materialized='table') }}

with green_data as (
    select 
        pickup_locationid,  
        dropoff_locationid, 
        pickup_datetime, 
        dropoff_datetime, 
        store_and_fwd_flag, 
        'Green' as service_type 
    from {{ ref('stg_green_tripdata') }}
), 

yellow_data as (
    select 
        pickup_locationid,  
        dropoff_locationid, 
        pickup_datetime, 
        dropoff_datetime, 
        store_and_fwd_flag,  
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 

fhv_data as (
    select *,
        'fhv' as service_type
    from {{ ref('stg_fhv_tripdata') }}
),

trips_unioned as (
    select * from fhv_data
), 

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select 
    trips_unioned.pickup_locationid,  
    trips_unioned.dropoff_locationid, 
    trips_unioned.pickup_datetime, 
    trips_unioned.dropoff_datetime, 
    trips_unioned.store_and_fwd_flag, 
from trips_unioned
inner join dim_zones as pickup_zone
on trips_unioned.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on trips_unioned.dropoff_locationid = dropoff_zone.locationid