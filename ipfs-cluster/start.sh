# install docker and docker compose
sudo apt update
sudo apt install docker.io docker-compose

# set secret key 
echo "CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')" > .env

# start ipfs cluster
docker-compose up -d
