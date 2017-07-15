curl -XGET -u 'elastic:test!323' 'localhost:9200/_template/stats*?pretty'

curl -XDELETE -u 'elastic:test!323' 'localhost:9200/_template/stats?pretty'

# "template": "stats*", : stats로 시작되는 index가 생성될 때 자동 적용됨

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_template/stats?pretty' -d'
{
  "template": "stats*",
  "settings": {
    "number_of_shards": 3
  },
  "aliases": {
    "stats-write": {}
  },
  "mappings": {
	"stats": {
        "properties": {
          "@timestamp": {
            "type": "date"
          },
          "@version": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "action": {
            "type": "string",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
      		"index" : "not_analyzed"
          },
          "country": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
            "fielddata": true
          },
          "date": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
            "fielddata": true
          },
          "geoip": {
            "properties": {
              "city_name": {
                "type": "string",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
          		"index" : "not_analyzed"
              },
              "continent_code": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
            	"fielddata": true
              },
              "coordinates": {
                "type": "geo_point"
              },
              "country_code2": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
            	"fielddata": true
              },
              "country_code3": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
            	"fielddata": true
              },
              "country_name": {
                "type": "string",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
          		"index" : "not_analyzed"
              },
              "dma_code": {
                "type": "long"
              },
              "ip": {
                "type": "string",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
          		"index" : "not_analyzed"
              },
              "latitude": {
                "type": "float"
              },
              "location": {
                "type": "float"
              },
              "longitude": {
                "type": "float"
              },
              "postal_code": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
            	"fielddata": true
              },
              "region_code": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
            	"fielddata": true
              },
              "region_name": {
                "type": "string",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
          		"index" : "not_analyzed"
              },
              "timezone": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                },
            	"fielddata": true
              }
            }
          },
          "host": {
            "type": "string",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
          	"index" : "not_analyzed"
          },
          "ip": {
            "type": "string",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
          	"index" : "not_analyzed"
          },
          "path": {
            "type": "string",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
          	"index" : "not_analyzed"
          },
          "type": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
            "fielddata": true
          },
          "username": {
            "type": "string",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            },
          	"index" : "not_analyzed"
          }

	    }
	  }
      }
    }
  },
  "version": 100
}'


exit 0
