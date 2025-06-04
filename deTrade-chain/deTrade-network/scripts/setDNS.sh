# Configuration
DOMAIN="example.com"
IP="127.0.0.1"
NUM_ORGS=20              # 组织数量
NUM_ORDERERS=3          # orderer节点数量
PEERS_PER_ORG=25        # 每个组织的peer节点数量 (0-24)

# Add orderer organization entry
grep -q "$IP       orderer.$DOMAIN" /etc/hosts || echo "$IP       orderer.$DOMAIN" >> /etc/hosts

# Add member organizations entries
for ((org=1; org<=NUM_ORGS; org++)); do
    grep -q "$IP       org$org.$DOMAIN" /etc/hosts || echo "$IP       org$org.$DOMAIN" >> /etc/hosts
done

# Add orderer nodes
for ((i=0; i<NUM_ORDERERS; i++)); do
    grep -q "$IP       orderer$i.orderer.$DOMAIN" /etc/hosts || \
    echo "$IP       orderer$i.orderer.$DOMAIN" >> /etc/hosts
done

# Add peer nodes for each org
for ((org=1; org<=NUM_ORGS; org++)); do
    for ((peer=0; peer<PEERS_PER_ORG; peer++)); do
        grep -q "$IP       peer$peer.org$org.$DOMAIN" /etc/hosts || \
        echo "$IP       peer$peer.org$org.$DOMAIN" >> /etc/hosts
    done
done