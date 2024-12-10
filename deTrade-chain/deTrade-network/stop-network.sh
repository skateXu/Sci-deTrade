#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

. scripts/utils.sh

# 结束网络
# Obtain CONTAINER_IDS and remove them
# This function is called when you bring a network down
function clearContainers() {
    infoln "Removing remaining containers"
    docker rm -f $(docker ps -aq --filter label=service=hyperledger-fabric) 2>/dev/null || true
    docker rm -f $(docker ps -aq --filter name='dev-peer*') 2>/dev/null || true
    docker kill "$(docker ps -q --filter name=ccaas)" 2>/dev/null || true
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# This function is called when you bring the network down
function removeUnwantedImages() {
    infoln "Removing generated chaincode docker images"
    docker image rm -f $(docker images -aq --filter reference='dev-peer*') 2>/dev/null || true
}

# Tear down running network
function networkDown() {
    local temp_compose=compose-net.yaml
    #   COMPOSE_FILE_BASE=compose-bft-test-net.yaml
    # COMPOSE_BASE_FILES="-f compose/compose-net.yaml -f compose/docker/docker-compose-net.yaml"
    COMPOSE_BASE_FILES="-f compose/compose-net-org1.yaml \
                    -f compose/compose-net-org2.yaml \
                    -f compose/compose-net-org3.yaml \
                    -f compose/compose-net-org4.yaml \
                    -f compose/compose-net-org5.yaml \
                    -f compose/compose-net-org6.yaml \
                    -f compose/compose-net-org7.yaml \
                    -f compose/compose-net-org8.yaml \
                    -f compose/compose-net-org9.yaml \
                    -f compose/compose-net-org10.yaml \
                    -f compose/compose-net-org11.yaml \
                    -f compose/compose-net-org12.yaml \
                    -f compose/compose-net-org13.yaml \
                    -f compose/compose-net-org14.yaml \
                    -f compose/compose-net-org15.yaml \
                    -f compose/compose-net-org16.yaml \
                    -f compose/compose-net-org17.yaml \
                    -f compose/compose-net-org18.yaml \
                    -f compose/compose-net-org19.yaml \
                    -f compose/compose-net-org20.yaml \
                    -f compose/docker/docker-compose-net.yaml"

    COMPOSE_COUCH_FILES="-f compose/compose-couch.yaml -f compose/docker/docker-compose-couch.yaml"
    COMPOSE_CA_FILES="-f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml"
    COMPOSE_FILES="${COMPOSE_BASE_FILES} ${COMPOSE_COUCH_FILES} ${COMPOSE_CA_FILES}"

    DOCKER_SOCK=$DOCKER_SOCK docker-compose ${COMPOSE_FILES} ${COMPOSE_ORG3_FILES} down --volumes --remove-orphans

    COMPOSE_FILE_BASE=$temp_compose

    # Don't remove the generated artifacts -- note, the ledgers are always removed

    # Bring down the network, deleting the volumes

    # docker volume rm compose_orderer0.orderer.example.com compose_orderer1.orderer.example.com compose_orderer2.orderer.example.com compose_peer0.org1.example.com compose_peer0.org2.example.com compose_peer0.org3.example.com
    # 删除所有与组织相关的卷
    docker volume rm $(docker volume ls -q | grep "compose_.*\.example\.com")

    #Cleanup the chaincode containers
    clearContainers
    #Cleanup images
    removeUnwantedImages
    # remove orderer block and other channel configuration transactions and certs
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations'
    ## remove fabric ca artifacts
    for i in {1..20}; do
        docker run --rm -v "$(pwd):/data" busybox sh -c "cd /data && rm -rf organizations/fabric-ca/org${i}/msp organizations/fabric-ca/org${i}/tls-cert.pem organizations/fabric-ca/org${i}/ca-cert.pem organizations/fabric-ca/org${i}/IssuerPublicKey organizations/fabric-ca/org${i}/IssuerRevocationPublicKey organizations/fabric-ca/org${i}/fabric-ca-server.db"
    done

    # docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/org1/msp organizations/fabric-ca/org1/tls-cert.pem organizations/fabric-ca/org1/ca-cert.pem organizations/fabric-ca/org1/IssuerPublicKey organizations/fabric-ca/org1/IssuerRevocationPublicKey organizations/fabric-ca/org1/fabric-ca-server.db'
    # docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/org2/msp organizations/fabric-ca/org2/tls-cert.pem organizations/fabric-ca/org2/ca-cert.pem organizations/fabric-ca/org2/IssuerPublicKey organizations/fabric-ca/org2/IssuerRevocationPublicKey organizations/fabric-ca/org2/fabric-ca-server.db'
    # docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/org3/msp organizations/fabric-ca/org3/tls-cert.pem organizations/fabric-ca/org3/ca-cert.pem organizations/fabric-ca/org3/IssuerPublicKey organizations/fabric-ca/org3/IssuerRevocationPublicKey organizations/fabric-ca/org3/fabric-ca-server.db'
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/ordererOrg/msp organizations/fabric-ca/ordererOrg/tls-cert.pem organizations/fabric-ca/ordererOrg/ca-cert.pem organizations/fabric-ca/ordererOrg/IssuerPublicKey organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey organizations/fabric-ca/ordererOrg/fabric-ca-server.db'
    # remove channel and script artifacts
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'
}
infoln "Stopping network"
networkDown