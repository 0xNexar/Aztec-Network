# Aztec Sequencer Node — One Command Setup

Launch a full **Aztec Network Testnet Sequencer Node** with one command. This script installs Docker, dependencies, firewall rules, 
and the latest Aztec binaries `fully automated`.

> 🛠️ **Guide by [0xNexar](https://github.com/0xNexar)**

---

## ⚠️Sequencer Node Requirements

- Ubuntu 20.04 / 22.04 VPS  
- Root access
- HW Requirements
  | RAM       | CPU       | Disk         |
  |-----------|-----------|--------------|
  | 8–16 GB   | 4–9 cores | 100+ GB SSD  |

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

 * Install system dependencies

 * Install Docker (official method)

 * Pull latest Aztec binaries

 * Open required ports via UFW

 * Start the sequencer node using Docker Compose

 * No longer need to manually edit the .env or docker-compose.yml files

---
✅ After running the setup script, you'll be prompted to enter your configuration details interactively (such as your Ethereum RPC URL, Beacon URL, private key, etc.).
Once entered, the script will automatically generate the .env and docker-compose.yml files with your values filled in — ready to use!
---

#########################################################
# 🛠 Other Commands – Useful for Managing Your Node
#########################################################

# 🔧 Edit Configuration Files

```
nano .env

```

```
nano docker-compose.yml
```

# 📜 View Logs

``` 
docker compose logs -fn 1000
```

# 🛑 Stop the Node

```
# docker compose down -v 
```

```
rm -rf ~/.aztec/alpha-testnet/data/
```

# 🔍 Find Your Node's Peer ID

```
sudo docker logs $(docker ps -q --filter ancestor=aztecprotocol/aztec:latest | head -n 1) 2>&1 | grep -i "peerId" | grep -o '"peerId":"[^"]*"' | cut -d'"' -f4 | head -n 1
```
