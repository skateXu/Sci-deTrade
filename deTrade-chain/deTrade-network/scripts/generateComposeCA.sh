#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

Nums_Org=${1:-"20"}

# 生成单个组织的CA配置
generate_org_ca() {
    local org_num=$1
    cat << EOF
  ca_org${org_num}:
    image: hyperledger/fabric-ca:latest
    labels:
      service: hyperledger-fabric
    container_name: ca_\${ORG${org_num}}
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_CA_NAME=ca-\${ORG${org_num}}
      - FABRIC_CA_SERVER_PORT=\${CAPORT${org_num}}
      - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:\${CAOPLISSEN${org_num}}
    ports:
      - "\${CAPORT${org_num}}:\${CAPORT${org_num}}"
      - "\${CAOPLISSEN${org_num}}:\${CAOPLISSEN${org_num}}"
    volumes:
      - ../organizations/fabric-ca/\${ORG${org_num}}:/etc/hyperledger/fabric-ca-server
    command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
    networks:
      - test
EOF
}

# 生成orderer的CA配置
generate_orderer_ca() {
    cat << EOF
  ca_orderer:
    image: hyperledger/fabric-ca:latest
    labels:
      service: hyperledger-fabric
    container_name: ca_\${ORDERER}
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_CA_NAME=ca-\${ORDERER}
      - FABRIC_CA_SERVER_PORT=\${CAPORTORD}
      - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:\${CAOPLISSENORD}
    ports:
      - "\${CAPORTORD}:\${CAPORTORD}"
      - "\${CAOPLISSENORD}:\${CAOPLISSENORD}"
    command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
    volumes:
      - ../organizations/fabric-ca/ordererOrg:/etc/hyperledger/fabric-ca-server
    networks:
      - test
EOF
}

# 生成完整的compose-ca.yaml文件
generate_compose_ca() {
    local num_orgs=$1
    
    # 生成文件头部
    cat > ../compose/compose-ca.yaml << EOF
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
version: '3.7'
networks:
  test:
    name: fabric_test
services:
EOF
    
    # 生成所有组织的CA配置
    for i in $(seq 1 $num_orgs); do
        generate_org_ca $i >> ../compose/compose-ca.yaml
    done
    
    # 添加orderer的CA配置
    generate_orderer_ca >> ../compose/compose-ca.yaml
}

# 生成20个组织的CA配置文件

generate_compose_ca $Nums_Org