#!/bin/bash

URL_BASE="http://localhost:8090/nifi-api/"

CONTEXT_UPLOAD="process-groups/root/templates/upload"
CONTEXT_INSTANCE="process-groups/root/template-instance"
CONTEXT_STARTING="flow/process-groups/"

#Initial states available: RUNNING | STOPPED | ENABLED | DISABLED
START_STATE_PROCESSOR="STOPPED"

#Position flow, remove the first 4 numbers from ORIGIN_X
ORIGIN_X=".2377052352963"
ORIGIN_Y="1315.657773876809"

#Add templates here
TEMPLATES=( "{path-here}/fast-nifi/templates/FAST.xml" )

for template in ${TEMPLATES[*]};
do

#Generate randon position X
RANDON_X=$(( ( RANDOM % 2 )  + 1 ))$(( ( RANDOM % 1000 )  + 1 ))${ORIGIN_X}

UPLOAD_TEMPLATE=$(curl -L -w "%{http_code} %{url_effective}\\n" -X POST -F "template=@${template}" ${URL_BASE}${CONTEXT_UPLOAD} --header "Content-Type:multipart/form-data") 
#Get ID template from response upload
ID_TEMPLATE=$(echo "${UPLOAD_TEMPLATE}" | grep -Po '(?<=<id>).*(?=</id>)')

INSTANCE_TEMPLATE=$(curl -L -w "%{http_code} %{url_effective}\\n" -X POST -d "{\"originX\": ${RANDON_X},\"originY\": ${ORIGIN_Y},\"templateId\":\"${ID_TEMPLATE}\"}" "${URL_BASE}${CONTEXT_INSTANCE}" --header "Content-Type:application/json")
#Get group ID response instance
ID_GROUP=$(echo "${INSTANCE_TEMPLATE}" | grep -Po '(?<="id":").*(?=","uri")')

STARTING_PROCESSORS="curl -i -X PUT -H 'Content-Type: application/json' -d '{\"id\":\"${ID_GROUP}\",\"state\":\"${START_STATE_PROCESSOR}\"}' ${URL_BASE}${CONTEXT_STARTING}${ID_GROUP}"
eval "${STARTING_PROCESSORS}"

done;
