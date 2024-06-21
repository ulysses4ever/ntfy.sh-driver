#!/usr/bin/env bash
#
# This script catches the moment when the Submitted status on the given HotCrp subsite changes
#
# Args (in the form of global constants below):
#  - SUBSITE -- HotCrp subsite like "ecoop24"
#  - SESSION -- cookie string for "hotcrpsession"; can get it from Dev console in Firefox using the Storage tab


echo "Hi!"

SUBSITE="oopsla24"
SESSION=""

while [ 1 ];
do
    count=`curl -s --cookie "hotcrpsession=$SESSION" https://$SUBSITE.hotcrp.com/u/0/ | grep -c "Submitted"`

    if [ "$count" == "0" ]
    then
       echo "Updated!"
       curl -d "HotCrp status changed" ntfy.sh/hotcrp
       exit 0   
    fi
    echo -e '\e[1A\e[KNo updates on' $(date) '. Will try in a minute...'
    sleep 60
done
