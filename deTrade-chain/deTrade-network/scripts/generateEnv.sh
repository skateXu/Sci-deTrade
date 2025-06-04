#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

# 创建.env文件
ENV_FILE="../compose/.env"

# 清空或创建文件
> $ENV_FILE

# 添加注释头
cat << 'EOF' >> $ENV_FILE
# ORG= ORG name
# ORG_MSP= MSP name
# PORT = Peer Port
# CCPORT1= Chaincode Port
# METRICS_PORT1=Operations Port
# CAPORT = CA PORT
# CAOPLISSEN=CA Operations Listenaddress

EOF

# 生成组织配置
generate_org_config() {
    local org_num=$1
    local base_port=$2
    
    echo "# Organization ${org_num} (Base port: ${base_port})" >> $ENV_FILE
    echo "ORG${org_num}=org${org_num}" >> $ENV_FILE
    echo "ORG${org_num}_MSP=Org${org_num}MSP" >> $ENV_FILE
    

    # 生成25个peer节点的端口配置
    for i in $(seq 0 24); do
        if [ $i -le 9 ]; then
            # First 10 peers (0-9)
            port_offset=$(( i * 100 ))
            peer_port=$((base_port + port_offset + 51))
            cc_port=$((peer_port + 1))
            metrics_port=$((base_port + port_offset + 91))
        elif [ $i -le 19 ]; then
            # Remaining peers (10-19)
            port_offset=$(( (i-10) * 100 ))
            peer_port=$((base_port + port_offset + 61))
            cc_port=$((peer_port + 1))
            metrics_port=$((base_port + port_offset + 11))
        else
            # Remaining peers (20-24)
            port_offset=$(( (i-20) * 100 ))
            peer_port=$((base_port + port_offset + 71))
            cc_port=$((peer_port + 1))
            metrics_port=$((base_port + port_offset + 21))
        fi        
        echo "PORT${org_num}_${i}=${peer_port}" >> $ENV_FILE
        echo "CCPORT${org_num}_${i}=${cc_port}" >> $ENV_FILE
        echo "METRICS_PORT${org_num}_${i}=${metrics_port}" >> $ENV_FILE
    done
    echo "" >> $ENV_FILE
}

# 生成20个组织的配置
for i in $(seq 1 20); do
    base_port=$((6000 + (i * 1000)))
    generate_org_config $i $base_port
done

# 添加CA端口配置
echo "# Common CA ports - remain unchanged from original" >> $ENV_FILE
for i in $(seq 1 20);do
    echo "CAPORT${i}=$((6054 + (i * 1000)))" >> $ENV_FILE
    echo "CAOPLISSEN${i}=$((36054 + (i * 1000)))" >> $ENV_FILE
done
echo "" >> $ENV_FILE

# 添加Orderer配置
cat << 'EOF' >> $ENV_FILE

# Orderer configuration
ORDERER=orderer
ORDERER_MSP=OrdererMSP
CAPORTORD=6054
CAOPLISSENORD=57054

ORDERER0=orderer0
ORDERER1=orderer1
ORDERER2=orderer2

# Orderer Nodes Configuration
# Orderer Node 1
ORDERER0_PORT=7050
ORDERER0_OPERATIONS_PORT=7053
ORDERER0_ADMIN_PORT=6441

# Orderer Node 2
ORDERER1_PORT=7150
ORDERER1_OPERATIONS_PORT=7055
ORDERER1_ADMIN_PORT=6442

# Orderer Node 3
ORDERER2_PORT=7250
ORDERER2_OPERATIONS_PORT=7057
ORDERER2_ADMIN_PORT=6443
EOF