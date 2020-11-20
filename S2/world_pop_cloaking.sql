CREATE TEMP FUNCTION keyToCornerLatLngs(key STRING) RETURNS STRING LANGUAGE js
OPTIONS (library=["gs://bigquery-geolib/s2geometry.js"]) AS """
var cornerLatLng = S2.S2Cell.FromHilbertQuadKey(key).getCornerLatLngs(); var geojson = { "type": "Polygon", "coordinates": [[ [cornerLatLng[0]['lng'],cornerLatLng[0]['lat']], [cornerLatLng[1]['lng'],cornerLatLng[1]['lat']], [cornerLatLng[2]['lng'],cornerLatLng[2]['lat']], [cornerLatLng[3]['lng'],cornerLatLng[3]['lat']], [cornerLatLng[0]['lng'],cornerLatLng[0]['lat']] ]] }; return JSON.stringify(geojson);
""";


With T0 AS( 
SELECT `libjs4us.s2.latLngToKey`( latitude_centroid , longitude_centroid , 14) key, sum(population) as population FROM `bigquery-public-data.worldpop.population_grid_1km`
WHERE last_updated = "2017-01-01" 
group by key
),
T1 AS( 
SELECT
population,
SUBSTR(key,1, 1) as face,
REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(key,3, 20),"0", "00"),"1", "01"),"2", "10"),"3", "11") key FROM T0
),
T2 AS( SELECT population, face,
SUBSTR(key, 1,  1) as key1,
SUBSTR(key, 1,  2) as key2,
SUBSTR(key, 1,  3) as key3,
SUBSTR(key, 1,  4) as key4,
SUBSTR(key, 1,  5) as key5,
SUBSTR(key, 1,  6) as key6,
SUBSTR(key, 1,  7) as key7,
SUBSTR(key, 1,  8) as key8,
SUBSTR(key, 1,  9) as key9,
from T1),
T3 AS( Select key9 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3,key4,key5,key6,key7,key8,key9, face union all
select key8 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3,key4,key5,key6,key7,key8, face union all
select key7 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3,key4,key5,key6,key7, face union all
select key6 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3,key4,key5,key6, face union all
select key5 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3,key4,key5, face union all
select key4 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3,key4, face union all
select key3 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2,key3, face union all
select key2 key , count(*) count, face, sum(population) as population
from T2
group by key1,key2, face union all
select key1 key , count(*) count, face, sum(population) as population
from T2
group by key1, face
),
T4 AS(Select key, count, face, population
from T3
where population > 15000000
),
T8 AS (SELECT concat(face,'/',key) key, face
from T4),
T9 AS (SELECT
  face,
  array (SELECT
    substr(key, 1,len) 
  FROM
    UNNEST(GENERATE_ARRAY(length(key)-1,length(key))) AS len) keys
FROM
  T8),
T10 AS (select key, count(*) as count from T9,
unnest(keys) as key
group by key
order by key),
T11 AS (select key from T10 where count>1),
T12 AS (select concat(key,'0') key from T11 union all
select concat(key,'1') key from T11),
T13 AS (select key from T12
where key not in (SELECT key from T11)),
T99 AS(
select concat(key,'0') key,
from T13
where mod(length(key), 2) = 1 union all
select concat(key,'1') key,
from T13
where mod(length(key), 2) = 1 union all
select key,
from T13
where mod(length(key), 2) = 0
)
select keyToCornerLatLngs(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ARRAY_TO_STRING(REGEXP_EXTRACT_ALL(key, "(..)"), ' '),"00", "0"),"01", "1"),"10", "2"),"11", "3")," ", "")) geo
from T99
order by key
