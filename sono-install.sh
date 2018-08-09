#!/bin/bash

clear && echo We start with getting all dependencies && sleep 3

#We know that you already did that, but we make it again
sudo apt-get update
sudo apt-get dist-upgrade -y

#Get all dependencies
sudo apt-get install -y build-essential libssl-dev libdb++-dev libdb-dev libboost-all-dev libqrencode-dev libminiupnpc-dev make fail2ban vim git glances nano

clear && echo We now create the SWAP to ensure that 1GB RAM is working && sleep 3

#Creating the swap file, to ensure that 1GB RAM is working
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

clear && echo Downloading the wallet from source and compile it ourself && sleep 3

#Building the wallet (Get yourself some coffee, this may takes some time)
git clone https://github.com/zPools/sonoa.git ~/sono

#Run the dependencies, to be on the save side
cd ~/sono
sudo chmod +x install-dependencies.sh
./install-dependencies.sh

#Tripple verify correct Barkley
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev 

cd ~/sono/src/leveldb
sudo chmod +x build_detect_platform
make libleveldb.a libmemenv.a
cd ~/sono/src
make -f makefile.unix

clear && echo Wallet is compiled. We now create the standard configuration && sleep 3

#Building the config
mkdir ~/.SONO/
touch ~/.SONO/SONO.conf
ex -sc '1i|addnode=multi.zPools.de' -cx ~/.SONO/SONO.conf
ex -sc '1i|addnode=zPools.de' -cx ~/.SONO/SONO.conf
ex -sc '1i|#masternodeprivkey=”Private Key”' -cx ~/.SONO/SONO.conf
ex -sc '1i|#masternodeaddr=”Change it to server IP:Port (26855)”' -cx ~/.SONO/SONO.conf
ex -sc '1i|#masternode=1' -cx ~/.SONO/SONO.conf
ex -sc '1i|port=26855' -cx ~/.SONO/SONO.conf
ex -sc '1i|listen=1' -cx ~/.SONO/SONO.conf
ex -sc '1i|server=1' -cx ~/.SONO/SONO.conf
ex -sc '1i|daemon=1' -cx ~/.SONO/SONO.conf
ex -sc '1i|rpcpassword=MakeItRandom' -cx ~/.SONO/SONO.conf
ex -sc '1i|rpcuser=NeedToSoundCool' -cx ~/.SONO/SONO.conf

clear && echo Configuration is set, we now make it smoother to work with && sleep 3

#Make it smooth to use
sudo cp ~/sono/src/SONOd /usr/bin

#Set the wallet to “autostart”
crontab -l > mycron
echo "@reboot SONOd" >> mycron
crontab mycron
rm mycron

#Starting the wallet
SONOd

clear && echo The wallet is now running. Now the server builds the chain. You now need to edit the config file.
