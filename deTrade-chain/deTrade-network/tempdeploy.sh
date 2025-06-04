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
Nums_Org=20 # 组织数量只涉及到了重命名
Nums_Peer=25

# Parse command line arguments
while getopts "n:" opt; do
  case $opt in
    n)
      Org_Num=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done


# 创建组织证书
function createOrgs() {
    if [ -d "organizations/peerOrganizations" ]; then
        rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
    fi

    infoln "Generating certificates using Fabric CA"
    docker-compose  -f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml up -d 2>&1

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
    createOrg "org1" "7054" "ca-org1" "$Nums_Peer"

    infoln "Creating Org2 Identities"
    createOrg "org2" "8054" "ca-org2" "$Nums_Peer"
    
    infoln "Creating Org3 Identities"
    createOrg "org3" "9054" "ca-org3" "$Nums_Peer"

    infoln "Creating Org4 Identities"
    createOrg "org4" "10054" "ca-org4" "$Nums_Peer"

    infoln "Creating Org5 Identities"
    createOrg "org5" "11054" "ca-org5" "$Nums_Peer"

    infoln "Creating Org6 Identities"
    createOrg "org6" "12054" "ca-org6" "$Nums_Peer"

    infoln "Creating Org7 Identities"
    createOrg "org7" "13054" "ca-org7" "$Nums_Peer"

    infoln "Creating Org8 Identities"
    createOrg "org8" "14054" "ca-org8" "$Nums_Peer"

    infoln "Creating Org9 Identities"
    createOrg "org9" "15054" "ca-org9" "$Nums_Peer"

    infoln "Creating Org10 Identities"
    createOrg "org10" "16054" "ca-org10" "$Nums_Peer"

    infoln "Creating Org11 Identities"
    createOrg "org11" "17054" "ca-org11" "$Nums_Peer"

    infoln "Creating Org12 Identities"
    createOrg "org12" "18054" "ca-org12" "$Nums_Peer"

    infoln "Creating Org13 Identities"
    createOrg "org13" "19054" "ca-org13" "$Nums_Peer"

    infoln "Creating Org14 Identities"
    createOrg "org14" "20054" "ca-org14" "$Nums_Peer"

    infoln "Creating Org15 Identities"
    createOrg "org15" "21054" "ca-org15" "$Nums_Peer"

    infoln "Creating Org16 Identities"
    createOrg "org16" "22054" "ca-org16" "$Nums_Peer"

    infoln "Creating Org17 Identities"
    createOrg "org17" "23054" "ca-org17" "$Nums_Peer"

    infoln "Creating Org18 Identities"
    createOrg "org18" "24054" "ca-org18" "$Nums_Peer"

    infoln "Creating Org19 Identities"
    createOrg "org19" "25054" "ca-org19" "$Nums_Peer"

    infoln "Creating Org20 Identities"
    createOrg "org20" "26054" "ca-org20" "$Nums_Peer"

    infoln "Creating Orderer Org Identities"
    createOrderer

    infoln "Generating CCP files for Orgs"
    ./organizations/ccp-generate.sh

    # 重命名密钥文件
    renameAdminKeys
}

# 开启网络
function networkUp() {
    infoln "Generating certificates using Fabric CA"
    # 启动CA
    docker-compose  -f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml up -d 2>&1

    # 基础docker文件，扩展文件（docker sock）
    # COMPOSE_BASE_FILES="-f compose/compose-net-full.yaml "
    COMPOSE_FILES_1="-f compose/compose-net-org1.yaml \
                    -f compose/docker/docker-compose-net-org1.yaml"
    COMPOSE_FILES_2="-f compose/compose-net-org2.yaml \
                    -f compose/docker/docker-compose-net-org2.yaml"

    COMPOSE_FILES_3="-f compose/compose-net-org3.yaml \
                    -f compose/docker/docker-compose-net-org3.yaml"

    COMPOSE_FILES_4="-f compose/compose-net-org4.yaml \
                    -f compose/docker/docker-compose-net-org4.yaml"

    COMPOSE_FILES_5="-f compose/compose-net-org5.yaml \
                    -f compose/docker/docker-compose-net-org5.yaml"

    COMPOSE_FILES_6="-f compose/compose-net-org6.yaml \
                    -f compose/docker/docker-compose-net-org6.yaml"

    COMPOSE_FILES_7="-f compose/compose-net-org7.yaml \
                    -f compose/docker/docker-compose-net-org7.yaml"

    COMPOSE_FILES_8="-f compose/compose-net-org8.yaml \
                    -f compose/docker/docker-compose-net-org8.yaml"

    COMPOSE_FILES_9="-f compose/compose-net-org9.yaml \
                    -f compose/docker/docker-compose-net-org9.yaml"

    COMPOSE_FILES_10="-f compose/compose-net-org10.yaml \
                    -f compose/docker/docker-compose-net-org10.yaml"

    COMPOSE_FILES_11="-f compose/compose-net-org11.yaml \
                    -f compose/docker/docker-compose-net-org11.yaml"

    COMPOSE_FILES_12="-f compose/compose-net-org12.yaml \
                    -f compose/docker/docker-compose-net-org12.yaml"

    COMPOSE_FILES_13="-f compose/compose-net-org13.yaml \
                    -f compose/docker/docker-compose-net-org13.yaml"

    COMPOSE_FILES_14="-f compose/compose-net-org14.yaml \
                    -f compose/docker/docker-compose-net-org14.yaml"

    COMPOSE_FILES_15="-f compose/compose-net-org15.yaml \
                    -f compose/docker/docker-compose-net-org15.yaml"

    COMPOSE_FILES_16="-f compose/compose-net-org16.yaml \
                    -f compose/docker/docker-compose-net-org16.yaml"

    COMPOSE_FILES_17="-f compose/compose-net-org17.yaml \
                    -f compose/docker/docker-compose-net-org17.yaml"

    COMPOSE_FILES_18="-f compose/compose-net-org18.yaml \
                    -f compose/docker/docker-compose-net-org18.yaml"

    COMPOSE_FILES_19="-f compose/compose-net-org19.yaml \
                    -f compose/docker/docker-compose-net-org19.yaml"

    COMPOSE_FILES_20="-f compose/compose-net-org20.yaml \
                    -f compose/docker/docker-compose-net-org20.yaml"

    COMPOSE_FILES_orderer="-f compose/compose-net-orderer.yaml"


    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_1} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_2} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_3} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_4} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_5} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_6} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_7} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_8} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_9} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_10} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_11} up -d 2>&1      
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_12} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_13} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_14} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_15} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_16} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_17} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_18} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_19} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_20} up -d 2>&1
    DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES_orderer} up -d 2>&1


    # DOCKER_SOCK="${DOCKER_SOCK}" docker-compose ${COMPOSE_FILES} up -d 2>&1

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
    scripts/createChannel.sh $Nums_Org $Nums_Peer $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE
    #   $bft_true
}


## Call the script to deploy a chaincode to the channel
## Call the script to deploy a chaincode to the channel
function deployCCEACH() {
    Org_Num=$1
    Nums_Peer=$2
    scripts/deployCCEACH.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE $Org_Num $Nums_Peer

    if [ $? -ne 0 ]; then
        fatalln "Deploying chaincode failed"
    fi
}

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
    setGlobals 1 0
    infoln "query chaincode Installed On Peer"
    println
    queryInstalledOnPeer
    println
    infoln "query chaincode Committed on channel"
    listAllCommitted

    infoln "setGlobals for org2"
    setGlobals 2 0
    infoln "query chaincode Installed On Peer"
    println
    queryInstalledOnPeer
    println
    infoln "query chaincode Committed on channel"
    listAllCommitted

    infoln "setGlobals for org3"
    setGlobals 3 0
    infoln "query chaincode Installed On Peer"
    println
    queryInstalledOnPeer
    println
    infoln "query chaincode Committed on channel"
    listAllCommitted

}

# 重命名
function renameAdminKeys() {
    infoln "Renaming admin keystore files for $Nums_Org organizations"
    
    # 根据组织数量动态遍历
    for ((i=1; i<=$Nums_Org; i++)); do
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
# ./scripts/generateComposeCA.sh
# ./scripts/generateComposeNet.sh
# ./scripts/generateComposeNetDocker.sh
# ./scripts/generateExplorer.sh
# ./scripts/setDNS.sh

# 启动网络
# infoln "Starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE}' ${CRYPTO_MODE}"
# networkUp

# 创建通道

# infoln "Creating channel '${CHANNEL_NAME}'."
# infoln "If network is not up, starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE} ${CRYPTO_MODE}"
# createChannel

# 部署链码:start to deploy chaincode
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config/

infoln "deploying chaincode on channel '${CHANNEL_NAME}'"
deployCCEACH $Org_Num $Nums_Peer


# # Pause execution and wait for user input
# read -n 1 -s -r -p "Press any key to continue..."
# echo # Print a newline after key press

# source scripts/utils.sh
# commitChaincodeDefinition 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20


