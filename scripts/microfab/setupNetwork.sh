#!/bin/bash

SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # Where the script lives

function networkUp() {
	# networkDown
	export MICRO_FAB_PORT=8085
	export MICRO_FAB_NAME=microfab
	export MICROFAB_CONFIG='{
	"port": '${MICRO_FAB_PORT}',
	"ordering_organization": {
		"name": "Orderer"
	},
	"endorsing_organizations": [
		{
		"name": "Org1"
		},
		{
		"name": "Org2"
		}
	],
	"channels": [
		{
		"name": "mychannel",
		"endorsing_organizations": ["Org1", "Org2"],
		"capability_level": "V1_4_2"
		},
		{
		"name": "mychannel20",
		"endorsing_organizations": ["Org1", "Org2"],
		"capability_level": "V2_0"
		}
	]
	}'

    MICROFAB_IMAGE="ibmcom/ibp-microfab"
echo $MICROFAB_CONFIG
    docker run -d \
        -p $MICRO_FAB_PORT:$MICRO_FAB_PORT \
        --name ${MICRO_FAB_NAME} \
        -e MICROFAB_CONFIG \
        ${MICROFAB_IMAGE}
}

function networkDown() {
	docker stop microfab
	docker rm microfab
}

function printHelp() {
 echo "./startNetwork up"
 echo "./startNetwork down"
}
## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then
  networkDown
else
  printHelp
  exit 1
fi
