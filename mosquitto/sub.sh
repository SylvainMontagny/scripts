#!/bin/sh

# PUBLISHER
mosquitto_pub \
# BROKER
-h test.mosquitto.org \
# TOPIC
-t montagny \
# MESSAGE
-m hello_world

 
