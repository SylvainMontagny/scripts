#!/bin/sh

# PUBLISHER	mosquitto_pub
# BROKER 	-h
# TOPIC		-t
# MESSAGE	-m

mosquitto_pub  \
-h test.mosquitto.org \
-t montagny \
-m  "{
    "confirmed": false,
    "fPort": 10,
    "data": "aGVsbG8="
    }" 

