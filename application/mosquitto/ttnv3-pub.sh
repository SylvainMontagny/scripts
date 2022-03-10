#!/bin/sh

mosquitto_pub --debug \
--host      eu1.cloud.thethings.network \
--username  formation@ttn \
--pw        NNSXS.7VDQUJOXZZ5CTTCZBBWRKQOET4SBI2XOGWLWA5Y.ASP3DDVUHPFUKSYWUOIZ6IRGWDD4D6MCAYQW6FGCNRQ3NE563L5Q \
--topic     v3/formation@ttn/devices/i-nucleo-otaa/down/replace \
--message   "{
            \"downlinks\":[{
            \"f_port\":15,
            \"frm_payload\":\"aGVsbG8=\",
            \"priority\":\"NORMAL\"
            }]
            }
            "



# Topic  TTNv3 : 	v3/+/devices/+/up
# Topic  Chirpstack :	application/+/device/+/event/up


  


