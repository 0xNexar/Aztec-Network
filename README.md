# Aztec Sequencer Node — One Command Setup

Launch a full **Aztec Network Testnet Sequencer Node** with one command. This script installs Docker, dependencies, firewall rules, and the latest Aztec binaries — fully automated.

> 🛠️ **Guide by [0xNexar](https://github.com/0xNexar)**

---

## ⚠️ Requirements

- Ubuntu 20.04 / 22.04 VPS  
- Root access  

---

## 🧰 Step 1: Install `sudo` and `curl` (if missing)

If you're on a fresh VPS and see `sudo: command not found` or `curl: command not found`, do this first:

```bash

apt-get update && apt-get install -y sudo
```
```bash

sudo apt-get install -y curl
```

## Step 2: Run the Aztec Setup Script


Once `sudo` and `curl` are installed, run this one-liner:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/0xNexar/Aztec-Network/main/run.sh)"
```

✅ This will:

Install system dependencies

Install Docker (official method)

Pull latest Aztec binaries

Open required ports via UFW

Start the sequencer node using Docker Compose

---

## 📝 Customize Your `.env` and `docker-compose.yml`

After running the setup script and creating the files `.env` and `docker-compose.yml`, you need to **replace placeholders with your own values**.

### Get Free RPC through [@cerberus_service_bot](http://t.me/cerberus_service_bot) = 3 days Free trial
---

nano.ev

```
ETHEREUM_RPC_URL=RPC_URL
CONSENSUS_BEACON_URL=BEACON_URL
VALIDATOR_PRIVATE_KEY=0xYourPrivateKey
COINBASE=0xYourAddress
P2P_IP=YourIP
```

docker-compose.yml
```
version: '3.8'

services:
  aztec-node:
    container_name: aztec-sequencer
    image: aztecprotocol/aztec:0.87.9
    restart: unless-stopped
    environment:
      ETHEREUM_HOSTS: RPC_URL
      L1_CONSENSUS_HOST_URLS: BEACON_URL
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEY: 0xYourPrivateKey
      COINBASE: 0xYourAddress
      P2P_IP: YourIP
      LOG_LEVEL: debug
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'    
    ports:
      - "8081:8080" 
      - "40400:40400/tcp"
      - "40400:40400/udp"
    volumes:
      - /root/.aztec/alpha-testnet/data/:/data
```

