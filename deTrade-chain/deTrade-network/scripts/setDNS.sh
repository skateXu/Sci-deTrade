grep -q "127.0.0.1       orderer.example.com" /etc/hosts ||echo "127.0.0.1       orderer.example.com" >> /etc/hosts
grep -q "127.0.0.1       org1.example.com" /etc/hosts ||echo "127.0.0.1       org1.example.com" >> /etc/hosts
grep -q "127.0.0.1       org2.example.com" /etc/hosts ||echo "127.0.0.1       org2.example.com" >> /etc/hosts
grep -q "127.0.0.1       org3.example.com" /etc/hosts ||echo "127.0.0.1       org3.example.com" >> /etc/hosts


grep -q "127.0.0.1       orderer0.orderer.example.com" /etc/hosts ||echo "127.0.0.1       orderer0.orderer.example.com" >> /etc/hosts
grep -q "127.0.0.1       orderer1.orderer.example.com" /etc/hosts ||echo "127.0.0.1       orderer1.orderer.example.com" >> /etc/hosts
grep -q "127.0.0.1       orderer2.orderer.example.com" /etc/hosts ||echo "127.0.0.1       orderer2.orderer.example.com" >> /etc/hosts


grep -q "127.0.0.1       peer0.org1.example.com" /etc/hosts ||cho "127.0.0.1       peer0.org1.example.com" >> /etc/hosts
grep -q "127.0.0.1       peer0.org2.example.com" /etc/hosts ||echo "127.0.0.1       peer0.org2.example.com" >> /etc/hosts
grep -q "127.0.0.1       peer0.org3.example.com" /etc/hosts ||echo "127.0.0.1       peer0.org3.example.com" >> /etc/hosts