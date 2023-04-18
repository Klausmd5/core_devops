#!/bin/bash -eu

conf=$(cat './mainframe-config.json')
search='https'
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

for id in $(echo "$conf" | jq -r '.plugins | keys[]'); do

    plugin_url=$(echo "$conf" | jq -r ".plugins[\"$id\"] .repoUrl //null")

    if grep -q "$search" <<<"$plugin_url"; then

        echo "Checking URL $id"

        status_code=$(curl --write-out %{http_code} --silent --output /dev/null ${plugin_url}"/releases/latest")

        if [[ "$status_code" == 302 ]]; then
            echo -e "${GREEN}OK... $status_code ${ENDCOLOR}"
        else
            echo -e "${RED}ERROR invalid URL... $status_code ${ENDCOLOR}"
            exit 0
        fi

    fi

done
