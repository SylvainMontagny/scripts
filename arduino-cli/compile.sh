#!/bin/bash

source ~/config_device.sh

DIR_BIN_OUTPUT=$HOME

rm -rf $DIR_BIN_OUTPUT/lorawanApp.bin

cd $HOME/Arduino/
rm -rf temp
mkdir temp
cp lorawanApp/lorawanApp.ino temp/temp.ino

# Activation MODE
sed -i -e "s/#define ACTIVATION_MODE/#define ACTIVATION_MODE $ACTIVATION_MODE/g" temp/temp.ino

# Sending method
sed -i -e "s/#define SEND_BY_PUSH_BUTTON/#define SEND_BY_PUSH_BUTTON $SEND_BY_PUSH_BUTTON/g" temp/temp.ino

# Time between 2 frames
sed -i -e "s/#define FRAME_DELAY/#define FRAME_DELAY $FRAME_DELAY/g" temp/temp.ino

# Data Rate
sed -i -e "s/#define DATA_RATE/#define DATA_RATE $DATA_RATE/g" temp/temp.ino

# Enable ADR
sed -i -e "s/#define ADAPTIVE_DR/#define ADAPTIVE_DR $ADAPTIVE_DR/g" temp/temp.ino

# Unconfirmed or Confirmed messages
sed -i -e "s/#define CONFIRMED/#define CONFIRMED $CONFIRMED/g" temp/temp.ino

# Application Port number
sed -i -e "s/#define PORT/#define PORT $PORT/g" temp/temp.ino

# ABP Credentials
sed -i -e "s/const char devAddr\[\] = \"\"/const char devAddr\[\]= \"$DEVADDR\"/g" temp/temp.ino
sed -i -e "s/const char nwkSKey\[\] = \"\"/const char nwkSKey\[\]= \"$NWKSKEY\"/g" temp/temp.ino
sed -i -e "s/const char appSKey\[\] = \"\"/const char appSKey\[\]= \"$APPSKEY\"/g" temp/temp.ino

# OTAA Credentials
sed -i -e "s/const char appEUI\[\] = \"\"/const char appEUI\[\]= \"$APPEUI\"/g" temp/temp.ino
sed -i -e "s/const char appKey\[\] = \"\"/const char appKey\[\]= \"$APPKEY\"/g" temp/temp.ino


arduino-cli compile -b STMicroelectronics:stm32:Nucleo_64:opt=o3std,pnum=NUCLEO_L073RZ  temp/temp.ino


NAME_BIN_OUTPUT=$ACTIVATION_MODE

if [  $SEND_BY_PUSH_BUTTON = "true" ]
    then NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_PB"
    else NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_"$FRAME_DELAY
fi

case $DATA_RATE in

  0)
   NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_SF12"
   ;;
  1)
   NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_SF11"
   ;;
  2)
   NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_SF10"
   ;;
  3)
   SNAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_SF9"
   ;;
  4)
   NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_SF8"
   ;;
  5)
   NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_SF7"
   ;;
esac

if [  $ADAPTIVE_DR = "true" ]
    then NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_ADRon"
    else NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_ADRoff"
fi

if [  $CONFIRMED = "true" ]
    then NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_Conf"
    else NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_Unconf"
fi

if [  $ACTIVATION_MODE = "ABP" ]
    then NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_AppSKey_"$APPSKEY".bin"
    else NAME_BIN_OUTPUT=$NAME_BIN_OUTPUT"_AppKey_"$APPKEY".bin"
fi


cp temp/build/STMicroelectronics.stm32.Nucleo_64/temp.ino.bin $DIR_BIN_OUTPUT/lorawanApp.bin
mv $DIR_BIN_OUTPUT/lorawanApp.bin  "$DIR_BIN_OUTPUT/$NAME_BIN_OUTPUT"
