#!/usr/bin/env bash

set -x

# remove es index
curl -XDELETE 'http://192.168.82.170:9200/derp'

# run logstash for derp
# logstash filter -> json / ruby
# You can use ruby for handling data in logstash for that, simply use this site for ruby env.
# https://codepad.remoteinterview.io/BeamingMysteriousRoadOasis
cp $SRC_DIR/logstash/log_list/derp.conf $PROJ_DIR/logstash-2.2.2/log_list
$PROJ_DIR/logstash-2.2.2/bin/logstash -f $PROJ_DIR/logstash-2.2.2/log_list/derp.conf &

# make logstash new data recognized 
cp $PROJ_DIR/data/stats-2016-01-22.log stats-2016-01-23.log

# query with hostname
curl -XPOST 'http://192.168.82.170:9200/derp/_search' -d '
{
	  "size" : 10,
    "query" : {
        "term" : { "hostname" : "healthcheck.xdn.com" }
    }
}
'
# group by query
# SELECT COUNT(1) CNT, user_id
# FROM LOG 
# GROUP BY user_id
# WHERE timestamp A FROM B
# ORDER BY CNT DESC
curl -XPOST 'http://192.168.82.170:9200/derp/_search' -d '
{
  "size": 0,
  "query": {
    "range": {
      "timestamp": {
        "from": "2016-01-22T00:59:50.991Z",
        "to": "2016-01-22T01:59:51.991Z"
      }
    }
  },
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "user_id"
      }
    }
  }
}
'
# multiple keys group by query
#
# SELECT COUNT(1) CNT, hostname, client_ip
# FROM LOG 
# GROUP BY hostname, client_ip
# WHERE timestamp A FROM B
# ORDER BY CNT DESC

curl -XPOST 'http://192.168.82.170:9200/derp/_search' -d '
{
  "size": 0,
  "query": {
    "range": {
      "timestamp": {
        "from": "2016-01-22T00:59:50.991Z",
        "to": "2016-01-22T01:59:51.991Z"
      }
    }
  },
  "aggs": {
    "agg1": {
      "terms": {
        "field": "hostname"
      },
      "aggs": {
        "agg2": {
          "terms": {
            "field": "user_id"
          }         
        }
      }
    }
  }
}
'

# group-by query for derp json 
# https://docs.google.com/document/d/1LBAhQR59FTWJ9umOKK8B9MugDMw0f2_HnUkPKBSn-kY/edit?usp=sharing

exit 0
