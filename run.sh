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
#!/bin/bash

echo "🔧 Updating system and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl iptables ufw build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

echo "🐳 Installing Docker..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
sudo apt-get install -y ca-certificates curl gnupg
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

# Export PATH so current session can use aztec-up immediately
if ! grep -q '.aztec/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/.aztec/bin:$PATH"

echo "⬇️ Pulling latest Aztec release..."
~/.aztec/bin/aztec-up latest

echo "🛡️ Configuring firewall..."
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

echo "📦 Setting up Aztec sequencer..."
mkdir -p ~/aztec && cd ~/aztec

# Replace these with real contents or instructions
cat <<EOF > .env
ETHEREUM_RPC_URL=your_rpc_url
CONSENSUS_BEACON_URL=your_beacon_url
VALIDATOR_PRIVATE_KEY=0xyourprivatekey
COINBASE=0xyourwallet
P2P_IP=your_public_ip
EOF

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  aztec-node:
    image: aztecprotocol/aztec-node:latest
    ports:
      - "40400:40400"
      - "8080:8080"
    env_file:
      - .env
    restart: unless-stopped
EOF

echo "✅ Configuration files created."
echo "🧱 Starting docker containers..."
docker compose up -d
docker compose logs -fn 1000

echo "📂 Moving into ~/aztec folder..."
cd "$HOME/aztec"
exec bash
