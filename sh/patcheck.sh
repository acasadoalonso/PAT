#!/bin/bash
pnum=$(pgrep -x -f "/usr/bin/node server/server.js" )
pcount=$(pgrep -a node | wc -l)
pnode=5
type -p /usr/bin/nsolid >>/dev/null && unset pnode && pnode=3 && echo $pnode
if [[ $pcount == $pnode ]] 								# if PAT interface is  not running
then
    logger -t $0 "PAT is alive"
    echo $0 "PAT is alive ID: "$pnum $USER
    echo $0 "PAT is alive ID: "$pnum $(date) >>/tmp/pat.log

else
    echo $0 "PAT is NOT alive:  "$pcount  $USER
    echo $0 "PAT is NOT alive:  "$pcount $(date) >>/tmp/pat.log 
	#               restart OGN data collector
    logger -t $0 "PAT seems down, restarting"
    date >>/tmp/.PATrangerestart.log
    (pkill node && cd ~/src/pat/patServer && bash runme.sh >>/tmp/pat.log 2>&1 &)
fi

pnumj=$(pgrep java )
pcountj=$(pgrep java | wc -l)

if [ $pcountj == 1 ] 								# if KC interface is  not running
then
    logger -t $0 "KC is alive"
    echo $0 "KC is alive ID: "$pnumj $USER
    echo $0 "KC is alive ID: "$pnumj $(date) >>/tmp/pat.log

else
    echo $0 "KC is NOT alive:  "$pcountj  $USER
    echo $0 "KC is NOT alive:  "$pcountj $(date) >>/tmp/pat.log 
    logger -t $0 "KC seems down, restarting"
    date >>/tmp/.PATrangerestart.log
    KCHOST=$(hostname -I | awk '{ print $1 }' | tail -n1)
    (~/src/*$KCversion/bin/kc.sh --verbose start-dev --http-host $KCHOST --http-port 8081  --http-enabled true --https-client-auth none &)
fi

/bin/echo '/bin/bash ~/src/sh/patcheck.sh ' | at -M $(date +%H:%M)+ 5 minutes    # check every 5 minutes



