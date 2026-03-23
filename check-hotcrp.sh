#!/usr/bin/env bash
#
# This script catches the moment when the Submitted status on the given HotCrp subsite changes
#
# Args (in the form of global constants below):
#  - SUBSITE -- HotCrp subsite like "ecoop24"
#  - SESSION -- cookie string for "hotcrpsession"; can get it from Dev console in Firefox using the Storage tab


echo "Hi!"

SUBSITE="ics2026-cycle-2"
SESSION=""

while [ 1 ];
do
    count=`curl -s --cookie "hotcrpsession=$SESSION" https://$SUBSITE.hotcrp.com | grep -c "Submitted"`

    if [ "$count" == "0" ]
    then
       echo "Updated!"
       curl -sd "HotCrp status changed" ntfy.sh/hotcrp 1>/dev/null 2>&1
       exit 0   
    fi
    echo -e '\e[1A\e[KNo updates on' $(date) '. Will try in 5 minutes...'
    sleep 300
done
