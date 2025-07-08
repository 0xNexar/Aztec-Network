#!/bin/bash

clear
echo -e "\e[1;35m"
cat << "EOF"
 /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\
( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )
 > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ < 
 /\_/\        █████               ██████   █████                                            /\_/\
( o.o )     ███░░░███            ░░██████ ░░███                                            ( o.o )
 > ^ <     ███   ░░███ █████ █████░███░███ ░███   ██████  █████ █████  ██████  ████████     > ^ < 
 /\_/\    ░███    ░███░░███ ░░███ ░███░░███░███  ███░░███░░███ ░░███  ░░░░░███░░███░░███    /\_/\
( o.o )   ░███    ░███ ░░░█████░  ░███ ░░██████ ░███████  ░░░█████░    ███████ ░███ ░░░    ( o.o )
 > ^ <    ░░███   ███   ███░░░███ ░███  ░░█████ ░███░░░    ███░░░███  ███░░███ ░███         > ^ < 
 /\_/\     ░░░█████░   █████ ██████████  ░░█████░░██████  █████ █████░░█████████████        /\_/\
( o.o )      ░░░░░░   ░░░░░ ░░░░░░░░░░    ░░░░░  ░░░░░░  ░░░░░ ░░░░░  ░░░░░░░░░░░░░        ( o.o )
 > ^ <                                                                                      > ^ < 
 /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\
( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )
 > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ < 
                                    Guide by 0xNexar
EOF
echo -e "\e[0m"
sleep 2


echo "🔧 Updating system and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl iptables ufw build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

echo "🐳 Installing Docker..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Testing Docker installation..."
sudo docker run hello-world
sudo systemctl enable docker
sudo systemctl restart docker

echo "🌐 Installing Aztec CLI..."
bash -i <(curl -s https://install.aztec.network)

if ! grep -q '.aztec/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
  echo "✅ Added Aztec bin directory to ~/.bashrc"
fi
export PATH="$HOME/.aztec/bin:$PATH"

echo "⬇️ Pulling latest Aztec release..."
if ! ~/.aztec/bin/aztec-up latest; then
  echo "❌ Failed to pull Aztec image. Retrying with 'docker pull'..."
  docker pull aztecprotocol/aztec:0.87.9 || {
    echo "❌ Docker pull failed. Please check your internet connection and try again."
    exit 1
  }
fi

echo "🛡️ Configuring firewall..."
sudo apt install -y ufw
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8081
sudo ufw --force enable

echo "📦 Setting up Aztec sequencer..."
AZTEC_DIR="$HOME/aztec"
mkdir -p "$AZTEC_DIR" && cd "$AZTEC_DIR"

echo "📝 Please enter your Aztec sequencer config values."

read -p "🔗 Enter Your RPC URL: " RPC_URL
read -p "📡 Enter Your Beacon URL: " BEACON_URL
read -p "🔑 Enter Your Private Key (0x...): " PRIVATE_KEY
read -p "💰 Enter Your Wallet Address (0x...): " YOUR_ADDRESS
read -p "🌍 Enter Your IP: " YOUR_IP

cat <<EOF > nano.env
ETHEREUM_RPC_URL=$RPC_URL
CONSENSUS_BEACON_URL=$BEACON_URL
VALIDATOR_PRIVATE_KEY=$PRIVATE_KEY
COINBASE=$YOUR_ADDRESS
P2P_IP=$YOUR_IP
EOF

echo "✅ nano.env created with your inputs."

echo "📝 Please enter your Aztec sequencer config values."

read -p "🔗 Enter Your RPC URL: " RPC_URL
read -p "📡 Enter Your Beacon URL: " BEACON_URL
read -p "🔑 Enter Your Private Key (0x...): " PRIVATE_KEY
read -p "💰 Enter Your Wallet Address (0x...): " YOUR_ADDRESS
read -p "🌍 Enter Your IP: " YOUR_IP

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  aztec-node:
    container_name: aztec-sequencer
    image: aztecprotocol/aztec:0.87.9
    restart: unless-stopped
    environment:
      ETHEREUM_HOSTS: $RPC_URL
      L1_CONSENSUS_HOST_URLS: $BEACON_URL
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEY: $PRIVATE_KEY
      COINBASE: $YOUR_ADDRESS
      P2P_IP: $YOUR_IP
      LOG_LEVEL: debug
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'    
    ports:
      - "8081:8080" 
      - "40400:40400/tcp"
      - "40400:40400/udp"
    volumes:
      - /root/.aztec/alpha-testnet/data/:/data
EOF

echo "✅ docker-compose.yml created with your inputs."


echo "🧱 Starting docker containers..."
docker compose up -d
docker compose logs -fn 1000

echo "📂 Moving into ~/aztec folder..."
cd "$HOME/aztec"
exec bash

echo "📂 Moving into ~/aztec folder..."
cd "$HOME/aztec"
exec bash
