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

# 加载default
. ./network.config

# 参数设置
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

# 检查Fabric环境配置、添加DNS解析
function checkPrereqs() {
    ## Check if your have cloned the peer binaries and configuration files.
    peer version >/dev/null 2>&1

    if [[ $? -ne 0 || ! -d "../config" ]]; then
        errorln "Peer binary and configuration files not found.."
        errorln
        errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
        errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
        exit 1
    fi

    LOCAL_VERSION=$(peer version | sed -ne 's/^ Version: //p')
    DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-peer:latest peer version | sed -ne 's/^ Version: //p')

    infoln "LOCAL_VERSION=$LOCAL_VERSION"
    infoln "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

    if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
        warnln "Local fabric binaries and docker images are out of  sync. This may cause problems."
    fi

    for UNSUPPORTED_VERSION in $NONWORKING_VERSIONS; do
        infoln "$LOCAL_VERSION" | grep -q $UNSUPPORTED_VERSION
        if [ $? -eq 0 ]; then
            fatalln "Local Fabric binary version of $LOCAL_VERSION does not match the versions supported by the test network."
        fi

        infoln "$DOCKER_IMAGE_VERSION" | grep -q $UNSUPPORTED_VERSION
        if [ $? -eq 0 ]; then
            fatalln "Fabric Docker image version of $DOCKER_IMAGE_VERSION does not match the versions supported by the test network."
        fi
    done

    ## Check for fabric-ca
    fabric-ca-client version >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        errorln "fabric-ca-client binary not found.."
        errorln
        errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
        errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
        exit 1
    fi
    CA_LOCAL_VERSION=$(fabric-ca-client version | sed -ne 's/ Version: //p')
    CA_DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-ca:latest fabric-ca-client version | sed -ne 's/ Version: //p' | head -1)
    infoln "CA_LOCAL_VERSION=$CA_LOCAL_VERSION"
    infoln "CA_DOCKER_IMAGE_VERSION=$CA_DOCKER_IMAGE_VERSION"

    if [ "$CA_LOCAL_VERSION" != "$CA_DOCKER_IMAGE_VERSION" ]; then
        warnln "Local fabric-ca binaries and docker images are out of sync. This may cause problems."
    fi

    ## set DNS
    # . scripts/setDNS.sh
    # infoln "set DNS for network"

}
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
    COMPOSE_BASE_FILES="-f compose/compose-net-orderer.yaml \
                    -f compose/compose-net-org1.yaml \
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

# 创建组织证书
function createOrgs() {
    if [ -d "organizations/peerOrganizations" ]; then
        rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
    fi

    infoln "Generating certificates using Fabric CA"
    docker-compose -f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml up -d 2>&1

    . scripts/registerEnroll.sh

    #通过轮询检查 tls-cert.pem 文件是否生成，确保 CA 服务已完全启动并准备就绪,调用registerEnroll.sh的函数
    while :; do
        if [ ! -f "organizations/fabric-ca/org1/tls-cert.pem" ]; then
            sleep 1
        else
            break
        fi
    done
    
    infoln "Creating Org1 Identities"
    createOrg "org1" "7054" "ca-org1"

    infoln "Creating Org2 Identities"
    createOrg "org2" "8054" "ca-org2"

    infoln "Creating Org3 Identities"
    createOrg "org3" "9054" "ca-org3"

    infoln "Creating Org4 Identities"
    createOrg "org4" "10054" "ca-org4"

    infoln "Creating Org5 Identities"
    createOrg "org5" "11054" "ca-org5"

    infoln "Creating Org6 Identities"
    createOrg "org6" "12054" "ca-org6"

    infoln "Creating Org7 Identities"
    createOrg "org7" "13054" "ca-org7"

    infoln "Creating Org8 Identities"
    createOrg "org8" "14054" "ca-org8"

    infoln "Creating Org9 Identities"
    createOrg "org9" "15054" "ca-org9"

    infoln "Creating Org10 Identities"
    createOrg "org10" "16054" "ca-org10"

    infoln "Creating Org11 Identities"
    createOrg "org11" "17054" "ca-org11"

    infoln "Creating Org12 Identities"
    createOrg "org12" "18054" "ca-org12"

    infoln "Creating Org13 Identities"
    createOrg "org13" "19054" "ca-org13"

    infoln "Creating Org14 Identities"
    createOrg "org14" "20054" "ca-org14"

    infoln "Creating Org15 Identities"
    createOrg "org15" "21054" "ca-org15"

    infoln "Creating Org16 Identities"
    createOrg "org16" "22054" "ca-org16"

    infoln "Creating Org17 Identities"
    createOrg "org17" "23054" "ca-org17"

    infoln "Creating Org18 Identities"
    createOrg "org18" "24054" "ca-org18"

    infoln "Creating Org19 Identities"
    createOrg "org19" "25054" "ca-org19"

    infoln "Creating Org20 Identities"
    createOrg "org20" "26054" "ca-org20"

    infoln "Creating Orderer Org Identities"
    createOrderer

    infoln "Generating CCP files for Orgs"
    ./organizations/ccp-generate.sh
}

# 开启网络
function networkUp() {

    checkPrereqs
    # generate artifacts if they don't exist
    if [ ! -d "organizations/peerOrganizations" ]; then
        createOrgs
    fi

    # 基础docker文件，扩展文件（docker sock）
    # COMPOSE_FILES="-f compose/compose-net.yaml -f compose/docker/docker-compose-net.yaml"
    COMPOSE_FILES=" -f compose/compose-net-orderer.yaml \
                    -f compose/compose-net-org1.yaml \
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

    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES} up -d 2>&1

    docker ps -a
    if [ $? -ne 0 ]; then
        fatalln "Unable to start network"
    fi
}

# 启动网络
infoln "Starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE}' ${CRYPTO_MODE}"
networkUp

# 创建通道

function createChannel() {
    # Bring up the network if it is not already up.

    bringUpNetwork="false"
    #   local bft_true=$1

    if ! docker info >/dev/null 2>&1; then
        fatalln "docker network is required to be running to create a channel"
    fi

    # check if all containers are present
    CONTAINERS=($(docker ps | grep hyperledger/ | awk '{print $2}'))
    len=$(echo ${#CONTAINERS[@]})

    # 容器大于等于4 且 目录不存在-> 证书异常，关闭网络
    if [[ $len -ge 4 ]] && [[ ! -d "organizations/peerOrganizations" ]]; then
        echo "Bringing network down to sync certs with containers"
        networkDown
    fi
    # 容器小于4 或 目录不存在 设置bringUpNetwork 否则输出网络已在运行
    [[ $len -lt 4 ]] || [[ ! -d "organizations/peerOrganizations" ]] && bringUpNetwork="true" || echo "Network Running Already"

    # 上一步的状态设置
    if [ $bringUpNetwork == "true" ]; then
        infoln "Bringing up network"
        networkUp
    fi

    # now run the script that creates a channel. This script uses configtxgen once
    # to create the channel creation transaction and the anchor peer updates.
    scripts/createChannel.sh $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE
    #   $bft_true
}

infoln "Creating channel '${CHANNEL_NAME}'."
infoln "If network is not up, starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE} ${CRYPTO_MODE}"
createChannel

# 部署链码
# start to deploy chaincode
export FABRIC_CFG_PATH=${PWD}/../config/

## Call the script to deploy a chaincode to the channel
function deployCC() {
    scripts/deployCC.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE

    if [ $? -ne 0 ]; then
        fatalln "Deploying chaincode failed"
    fi
}

infoln "deploying chaincode on channel '${CHANNEL_NAME}'"
deployCC

## Call the script to deploy a chaincode to the channel
# function deployCCAAS() {
#     scripts/deployCCAAS.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CCAAS_DOCKER_RUN $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE $CCAAS_DOCKER_RUN

#     if [ $? -ne 0 ]; then
#         fatalln "Deploying chaincode-as-a-service failed"
#     fi
# }

## Call the script to package the chaincode
function packageChaincode() {

    infoln "Packaging chaincode"

    scripts/packageCC.sh $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION true

    if [ $? -ne 0 ]; then
        fatalln "Packaging the chaincode failed"
    fi

}

## Call the script to list installed and committed chaincode on a peer
function listChaincode() {

    export FABRIC_CFG_PATH=${PWD}/../config

    . scripts/envVar.sh
    . scripts/ccutils.sh

    infoln "setGlobals for org1"
    setGlobals 1
    infoln "query chaincode Installed On Peer"
    println
    queryInstalledOnPeer
    println
    infoln "query chaincode Committed on channel"
    listAllCommitted

    infoln "setGlobals for org2"
    setGlobals 2
    infoln "query chaincode Installed On Peer"
    println
    queryInstalledOnPeer
    println
    infoln "query chaincode Committed on channel"
    listAllCommitted

    infoln "setGlobals for org3"
    setGlobals 3
    infoln "query chaincode Installed On Peer"
    println
    queryInstalledOnPeer
    println
    infoln "query chaincode Committed on channel"
    listAllCommitted

}

infoln "test:query the chaincode installed for 1/2/3"
listChaincode

infoln "set the peer environment virable"
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

## Call the script to invoke
# function invokeChaincode() {

#     export FABRIC_CFG_PATH=${PWD}/../config

#     . scripts/envVar.sh
#     . scripts/ccutils.sh

#     setGlobals $ORG

#     chaincodeInvoke $ORG $CHANNEL_NAME $CC_NAME $CC_INVOKE_CONSTRUCTOR

# }
## Call the script to query chaincode
# function queryChaincode() {

#     export FABRIC_CFG_PATH=${PWD}/../config

#     . scripts/envVar.sh
#     . scripts/ccutils.sh

#     setGlobals $ORG

#     chaincodeQuery $ORG $CHANNEL_NAME $CC_NAME $CC_QUERY_CONSTRUCTOR

# }
