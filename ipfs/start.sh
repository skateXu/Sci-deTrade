wget https://dist.ipfs.tech/kubo/v0.31.0/kubo_v0.31.0_linux-amd64.tar.gz
tar -xvzf kubo_v0.31.0_linux-amd64.tar.gz
cd kubo
sudo bash install.sh
export IPFS_PATH=$(pwd)/.ipfs
ipfs init
ipfs daemon