#!/usr/bin/env bash

set -x

export SRC_DIR=/ubuntu/resources
export PROJ_DIR=/home/ubuntu

# remove es index
curl -XDELETE 'http://localhost:9200/test1'

# run logstash for test1
# logstash filter -> json / ruby
# You can use ruby for handling data in logstash for that, simply use this site for ruby env.
# https://codepad.remoteinterview.io/BeamingMysteriousRoadOasis

cp $SRC_DIR/logstash/log_list/test1_aws.conf $PROJ_DIR/logstash-2.2.2/log_list/test1.conf
$PROJ_DIR/logstash-2.2.2/bin/logstash -f $PROJ_DIR/logstash-2.2.2/log_list/test1.conf &

# make logstash new data recognized 
cp $PROJ_DIR/data/stats-2017-02-22.log $PROJ_DIR/data/stats-2017-02-23.log

# query with hostname
curl -XPOST 'http://localhost:9200/test1/_search' -d '
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
curl -XPOST 'http://localhost:9200/test1/_search' -d '
{
  "size": 0,
  "query": {
    "range": {
      "timestamp": {
        "from": "2017-03-22T00:59:50.991Z",
        "to": "2017-03-22T01:59:51.991Z"
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

curl -XPOST 'http://localhost:9200/test1/_search' -d '
{
  "size": 0,
  "query": {
    "range": {
      "timestamp": {
        "from": "2017-03-22T00:59:50.991Z",
        "to": "2017-03-22T01:59:51.991Z"
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

# group-by query for test1 json 
# https://docs.google.com/document/d/1LBAhQR59FTWJ9umOKK8B9MugDMw0f2_HnUkPKBSn-kY/edit?usp=sharing

exit 0
