#!/bin/bash

sudo yum remove docker-ce -y
sudo rm -rf "/var/lib/docker"

sudo rm $(which docker-compose)
