#!/bin/bash
CHIRPSTACK_DIR="$HOME/chirpstack"

if [ -d "$CHIRPSTACK_DIR" ]; then
    cd "$CHIRPSTACK_DIR"
    sudo docker-compose down
    rm -rf "$CHIRPSTACK_DIR"
fi
