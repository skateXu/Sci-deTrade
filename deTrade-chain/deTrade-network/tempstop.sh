#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

. scripts/utils.sh
# Get docker sock path from environment variable
SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
DOCKER_SOCK="${SOCK##unix://}"

# set the Global variable
CHANNEL_NAME="mychannel"
CRYPTO_MODE="Certificate Authorities"
CC_NAME="datatrading"
CC_SRC_PATH="../datatrading-chaincode/chaincode-go/"
CC_SRC_LANGUAGE="go"
# CC_VERSION = "1.0.1"
# CC_SEQUENCE = "auto"
# CC_INIT_FCN = "NA"
# CC_END_POLICY = "NA"
# CC_COLL_CONFIG = "NA"
# DATABASE = "leveldb"
# MAX_RETRY = 5
# CLI_DELAY = 3

# 组织和节点数量
Org_Count=2 
Peer_Count=2
Flag=1
# -n不保留组织文件
if [ "$1" = "-n" ]; then
  Flag=0
fi


# Stop the network
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
    # 根据组织数量动态生成compose文件路径
    for ((i=1; i<=$Org_Count; i++)); do
        declare "COMPOSE_FILES_${i}=-f compose/compose-net-org${i}.yaml \
                    -f compose/docker/docker-compose-net-org${i}.yaml"
    done

    COMPOSE_FILES_orderer="-f compose/compose-net-orderer.yaml"
    COMPOSE_FILES_ca="-f compose/compose-ca.yaml \
                    -f compose/docker/docker-compose-ca.yaml "


    COMPOSE_FILES=""
    for ((i=1; i<=$Org_Count; i++)); do
        eval "COMPOSE_FILES=\"\${COMPOSE_FILES}\${COMPOSE_FILES_$i}\""
    done
    COMPOSE_FILES="${COMPOSE_FILES}${COMPOSE_FILES_orderer}${COMPOSE_FILES_ca}"

    DOCKER_SOCK=$DOCKER_SOCK docker-compose ${COMPOSE_FILES} down --volumes --remove-orphans

    # Don't remove the generated artifacts -- note, the ledgers are always removed

    # Bring down the network, deleting the volumes

    # docker volume rm compose_orderer0.orderer.example.com compose_orderer1.orderer.example.com compose_orderer2.orderer.example.com compose_peer0.org1.example.com compose_peer0.org2.example.com compose_peer0.org3.example.com
  

    #Cleanup the chaincode containers
    clearContainers

    # 删除所有与组织相关的卷
    docker volume rm $(docker volume ls -q | grep "compose_.*\.example\.com")
    docker volume rm $(docker volume ls -q | grep "compose-.*\.example\.com")

    #Cleanup images
    removeUnwantedImages
    # 删除生成的组织文件
    if [ $Flag -eq 0 ]; then
        # remove orderer block and other channel configuration transactions and certs
        docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations'
    fi
    # 删除组织ca证书
    if [ $Flag -eq 0 ]; then
    # remove fabric ca artifacts
        for i in {1..$Org_Count}; do
            docker run --rm -v "$(pwd):/data" busybox sh -c "cd /data && rm -rf organizations/fabric-ca/org${i}/msp organizations/fabric-ca/org${i}/tls-cert.pem organizations/fabric-ca/org${i}/ca-cert.pem organizations/fabric-ca/org${i}/IssuerPublicKey organizations/fabric-ca/org${i}/IssuerRevocationPublicKey organizations/fabric-ca/org${i}/fabric-ca-server.db"
        done

        docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/ordererOrg/msp organizations/fabric-ca/ordererOrg/tls-cert.pem organizations/fabric-ca/ordererOrg/ca-cert.pem organizations/fabric-ca/ordererOrg/IssuerPublicKey organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey organizations/fabric-ca/ordererOrg/fabric-ca-server.db'
    fi

    # remove channel and script artifacts
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'
}


infoln "Stopping network"
networkDown