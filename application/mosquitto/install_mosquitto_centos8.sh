#!/bin/bash

sudo yum -y install epel-release
sudo yum -y install mosquitto
sudo systemctl start mosquitto
sudo systemctl enable mosquitto

