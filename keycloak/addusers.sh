echo "=============="
./bin/kcadm.sh config credentials --server http://localhost:8081 --realm master --user admin
echo "=============="
./bin/kcadm.sh create users    -r cpas -f conf/user1.json
./bin/kcadm.sh create users    -r cpas -f conf/user2.json
./bin/kcadm.sh create users    -r cpas -f conf/user3.json
echo "=============="
./bin/kcadm.sh get    users    -r cpas
echo "=============="
