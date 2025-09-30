#!/usr/bin/env bash
#
# This script catches the moment when the file by the given URL changes
#
# Args (in the form of global constants below):
#  - FILE_URL -- the file to check


echo "Hi!"

FILE_URL="https://careercenter.cra.org/api/v1/jobs?locale=en&page=1&sort=date&country=&state=&city=&zip=&latitude=&longitude=&keywords=&city_state_zip="
NTFY_TAG=crajobs


contents=""
while [ 1 ];
do
    contents1=`curl -s -L "$FILE_URL" | jq . | rg -v "modified_time"`
    echo -e 'Checking for updates on ' $(date) 

    if [[ "$contents" == "" ]]; then
      echo 'No past info (initial run), see you in 3 hours'
      contents="$contents1"
    else
      if [[ "$contents" != "$contents1" ]]; then
        echo 'Updated! Changes:'
        diff <(echo "$contents") <(echo "$contents1") | rg -v '<'
        curl -s -d 'CRA Jobs status changed' ntfy.sh/$NTFY_TAG
        contents="$contents1"
      else
        echo -e 'No updates. Will try in 3 hours...'
      fi
    fi

    sleep 10800
done
