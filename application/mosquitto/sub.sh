#!/bin/sh

# PUBLISHER	mosquitto_sub
# BROKER 	-h
# TOPIC		-t


mosquitto_sub  \
-h test.mosquitto.org \
-t montagny \
-F "%J"



# Broker TTNv3 :        eu1.cloud.thethings.network
# Broker Chirpstack :   URL_DE_VOTRE_SERVER
# Broker mosquitto :    test.mosquitto.org
# Broker HiveMQ :       broker.hivemq.com

# Topic  TTNv3 :        v3/+/devices/+/up
# Topic  Chirpstack :   application/+/device/+/event/up



