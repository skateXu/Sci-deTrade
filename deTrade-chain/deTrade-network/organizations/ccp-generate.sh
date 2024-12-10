#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}


# 定义组织信息
declare -a orgs=("org1" "org2" "org3" "org4" "org5" "org6" "org7" "org8" "org9" "org10" "org11" "org12" "org13" "org14" "org15" "org16" "org17" "org18" "org19" "org20")
declare -a peer_ports=(7051 8051 9051 10051 11051 12051 13051 14051 15051 16051 17051 18051 19051 20051 21051 22051 23051 24051 25051 26051)
declare -a ca_ports=(7054 8054 9054 10054 11054 12054 13054 14054 15054 16054 17054 18054 19054 20054 21054 22054 23054 24054 25054 26054)

# 循环遍历每个组织
for i in ${!orgs[@]}; do
    ORG=${orgs[$i]}
    P0PORT=${peer_ports[$i]}
    CAPORT=${ca_ports[$i]}
    PEERPEM="organizations/peerOrganizations/$ORG.example.com/tlsca/tlsca.$ORG.example.com-cert.pem"
    CAPEM="organizations/peerOrganizations/$ORG.example.com/ca/ca.$ORG.example.com-cert.pem"

    # 生成JSON配置文件
    echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/$ORG.example.com/connection-$ORG.json
    
    # 生成YAML配置文件
    echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/$ORG.example.com/connection-$ORG.yaml

    echo "Generated connection file for $ORG"
done

# ORG=1
# P0PORT=7051
# CAPORT=7054
# PEERPEM=organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
# CAPEM=organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem

# echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.example.com/connection-org1.json
# echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.example.com/connection-org1.yaml

# ORG=2
# P0PORT=8051
# CAPORT=8054
# PEERPEM=organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem
# CAPEM=organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

# echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.example.com/connection-org2.json
# echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.example.com/connection-org2.yaml

# ORG=3
# P0PORT=9051
# CAPORT=9054
# PEERPEM=organizations/peerOrganizations/org3.example.com/tlsca/tlsca.org3.example.com-cert.pem
# CAPEM=organizations/peerOrganizations/org3.example.com/ca/ca.org3.example.com-cert.pem

# echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org3.example.com/connection-org3.json
# echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org3.example.com/connection-org3.yaml
