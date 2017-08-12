curl -XGET -u 'elastic:passwd323' 'localhost:9200/_xpack/security/role/logstash_writer'

curl -XGET -u 'elastic:passwd323' 'localhost:9200/_xpack/security/role/logstash_writer'



curl -XDELETE -u 'elastic:passwd323' 'localhost:9200/_xpack/security/role/logstash_writer'

curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/role/logstash_writer' -d '
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

curl -XDELETE -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_internal'

curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_internal' -d '
{
  "password" : "passwd323",
  "roles" : [ "logstash_writer", "logstash_system" ],
  "full_name" : "Internal Logstash User"
}'

#PUT _xpack/security/user/logstash_system/_enable
curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_system/_enable'
curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_internal/_enable'

curl -XGET -u 'elastic:passwd323' 'localhost:9200/_xpack/security/role/logstash_writer?pretty'
curl -XGET -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_internal?pretty'

- get user info
curl -XGET -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user?pretty'
curl -XGET -u 'elastic:passwd323' 'localhost:9200/_xpack/security/role?pretty'

exit 0

curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d '{
  "password" : "passwd323"
}'

curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/kibana/_password' -H "Content-Type: application/json" -d '{
  "password" : "passwd323"
}'

curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_system/_password' -H "Content-Type: application/json" -d '{
  "password" : "passwd323"
}'

curl -XPUT -u 'elastic:passwd323' 'localhost:9200/_xpack/security/user/logstash_internal/_password' -H "Content-Type: application/json" -d '{
  "password" : "passwd323"
}'

# xpack
cd /usr/share/$ES/bin
./elasticsearch-plugin install -b x-pack
./elasticsearch-plugin remove x-pack; rm -Rf /etc/elasticsearch/x-pack
update-rc.d $ES defaults 95 10
service $ES stop
service $ES start

cd /usr/share/$ES/bin/x-pack
./users passwd elastic -p 'passwd323'
./users passwd kibana -p 'passwd323'
./users passwd logstash_system -p 'passwd323'
./users passwd logstash_internal -p 'passwd323'
./users useradd <username> -p <password>
./users useradd <username> -r <comma-separated list of role names>

