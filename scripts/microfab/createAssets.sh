#!/bin/bash

SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # Where the script lives

WORK_AREA=${SRC_DIR}/../workarea1
rm -fr ${WORK_AREA}
mkdir -p ${WORK_AREA}/assets/Certificate_Authorities
mkdir -p ${WORK_AREA}/assets/Ordering_Services
mkdir -p ${WORK_AREA}/assets/Peers
mkdir -p ${WORK_AREA}/assets/Organizations

ASSETS_ROOT=${WORK_AREA}/assets
TEMPLATE_ROOT=${SRC_DIR}/../../common/templates

MICRO_FAB_OUTPUT=${WORK_AREA}/microfab_all.json

curl -k http://console.127-0-0-1.nip.io:8085/ak/api/v1/components | jq > ${MICRO_FAB_OUTPUT}

ORG1_ROOT_CERT=`jq '.[] | select(.id == "org1admin").ca' ${MICRO_FAB_OUTPUT} -r`
ORG2_ROOT_CERT=`jq '.[] | select(.id == "org2admin").ca' ${MICRO_FAB_OUTPUT} -r`
ORDERER_ROOT_CERT=`jq '.[] | select(.id == "ordereradmin").ca' ${MICRO_FAB_OUTPUT} -r`

# Create CA Imports
ORG1CA_API_URL="http://org1ca-api.127-0-0-1.nip.io:8085"
ORG1CA_OPS_URL="http://org1ca-operations.127-0-0-1.nip.io:8085"

jq --arg ORG1_ROOT_CERT "$ORG1_ROOT_CERT" \
   --arg ORG1CA_API_URL "$ORG1CA_API_URL" \
   --arg ORG1CA_OPS_URL "$ORG1CA_OPS_URL" \
		'.tls_cert = $ORG1_ROOT_CERT | .ca_url = $ORG1CA_API_URL | .api_url = $ORG1CA_API_URL | .operations_url = $ORG1CA_OPS_URL | .ca_name = "ca" | .tlsca_name = "ca"' \
		${TEMPLATE_ROOT}/Certificate_Authorities/org1ca-local_ca.json > ${ASSETS_ROOT}/Certificate_Authorities/org1ca-local_ca.json

ORG2CA_API_URL="http://org2ca-api.127-0-0-1.nip.io:8085"
ORG2CA_OPS_URL="http://org2ca-operations.127-0-0-1.nip.io:8085"

jq --arg ORG2_ROOT_CERT "$ORG2_ROOT_CERT" \
   --arg ORG2CA_API_URL "$ORG2CA_API_URL" \
   --arg ORG2CA_OPS_URL "$ORG2CA_OPS_URL" \
		'.tls_cert = $ORG2_ROOT_CERT | .ca_url = $ORG2CA_API_URL | .api_url = $ORG2CA_API_URL | .operations_url = $ORG2CA_OPS_URL | .ca_name = "ca" | .tlsca_name = "ca"' \
		${TEMPLATE_ROOT}/Certificate_Authorities/org2ca-local_ca.json > ${ASSETS_ROOT}/Certificate_Authorities/org2ca-local_ca.json

# Create Peer Imports
ORG1PEER_API_URL="http://org1peer-api.127-0-0-1.nip.io:8085"
ORG1PEER_OPS_URL="http://org1peer-operations.127-0-0-1.nip.io:8085"
ORG1PEER_GRPC_URL="http://org1peer-api.127-0-0-1.nip.io:8085"

jq --arg ORG1_ROOT_CERT "$ORG1_ROOT_CERT" \
   --arg ORG1PEER_API_URL "$ORG1PEER_API_URL" \
   --arg ORG1PEER_OPS_URL "$ORG1PEER_OPS_URL" \
   --arg ORG1PEER_GRPC_URL "$ORG1PEER_GRPC_URL" \
	'.msp.component.tls_cert = $ORG1_ROOT_CERT | .msp.ca.root_certs[0] = $ORG1_ROOT_CERT | .msp.tlsca.root_certs[0] = $ORG1_ROOT_CERT | .pem = $ORG1_ROOT_CERT | .tls_cert = $ORG1_ROOT_CERT | .tls_ca_root_cert = $ORG1_ROOT_CERT | .api_url = $ORG1PEER_API_URL | .operations_url = $ORG1PEER_OPS_URL | .grpcwp_url = $ORG1PEER_GRPC_URL' \
	${TEMPLATE_ROOT}/Peers/org1_peer1-local_peer.json > ${ASSETS_ROOT}/Peers/org1_peer1-local_peer.json

ORG2PEER_API_URL="http://org2peer-api.127-0-0-1.nip.io:8085"
ORG2PEER_OPS_URL="http://org2peer-operations.127-0-0-1.nip.io:8085"
ORG2PEER_GRPC_URL="http://org2peer-api.127-0-0-1.nip.io:8085"

jq --arg ORG2_ROOT_CERT "$ORG2_ROOT_CERT" \
   --arg ORG2PEER_API_URL "$ORG2PEER_API_URL" \
   --arg ORG2PEER_OPS_URL "$ORG2PEER_OPS_URL" \
   --arg ORG2PEER_GRPC_URL "$ORG2PEER_GRPC_URL" \
	'.msp.component.tls_cert = $ORG2_ROOT_CERT | .msp.ca.root_certs[0] = $ORG2_ROOT_CERT | .msp.tlsca.root_certs[0] = $ORG2_ROOT_CERT | .pem = $ORG2_ROOT_CERT | .tls_cert = $ORG2_ROOT_CERT | .tls_ca_root_cert = $ORG2_ROOT_CERT | .api_url = $ORG2PEER_API_URL | .operations_url = $ORG2PEER_OPS_URL | .grpcwp_url = $ORG2PEER_GRPC_URL' \
	${TEMPLATE_ROOT}/Peers/org2_peer1-local_peer.json > ${ASSETS_ROOT}/Peers/org2_peer1-local_peer.json

# Create Orderer Imports
ORDERER_API_URL="http://orderer-api.127-0-0-1.nip.io:8085"
ORDERER_OPS_URL="http://orderer-operations.127-0-0-1.nip.io:8085"
ORDERER_GRPC_URL="http://orderer-api.127-0-0-1.nip.io:8085"
jq --arg ORDERER_ROOT_CERT "$ORDERER_ROOT_CERT" \
   --arg ORDERER_API_URL "$ORDERER_API_URL" \
   --arg ORDERER_OPS_URL "$ORDERER_OPS_URL" \
   --arg ORDERER_GRPC_URL "$ORDERER_GRPC_URL" \
	'.msp.component.tls_cert = $ORDERER_ROOT_CERT | .msp.ca.root_certs[0] = $ORDERER_ROOT_CERT | .msp.tlsca.root_certs[0] = $ORDERER_ROOT_CERT | .pem = $ORDERER_ROOT_CERT | .tls_cert = $ORDERER_ROOT_CERT | .tls_ca_root_cert = $ORDERER_ROOT_CERT | .api_url = $ORDERER_API_URL | .operations_url = $ORDERER_OPS_URL | .grpcwp_url = $ORDERER_GRPC_URL' \
	${TEMPLATE_ROOT}/Ordering_Services/orderer-local_orderer.json > ${ASSETS_ROOT}/Ordering_Services/orderer-local_orderer.json

# Create MSP Imports
jq --arg ORG1_ROOT_CERT "$ORG1_ROOT_CERT" \
	'.root_certs[0] = $ORG1_ROOT_CERT | .tls_root_certs[0] = $ORG1_ROOT_CERT | .fabric_node_ous.admin_ou_identifier.certificate = $ORG1_ROOT_CERT | .fabric_node_ous.client_ou_identifier.certificate = $ORG1_ROOT_CERT | .fabric_node_ous.orderer_ou_identifier.certificate = $ORG1_ROOT_CERT | .fabric_node_ous.peer_ou_identifier.certificate = $ORG1_ROOT_CERT' \
	${TEMPLATE_ROOT}/Organizations/org1msp_msp.json > ${ASSETS_ROOT}/Organizations/org1msp_msp.json

jq --arg ORG2_ROOT_CERT "$ORG2_ROOT_CERT" \
	'.root_certs[0] = $ORG2_ROOT_CERT | .tls_root_certs[0] = $ORG2_ROOT_CERT | .fabric_node_ous.admin_ou_identifier.certificate = $ORG2_ROOT_CERT | .fabric_node_ous.client_ou_identifier.certificate = $ORG2_ROOT_CERT | .fabric_node_ous.orderer_ou_identifier.certificate = $ORG2_ROOT_CERT | .fabric_node_ous.peer_ou_identifier.certificate = $ORG2_ROOT_CERT' \
	${TEMPLATE_ROOT}/Organizations/org2msp_msp.json > ${ASSETS_ROOT}/Organizations/org2msp_msp.json

jq --arg ORDERER_ROOT_CERT "$ORDERER_ROOT_CERT" \
	'.root_certs[0] = $ORDERER_ROOT_CERT | .tls_root_certs[0] = $ORDERER_ROOT_CERT | .fabric_node_ous.admin_ou_identifier.certificate = $ORDERER_ROOT_CERT | .fabric_node_ous.client_ou_identifier.certificate = $ORDERER_ROOT_CERT | .fabric_node_ous.orderer_ou_identifier.certificate = $ORDERER_ROOT_CERT | .fabric_node_ous.peer_ou_identifier.certificate = $ORDERER_ROOT_CERT' \
	${TEMPLATE_ROOT}/Organizations/orderermsp_msp.json > ${ASSETS_ROOT}/Organizations/orderermsp_msp.json

cd ${WORK_AREA}
zip -r console_assets.zip ./assets/*
