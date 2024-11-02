
echo
echo "Add groupd, users and roles to the CPAS master ..."
echo
echo "Get the credentials first ... "
./bin/kcadm.sh config credentials --server http://localhost:8081 --realm master --user admin
echo "=============="
export CPASgroupid=$(./bin/kcadm.sh get groups -r cpas -F id --noquotes --format CSV)
echo "CPASGroupID:   "$CPASgroupid
echo "Get groups ..."
./bin/kcadm.sh get groups -r cpas
echo "Create Europe Group ..."
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=Europe
export EUgroupid=$(./bin/kcadm.sh get groups/$CPASgroupid/children -r cpas -F id --noquotes --format CSV)
echo "EUGroupID:   "$EUgroupid
echo "Create the countries within Europe"
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Spain
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=France
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=UK
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Italy
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Poland
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Germany
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Sweeden
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Belgium
./bin/kcadm.sh create groups/$EUgroupid/children     -r cpas -s name=Slovenia
echo "Create Continents Group ..."
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=Australia
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=USA
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=SouthAmerica
./bin/kcadm.sh create groups/$CPASgroupid/children   -r cpas -s name=Africa
echo "=============="
./bin/kcadm.sh get    groups/$CPASgroupid/children   -r cpas
./bin/kcadm.sh get    groups/$CPASgroupid/children   -r cpas -F id,name --noquotes --format CSV

echo "=============="
echo "Create roles ..."
./bin/kcadm.sh create roles    -r cpas -s name=user_Spain     -s 'description=The Spaniars'
./bin/kcadm.sh create roles    -r cpas -s name=user_France    -s 'description=The Frenchies'
./bin/kcadm.sh create roles    -r cpas -s name=user_USA       -s 'description=The Americans'
./bin/kcadm.sh create roles    -r cpas -s name=user_Australia -s 'description=The down under folks'
./bin/kcadm.sh create roles    -r cpas -s name=user_UK        -s 'description=The Brits'
./bin/kcadm.sh create roles    -r cpas -s name=user_Germany   -s 'description=The Germans'
./bin/kcadm.sh create roles    -r cpas -s name=user_Italy     -s 'description=The Italians'
./bin/kcadm.sh create roles    -r cpas -s name=user_Slovenia  -s 'description=The Slovenians'
./bin/kcadm.sh get-roles       -r cpas

echo "=============="
echo "Create users ... "

./bin/kcadm.sh create users    -r cpas -f conf/user1.json
./bin/kcadm.sh create users    -r cpas -f conf/user2.json
./bin/kcadm.sh create users    -r cpas -f conf/user3.json
echo "=============="
./bin/kcadm.sh get    users    -r cpas
echo "=============="
echo "Update roles of users."
./bin/kcadm.sh get-roles -r cpas --uusername admin
./bin/kcadm.sh get-roles -r cpas --uusername angel
./bin/kcadm.sh get-roles -r cpas --uusername john
./bin/kcadm.sh add-roles --uusername angel --rolename user           -r cpas
./bin/kcadm.sh add-roles --uusername angel --rolename user_Spain     -r cpas
./bin/kcadm.sh add-roles --uusername angel --rolename user_France    -r cpas
./bin/kcadm.sh add-roles --uusername john  --rolename user           -r cpas
./bin/kcadm.sh add-roles --uusername john  --rolename user_Australia -r cpas
echo "=============="
./bin/kcadm.sh get-roles -r cpas --uusername angel
./bin/kcadm.sh get-roles -r cpas --uusername john
echo "=============="

