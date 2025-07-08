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

#!/bin/bash

clear
echo -e "\e[1;35m"
cat << "EOF"
(ASCII Art Banner Here)
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

# Add Aztec to PATH
if ! grep -q '.aztec/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
  echo "✅ Added Aztec bin directory to ~/.bashrc"
fi
export PATH="$HOME/.aztec/bin:$PATH"

echo "⬇️ Pulling latest Aztec release..."
if ! ~/.aztec/bin/aztec-up latest; then
  echo "❌ Failed to pull Aztec image. Retrying with 'docker pull'..."
  docker pull aztecprotocol/aztec:latest || {
    echo "❌ Docker pull failed. Please check your internet connection and try again."
    exit 1
  }
fi

echo "🛡️ Configuring firewall..."
sudo apt install -y ufw
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

echo "📦 Setting up Aztec sequencer..."
AZTEC_DIR="$HOME/aztec"
mkdir -p "$AZTEC_DIR" && cd "$AZTEC_DIR"

echo "📝 Creating Aztec config files..."

# Create .env template
cat <<EOF > .env
ETHEREUM_RPC_URL=https://your.ethereum.node
CONSENSUS_BEACON_URL=https://your.beacon.node
VALIDATOR_PRIVATE_KEY=0xYourPrivateKey
COINBASE=0xYourWalletAddress
P2P_IP=your.public.ip
EOF

# Create docker-compose.yml template
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  aztec-node:
    image: aztecprotocol/aztec:latest
    ports:
      - "40400:40400"
      - "8080:8080"
    restart: unless-stopped
    env_file:
      - .env
EOF

echo "✅ Templates created."
echo ""
echo "🧑 Please edit your .env file now. Press Ctrl+X to save and exit."
sleep 2
nano .env

echo ""
echo "🧑 Please review or edit docker-compose.yml. Press Ctrl+X to save and exit."
sleep 2
nano docker-compose.yml

echo "✅ Files finalized."

echo "🧱 Starting docker containers..."
docker compose up -d
docker compose logs -fn 1000

echo "📂 Moving into ~/aztec folder..."
cd "$HOME/aztec"
exec bash
