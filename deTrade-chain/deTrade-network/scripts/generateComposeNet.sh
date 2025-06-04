#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT


Nums_Org=${1:-"20"}
Nums_Peer=${2:-"25"}

# 生成单个peer节点的配置
generate_peer() {
    local org_num=$1
    local peer_num=$2
    cat << EOF
  peer${peer_num}.org${org_num}.example.com:
    container_name: peer${peer_num}.\${ORG${org_num}}.example.com 
    image: hyperledger/fabric-peer:latest
    labels:
      service: hyperledger-fabric
    environment:
      - FABRIC_CFG_PATH=/etc/docker/peercfg
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=false
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      - CORE_METRICS_PROVIDER=prometheus
      - CORE_CHAINCODE_EXECUTETIMEOUT=300s
      - CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
      - CORE_PEER_ID=peer${peer_num}.\${ORG${org_num}}.example.com
      - CORE_PEER_ADDRESS=peer${peer_num}.\${ORG${org_num}}.example.com:\${PORT${org_num}_${peer_num}}
      - CORE_PEER_LISTENADDRESS=0.0.0.0:\${PORT${org_num}_${peer_num}}
      - CORE_PEER_CHAINCODEADDRESS=peer${peer_num}.\${ORG${org_num}}.example.com:\${CCPORT${org_num}_${peer_num}}
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:\${CCPORT${org_num}_${peer_num}}
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer${peer_num}.\${ORG${org_num}}.example.com:\${PORT${org_num}_${peer_num}}
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer${peer_num}.\${ORG${org_num}}.example.com:\${PORT${org_num}_${peer_num}}
      - CORE_PEER_LOCALMSPID=\${ORG${org_num}_MSP}
      - CORE_OPERATIONS_LISTENADDRESS=peer${peer_num}.\${ORG${org_num}}.example.com:\${METRICS_PORT${org_num}_${peer_num}}
      - CHAINCODE_AS_A_SERVICE_BUILDER_CONFIG={"peername":"peer${peer_num}.org${org_num}"}
    ports:
      - "\${PORT${org_num}_${peer_num}}:\${PORT${org_num}_${peer_num}}"
      - "\${METRICS_PORT${org_num}_${peer_num}}:\${METRICS_PORT${org_num}_${peer_num}}"
    volumes:
      - ../organizations/peerOrganizations/\${ORG${org_num}}.example.com/peers/peer${peer_num}.\${ORG${org_num}}.example.com:/etc/hyperledger/fabric
      - peer${peer_num}.\${ORG${org_num}}.example.com:/var/hyperledger/production
      - ../compose/docker:/etc/docker
    working_dir: /root
    command: peer node start
    networks:
      - test

EOF
}

generate_volume(){
    local org_num=$1
    local peer_num=$2
    cat << EOF
  peer${peer_num}.org${org_num}.example.com:
EOF
}

# 生成单个组织的所有peer节点配置
generate_org_peers() {
    local org_num=$1
    local num_peers=$2
    local output_file=$3

    # 生成文件头部
    cat > "$output_file" << EOF
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
version: '3.7'
networks:
  test:
    name: fabric_test
volumes:
EOF
    for peer_num in $(seq 0 $(($num_peers-1))); do
        generate_volume $org_num $peer_num >> "$output_file"
    done
     # 生成services
    cat >> "$output_file" << EOF
services: 
# Peer for org${org_num}
EOF
    
    # 生成该组织的所有peer节点配置
    for peer_num in $(seq 0 $(($num_peers-1))); do
        generate_peer $org_num $peer_num >> "$output_file"
    done
}

# 为每个组织生成配置文件（20个组织，每个组织25个peer）
for i in $(seq 1 $Nums_Org); do
    generate_org_peers $i $Nums_Peer "../compose/compose-net-org${i}.yaml"
done
