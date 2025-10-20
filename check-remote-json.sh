#!/usr/bin/env bash
#
# This script catches the moment when the file by the given URL changes
#
# Args (in the form of global constants below):
#  - FILE_URL -- the file to check
#  - NTFY_TAG -- the tag to use for ntfy.sh notifications
# Other tunable parameters:
#  - jq expression -- how to extract the relevant part of the file;
#    this is not factored out but see the curl-line below
#  - sleep time -- how often to check (currently 1 hour)


echo "Hi!"

FILE_URL="https://careercenter.cra.org/api/v1/jobs?locale=en&page=1&sort=date&country=&state=&city=&zip=&latitude=&longitude=&keywords=&city_state_zip="
NTFY_TAG=crajobs


contents=""
ERASELINE='\033[1A\033[2K'
maybeerase=""
while true;
do
    contents1=$(curl -s -L "$FILE_URL" | jq '.data | map({title: .title, place: .company.name})')
    echo -e "${maybeerase}Checking for updates on " "$(date)"

    if [[ "$contents" == "" ]]; then                        # first run
      echo 'No past info (initial run), see you in 1 hour'
      contents="$contents1"
      maybeerase="${ERASELINE}${ERASELINE}"
    else                                                   # subsequent runs
      if [[ "$contents" != "$contents1" ]]; then           # changed
        echo -e "${maybeerase}Updated! Changes:"
        df=$(diff <(echo -e "$contents") <(echo "$contents1") | rg -v '<')
        dfclean=$(echo -e "$df" | sed '1d;$d' | sed 's/^>   //' | head -n -2)
        echo -e "$dfclean"
        curl -s -d "CRA Jobs status changed:
${dfclean}" ntfy.sh/$NTFY_TAG 1>/dev/null 2>&1
        contents="$contents1"
        maybeerase=""
      else                                                  # not changed
        echo -e 'No updates. Will try in 1 hour...'
        maybeerase="${ERASELINE}${ERASELINE}"
      fi
    fi

    sleep 3600
done
