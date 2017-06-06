curl -XPOST 'http://localhost:9200/stats/_search?pretty' -d '
{
  "_source": false,
  "query": {
    "range": {
      "@timestamp": {
        "from": 1496242074825,
        "to": 1496252428269
      }
    }
  },
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "geoip.city_name"
      }
    }
  }
}
'