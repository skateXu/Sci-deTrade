#!/bin/bash
# 设置当前脚本目录
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

CCP_JSON_FILE="../organizations/ccp-template-deTrade.json"
CCP_YAML_FILE="../organizations/ccp-template-deTrade.yaml"

Nums_Org=${1:-"20"}
Nums_Peer=${2:-"25"}

# 清空或创建文件
> $CCP_JSON_FILE
> $CCP_YAML_FILE

cat << EOF >> $CCP_JSON_FILE
{
    "name": "deTrade-network-org\${ORG}",
    "version": "1.0.0",
    "client": {
        "organization": "Org\${ORG}",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300"
                }
            }
        }
    },
    "organizations": {
        "Org\${ORG}": {
            "mspid": "Org\${ORG}MSP",
            "peers": [
EOF

# 生成peer列表
for i in $(seq 0 $((Nums_Peer-1)))
do
    echo -n "                \"peer${i}.org\${ORG}.example.com\"" >> $CCP_JSON_FILE
    if [ $i -lt $((Nums_Peer-1)) ]; then
        echo "," >> $CCP_JSON_FILE
    else
        echo "" >> $CCP_JSON_FILE
    fi  
done

cat << EOF >> $CCP_JSON_FILE
            ],
            "certificateAuthorities": [
                "ca.org\${ORG}.example.com"
            ]
        }
    },
    "peers": {
EOF

# 生成peers详细配置
for i in $(seq 0 $((Nums_Peer-1)))
do
    echo "        \"peer${i}.org\${ORG}.example.com\": {">> $CCP_JSON_FILE
    echo "            \"url\": \"grpcs://localhost:\${P${i}PORT}\"," >> $CCP_JSON_FILE
    echo "            \"tlsCACerts\": {" >> $CCP_JSON_FILE
    echo "                \"pem\": \"\${PEERPEM}\"" >> $CCP_JSON_FILE
    echo "            }," >> $CCP_JSON_FILE
    echo "            \"grpcOptions\": {" >> $CCP_JSON_FILE
    echo "                \"ssl-target-name-override\": \"peer${i}.org\${ORG}.example.com\"," >> $CCP_JSON_FILE
    echo "                \"hostnameOverride\": \"peer${i}.org\${ORG}.example.com\"" >> $CCP_JSON_FILE
    echo "            }" >> $CCP_JSON_FILE
    if [ $i -lt $((Nums_Peer-1)) ]; then
        echo "        }," >> $CCP_JSON_FILE
    else
        echo "        }" >> $CCP_JSON_FILE
    fi
done

cat << EOF >> $CCP_JSON_FILE
    },
    "certificateAuthorities": {
        "ca.org\${ORG}.example.com": {
            "url": "https://localhost:\${CAPORT}",
            "caName": "ca-org\${ORG}",
            "tlsCACerts": {
                "pem": ["\${CAPEM}"]
            },
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF


# 生成YAML文件内容
cat << EOF >> $CCP_YAML_FILE
---
name: deTrade-network-org\${ORG}
version: 1.0.0
client:
  organization: Org\${ORG}
  connection:
    timeout:
      peer:
        endorser: '300'
organizations:
  Org\${ORG}:
    mspid: Org\${ORG}MSP
    peers:
EOF
# 生成peer列表
for i in $(seq 0 $((Nums_Peer-1)))
do
    echo "    - peer${i}.org\${ORG}.example.com" >> $CCP_YAML_FILE
done

cat << EOF >> $CCP_YAML_FILE
    certificateAuthorities:
    - ca.org\${ORG}.example.com
peers:
EOF

# 生成peers详细配置
for i in $(seq 0 $((Nums_Peer-1)))
do
    cat << EOF >> $CCP_YAML_FILE
  peer${i}.org\${ORG}.example.com:
    url: grpcs://localhost:\${P${i}PORT}
    tlsCACerts:
      pem: |
          \${PEERPEM}
    grpcOptions:
      ssl-target-name-override: peer${i}.org\${ORG}.example.com
      hostnameOverride: peer${i}.org\${ORG}.example.com
EOF
done

cat << EOF >> $CCP_YAML_FILE
certificateAuthorities:
  ca.org\${ORG}.example.com:
    url: https://localhost:\${CAPORT}
    caName: ca-org\${ORG}
    tlsCACerts:
      pem: 
        - |
          \${CAPEM}
    httpOptions:
      verify: false
EOF