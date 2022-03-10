#!/bin/sh

# PUBLISHER	mosquitto_sub
# BROKER 	-h
# TOPIC		-t


mosquitto_sub   		\
--host eu1.cloud.thethings.network 	\
--topic v3/+/devices/+/up 		\
-u formation@ttn		\
-P NNSXS.7VDQUJOXZZ5CTTCZBBWRKQOET4SBI2XOGWLWA5Y.ASP3DDVUHPFUKSYWUOIZ6IRGWDD4D6MCAYQW6FGCNRQ3NE563L5Q


# Broker TTNv3 :        eu1.cloud.thethings.network
# Broker Chirpstack :   URL_DE_VOTRE_SERVER
# Broker mosquitto :    test.mosquitto.org
# Broker HiveMQ :       broker.hivemq.com

# Topic  TTNv3 :        v3/+/devices/+/up
# Topic  Chirpstack :   application/+/device/+/event/up



