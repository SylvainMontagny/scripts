#!/bin/bash

# Install utilities
sudo apt-get install git wget nano unzip iptables -y

# Uninstall Documents and arduino-cli
cd ~
sudo rm -rf Documents.zip
sudo rm -rf Arduino/
sudo rm -rf Documents-formation-LoRaWAN/

# arduino-cli install 
mkdir Arduino
cd ~/Arduino/
mkdir libraries
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
echo 'PATH="~/Arduino/bin:$PATH"' >> ~/.bashrc
echo 'export PATH' >> ~/.bashrc
export PATH=$PATH:~/Arduino/bin
arduino-cli config init --overwrite
arduino-cli config add board_manager.additional_urls https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json
arduino-cli core update-index
arduino-cli core install STMicroelectronics:stm32
arduino-cli config set sketch.always_export_binaries true

# Documents install
cd ~
wget http://lora.master-stic.fr/Documents.zip --http-user=admin --http-passwd=lorawan
unzip Documents.zip
cp -r Documents-formation-LoRaWAN/Librairies-a-copier/* Arduino/libraries/
cp -r Documents-formation-LoRaWAN/Programme-Device-LoRa/* Arduino/

# First Compilation
cd $HOME/Arduino/
rm -rf temp
mkdir temp
cp Sensors-I-Nucleo-LRWAN/Sensors-I-Nucleo-LRWAN.ino temp/temp.ino
arduino-cli compile -b STMicroelectronics:stm32:Nucleo_64:opt=o3std,pnum=NUCLEO_L073RZ  temp/temp.ino
cp temp/build/STMicroelectronics.stm32.Nucleo_64/temp.ino.bin $HOME/Upload_this_binary_to_your_Device.bin
