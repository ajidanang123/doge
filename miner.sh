#!/bin/bash

echo ========================================================================
echo Before continuing make sure you have your DOGE wallet address at hand
echo ========================================================================
read -p "press enter to continue"

echo DOGE Wallet Address: ; read wallet_address ; export wallet_address

echo updating
apt update > /dev/null 2>&1

echo upgrading
apt -y upgrade > /dev/null 2>&1

echo installing prerequisites
apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev > /dev/null 2>&1

echo cloning repository
git clone https://github.com/xmrig/xmrig.git > /dev/null 2>&1

echo creating directories
cd xmrig ; mkdir build ; cd build

echo building binary
cmake .. > /dev/null 2>&1 ; make

echo downloading configuration
wget https://raw.githubusercontent.com/xmrig/xmrig/master/src/config.json > /dev/null 2>&1

echo modifying configuration
sed -i "s/donate.v2.xmrig.com:3333/rx.unmineable.com:3333/g" $HOME/xmrig/build/config.json
sed -i "s/YOUR_WALLET_ADDRESS/DOGE:$wallet_address.$HOSTNAME/g" $HOME/xmrig/build/config.json

echo creating service
cat <<EOL >> /etc/systemd/system/miner.service
[Unit]
Description=miner
After=network.target

[Service]
ExecStart=/bin/bash -c "while true ; do $HOME/xmrig/build/xmrig ; done"
Restart=always

[Install]
WantedBy=multi-user.target
EOL

echo starting service
systemctl daemon-reload
systemctl start miner.service
systemctl enable miner.service > /dev/null 2>&1

echo monitoring service
journalctl -f -u miner.service
