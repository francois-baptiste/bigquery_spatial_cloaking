# bigquery_spatial_cloaking


This repo shows how to create cloaking regions to provide k–anonymity for location based services. It leverages the integration of hierarchical spatial indexes on Bigquery using [jslibs](https://github.com/CartoDB/bigquery-jslibsBigquery).

### Examples

In the following examples, the [worldpop public dataset](http://worldpop.org) is used.


### Using Uber H3


* [Code](/H3/world_pop_cloaking.sql)
* [Preview](http://francois-baptiste.github.io/bigquery_spatial_cloaking/H3/)

### Using Google S2

* [Code](/S2/world_pop_cloaking.sql)
* [Preview](https://geojson.io/#id=github:francois-baptiste/bigquery_spatial_cloaking/blob/main/S2/world_pop_cloaking.json)

## Some thoughts

Kepler.gl and geojson.io has some problem displaying S2 cells near the poles so I had to remove some cells from the display in the example.
