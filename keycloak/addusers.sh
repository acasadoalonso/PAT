echo "=============="
./bin/kcadm.sh config credentials --server http://localhost:8081 --realm master --user admin
echo "=============="
export CPASgroupid=$(./bin/kcadm.sh get groups -r cpas -F id --noquotes --format CSV)
echo "CPASGroupID:   "$CPASgroupid
./bin/kcadm.sh get groups -r cpas
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=Europe
export EUgroupid=$(./bin/kcadm.sh get groups/$CPASgroupid/children -r cpas -F id --noquotes --format CSV)
echo "EUGroupID:   "$EUgroupid
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Spain
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=France
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=UK
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=Australia
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=USA
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=SouthAmerica
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=Africa
./bin/kcadm.sh get    groups/$CPASgroupid/children   -r cpas
./bin/kcadm.sh get    groups/$CPASgroupid/children   -r cpas -F id,name --noquotes --format CSV

./bin/kcadm.sh create users    -r cpas -f conf/user1.json
./bin/kcadm.sh create users    -r cpas -f conf/user2.json
./bin/kcadm.sh create users    -r cpas -f conf/user3.json
echo "=============="
./bin/kcadm.sh get    users    -r cpas
echo "=============="
