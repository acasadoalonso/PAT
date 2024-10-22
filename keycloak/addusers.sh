echo "=============="
./bin/kcadm.sh config credentials --server http://localhost:8081 --realm master --user admin
echo "=============="
groupid=$(./bin/kcadm.sh get groups -r cpas -F id --noquotes --format CSV)
echo "GroupID:   "$groupid
./bin/kcadm.sh get groups -r cpas
./bin/kcadm.sh create groups/$groupid/children   -r cpas -s name=Europe
./bin/kcadm.sh create groups/$groupid/children   -r cpas -s name=Australia
./bin/kcadm.sh create groups/$groupid/children   -r cpas -s name=USA
./bin/kcadm.sh create groups/$groupid/children   -r cpas -s name=SouthAmerica
./bin/kcadm.sh create groups/$groupid/children   -r cpas -s name=Africa
./bin/kcadm.sh get    groups/$groupid/children   -r cpas
./bin/kcadm.sh get    groups/$groupid/children   -r cpas -F id,name --noquotes --format CSV

./bin/kcadm.sh create users    -r cpas -f conf/user1.json
./bin/kcadm.sh create users    -r cpas -f conf/user2.json
./bin/kcadm.sh create users    -r cpas -f conf/user3.json
echo "=============="
./bin/kcadm.sh get    users    -r cpas
echo "=============="
