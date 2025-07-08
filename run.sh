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
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

echo "🐳 Installing Docker..."
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "✅ Testing Docker installation..."
sudo docker run hello-world
sudo systemctl enable docker
sudo systemctl restart docker

echo "🌐 Installing Aztec..."
bash -i <(curl -s https://install.aztec.network)
echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "⬇️ Pulling latest Aztec release..."
aztec-up latest

echo "🛡️ Configuring firewall..."
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

echo "📦 Setting up Aztec sequencer..."
mkdir -p ~/aztec && cd ~/aztec

# Replace with given code
touch .env
touch docker-compose.yml

echo "✅ Files created: .env and docker-compose.yml"
echo "🧱 Starting docker containers..."
docker compose up -d
docker compose logs -fn 1000

