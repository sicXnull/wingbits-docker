#!/usr/bin/env bash
set -e

# Verify that all the required variables are set before starting up the application.
echo "Verifying settings..."
echo " "
sleep 2

missing_variables=false

# Begin defining all the required configuration variables.
[ -z "$WINGBITS_DEVICE_ID" ] && echo "Wingbits Device ID is missing, will abort startup." && missing_variables=true || echo "Wingbits Device ID is set: $WINGBITS_DEVICE_ID"
[ -z "$RECEIVER_HOST" ] && echo "Receiver host is missing, will abort startup." && missing_variables=true || echo "Receiver host is set: $RECEIVER_HOST"
[ -z "$RECEIVER_PORT" ] && echo "Receiver port is missing, will abort startup." && missing_variables=true || echo "Receiver port is set: $RECEIVER_PORT"
# End defining all the required configuration variables.

echo " "

if [ "$missing_variables" = true ]; then
    echo "Settings missing, aborting..."
    echo " "
    sleep infinity
fi

echo "Settings verified, proceeding with startup."
echo " "

# Variables are verified – continue with the startup procedure.
# Start vector and readsb and put them in the background.
/usr/bin/vector --watch-config &
/usr/bin/feed-wingbits --net --net-only --debug=n --quiet --net-connector localhost,30006,json_out --write-json /run/wingbits-feed --net-beast-reduce-interval 0.5 --net-heartbeat 60 --net-ro-size 1280 --net-ro-interval 0.2 --net-ro-port 0 --net-sbs-port 0 --net-bi-port 30154 --net-bo-port 0 --net-ri-port 0 --net-connector "$RECEIVER_HOST","$RECEIVER_PORT",beast_in 2>&1 | stdbuf -o0 sed --unbuffered '/^$/d' |  awk -W interactive '{print "[readsb-wingbits]     " $0}' &

# Wait for any services to exit.
wait -n