#!/bin/bash

clear && echo We start with getting all dependencies && sleep 3

#We know that you already did that, but we make it again
sudo apt-get update
sudo apt-get dist-upgrade -y


#Get all dependencies
sudo apt-get install -y build-essential libssl-dev libdb++-dev libdb-dev libboost-all-dev libqrencode-dev libminiupnpc-dev make fail2ban vim git glances


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
git clone https://github.com/altcommunitycoin/altcommunitycoin-skunk.git altcom
cd ~/altcom/src/leveldb
sudo chmod +x build_detect_platform
make libleveldb.a libmemenv.a
cd ~/altcom/src
make -f makefile.unix


clear && echo Wallet is compiled. We now create the standard configuration && sleep 3

#Building the config
mkdir ~/.altcommunitycoin/
touch ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|addnode=multi.zPools.de' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|addnode=zPools.de' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|masternodeprivkey=”Private Key”' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|masternodeaddr=”Change it to server IP:Port”' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|masternode=1' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|port=26855' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|irc=0' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|listen=1' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|server=1' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|daemon=1' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|rpcpassword=MakeItRandom' -cx ~/.altcommunitycoin/altcommunitycoin.conf
ex -sc '1i|rpcuser=NeedToSoundCool' -cx ~/.altcommunitycoin/altcommunitycoin.conf

clear && echo Configuration is set, we now make it smoother to work with && sleep 3

#Make it smooth to use
sudo cp ~/altcom/src/altcommunitycoind /usr/bin

#Set the wallet to “autostart”
crontab -l > mycron
echo "@reboot altcommunitycoind" >> mycron
crontab mycron
rm mycron

#Starting the wallet and end with ~/
altcommunitycoind
cd
clear && echo The wallet is now running. Now the server builds the chain. You now need to edit the config file.

