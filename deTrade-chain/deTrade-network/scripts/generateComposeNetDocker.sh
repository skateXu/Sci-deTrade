#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

Nums_Org=${1:-"20"}
Nums_Peer=${2:-"25"}

generate_peers(){
    local org_num=$1
    local peer_num=$2
    cat << EOF
  peer${peer_num}.org${org_num}.example.com:
    container_name: peer${peer_num}.org${org_num}.example.com
    image: hyperledger/fabric-peer:latest
    labels:
      service: hyperledger-fabric
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=fabric_test
    volumes:
      - ./docker/peercfg:/etc/hyperledger/peercfg
      - \${DOCKER_SOCK}:/host/var/run/docker.sock
EOF
}


# 生成单个组织的所有peer节点配置
generate_org_peers() {
    local org_num=$1
    local num_peers=$2
    local output_file=$3

    # 生成文件头部
    cat > "$output_file" << EOF
version: '3.7'

services:
EOF
     # 生成services
    for peer_num in $(seq 0 $(($num_peers-1))); do
        generate_peers $org_num $peer_num >> "$output_file"
    done
}

# 为每个组织生成配置文件（20个组织，每个组织25个peer）
for i in $(seq 1 $Nums_Org); do
    generate_org_peers $i $Nums_Peer "../compose/docker/docker-compose-net-org${i}.yaml"
done
