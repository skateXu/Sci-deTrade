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

# import default
. ./network.config

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
Org_Count=5 
Peer_Count=20
Flag=0
# -n生成组织文件
if [ "$1" = "-n" ]; then
  Flag=1
fi

# check the Fabric environment configuration and add DNS resolution

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
# 创建组织证书
function createOrgs() {
    if [ -d "organizations/peerOrganizations" ]; then
        rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
    fi

     . scripts/registerEnroll.sh

    #通过轮询检查 tls-cert.pem 文件是否生成，确保 CA 服务已完全启动并准备就绪,调用registerEnroll.sh的函数
    while :; do
        if [ ! -f "organizations/fabric-ca/org1/tls-cert.pem" ]; then
            sleep 1
        else
            break
        fi
    done
    for i in $(seq 1 $Org_Count); do
        infoln "Creating Org${i} Identities"
        port=$((7054 + ($i-1)*1000))
        createOrg "org${i}" "${port}" "ca-org${i}" "$Peer_Count"
    done

    infoln "Creating Orderer Org Identities"
    createOrderer

    # 重命名密钥文件
    renameAdminKeys
}
# 开启网络
function networkUp() {
    checkPrereqs
    # infoln "Generating certificates using Fabric CA"
    # docker-compose  -f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml up -d 2>&1

    # 基础docker文件，扩展文件（docker sock）
    for i in $(seq 1 $Org_Count); do
        declare "COMPOSE_FILES_${i}=-f compose/compose-net-org${i}.yaml \
                    -f compose/docker/docker-compose-net-org${i}.yaml"
    done

    COMPOSE_FILES_orderer="-f compose/compose-net-orderer.yaml"

    COMPOSE_FILES_test="-f compose/compose-test-net.yaml\
                    -f compose/docker/docker-compose-test-net.yaml"

    # DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_test} up -d 2>&1
    # 根据组织数目启动对应数量的组织节点
    for i in $(seq 1 ${Org_Count}); do
        COMPOSE_FILE_VAR="COMPOSE_FILES_${i}"
        DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${!COMPOSE_FILE_VAR} up -d 2>&1
    done

    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_orderer} up -d 2>&1

    docker ps -a
    if [ $? -ne 0 ]; then
        fatalln "Unable to start network"
    fi
}

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
    scripts/createChannel.sh $Org_Count $Peer_Count $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE
    #   $bft_true
}

## Call the script to deploy a chaincode to the channel
function deployCC() {
    scripts/deployCC.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE $Org_Count $Peer_Count

    if [ $? -ne 0 ]; then
        fatalln "Deploying chaincode failed"
    fi
}
## Call the script to deploy a chaincode to the channel
# function deployCCEACH() {
#     Org_Num=$1
#     Nums_Peer=$2
#     scripts/deployCCEACH.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE $Org_Num $Nums_Peer

#     if [ $? -ne 0 ]; then
#         fatalln "Deploying chaincode failed"
#     fi
# }
# function deployCCALL() {
#     Nums_Org=$1
#     Nums_Peer=$2    
#     scripts/deployCCALL.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE $Nums_Org $Nums_Peer
# }   

function packageChaincode() {

    infoln "Packaging chaincode"

    scripts/packageCC.sh $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION true

    if [ $? -ne 0 ]; then
        fatalln "Packaging the chaincode failed"
    fi

}

# 重命名
function renameAdminKeys() {
    infoln "Renaming admin keystore files for $Org_Count organizations"
    
    # 根据组织数量动态遍历
    for ((i=1; i<=$Org_Count; i++)); do
        KEYSTORE_DIR="organizations/peerOrganizations/org${i}.example.com/users/Admin@org${i}.example.com/msp/keystore"
        if [ -d "$KEYSTORE_DIR" ]; then
            # 重命名找到的 *_sk 文件为 priv_sk
            find "$KEYSTORE_DIR" -name "*_sk" -exec mv {} "$KEYSTORE_DIR/priv_sk" \;
            successln "Renamed keystore file for org${i}"
        fi
    done
}




# ------------> START <-------------

# 生成Docker配置文件
# ./scripts/generateEnv.sh
./scripts/generateComposeCA.sh $Org_Count
./scripts/generateComposeNet.sh $Org_Count $Peer_Count
./scripts/generateComposeNetDocker.sh $Org_Count $Peer_Count
# 生成explorer配置文件
./scripts/generateExplorer.sh $Org_Count $Peer_Count
# ./scripts/setDNS.sh

#启动CA
infoln "Generating certificates using Fabric CA"
docker-compose  -f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml up -d 2>&1

if [ $Flag -eq 1 ]; then
    createOrgs
fi

# 生成ccp连接模板和连接文件
./scripts/generateCCPtemplate.sh $Org_Count $Peer_Count
./organizations/ccp-generate.sh $Org_Count $Peer_Count

# 启动网络
infoln "Starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE}' ${CRYPTO_MODE}"
networkUp

# 创建通道

infoln "Creating channel '${CHANNEL_NAME}'."
infoln "If network is not up, starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE} ${CRYPTO_MODE}"
createChannel


# # 部署链码
# # start to deploy chaincode

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config/
infoln "deploying chaincode on channel '${CHANNEL_NAME}'"
deployCC



# infoln "list installed and committed chaincode on a peer"
# listChaincode