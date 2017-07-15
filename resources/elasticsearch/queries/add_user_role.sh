curl -XGET -u 'elastic:test!323' 'localhost:9200/_xpack/security/role/logstash_writer'

curl -XGET -u 'elastic:test!323' 'localhost:9200/_xpack/security/role/logstash_writer'



curl -XDELETE -u 'elastic:test!323' 'localhost:9200/_xpack/security/role/logstash_writer'

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/role/logstash_writer' -d '
{
  "cluster": ["manage_index_templates", "monitor"],
  "indices": [
    {
      "names": [ "nginx*" ], 
      "privileges": ["write","delete","create_index"]
    },
    {
      "names": [ "stats*" ], 
      "privileges": ["write","delete","create_index"]
    }
  ]
}'

curl -XDELETE -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_internal'

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_internal' -d '
{
  "password" : "test!323",
  "roles" : [ "logstash_writer", "logstash_system" ],
  "full_name" : "Internal Logstash User"
}'

#PUT _xpack/security/user/logstash_system/_enable
curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_system/_enable'
curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_internal/_enable'

curl -XGET -u 'elastic:test!323' 'localhost:9200/_xpack/security/role/logstash_writer?pretty'
curl -XGET -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_internal?pretty'

- get user info
curl -XGET -u 'elastic:test!323' 'localhost:9200/_xpack/security/user?pretty'
curl -XGET -u 'elastic:test!323' 'localhost:9200/_xpack/security/role?pretty'

exit 0

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d '{
  "password" : "test!323"
}'

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/kibana/_password' -H "Content-Type: application/json" -d '{
  "password" : "test!323"
}'

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_system/_password' -H "Content-Type: application/json" -d '{
  "password" : "test!323"
}'

curl -XPUT -u 'elastic:test!323' 'localhost:9200/_xpack/security/user/logstash_internal/_password' -H "Content-Type: application/json" -d '{
  "password" : "test!323"
}'

cd /usr/share/es1/bin/x-pack
./users passwd elastic -p test!323
./users passwd kibana -p test!323
./users passwd logstash_system -p test!323
./users passwd logstash_internal -p test!323
./users useradd <username> -p <password>
./users useradd <username> -r <comma-separated list of role names>





