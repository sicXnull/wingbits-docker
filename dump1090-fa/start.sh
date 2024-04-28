#!/usr/bin/env bash
set -e

echo "Verifying settings..."
echo " "
sleep 2

missing_variables=false

# Begin defining all the required configuration variables.

[ -z "$LAT" ] && \echo "Receiver latitude is missing, will abort startup." && missing_variables=true || echo "Receiver latitude is set: $LAT"
[ -z "$LONG" ] && echo "Receiver longitude is missing, will abort startup." && missing_variables=true || echo "Receiver longitude is set: $LONG"

# End defining all the required configuration variables.

echo " "

if [ "$missing_variables" = true ]
then
        echo "Settings missing, aborting..."
        echo " "
        sleep infinity
fi

echo "Settings verified, proceeding with startup."
echo " "

	# Variables are verified � continue with startup procedure.

# Build dump1090 configuration
dump1090configuration="--device-type rtlsdr --device "$DUMP1090_DEVICE" --lat "$LAT" --lon "$LONG" --fix --ppm "$DUMP1090_PPM" --max-range "$DUMP1090_MAX_RANGE" --net --net-heartbeat 60 --net-ro-size 1000 --net-ro-interval 0.05 --net-http-port 0 --net-ri-port 0 --net-ro-port 30002,30102 --net-sbs-port 30003 --net-bi-port 30004,30104 --net-bo-port 30005,30105 --raw --json-location-accuracy 2 --write-json /run/dump1090-fa --quiet"
if [[ -z "$DUMP1090_GAIN" ]]; then
        echo "Gain is not specified. Will enable Adaptive Dynamic Range."
        DUMP1090_ADAPTIVE_DYNAMIC_RANGE="true"
else
        echo "Gain value set manually to $DUMP1090_GAIN. Disabling adaptive gain." && dump1090configuration="${dump1090configuration} --gain $DUMP1090_GAIN"
        DUMP1090_ADAPTIVE_DYNAMIC_RANGE="false"
fi
if [[ "$DUMP1090_ADAPTIVE_DYNAMIC_RANGE" == "true" ]]; then
        echo "Enabling Adaptive Dynamic Range." && dump1090configuration="${dump1090configuration} --adaptive-range"
        if [[ "$DUMP1090_ADAPTIVE_DYNAMIC_RANGE_TARGET" != "" ]]; then
                echo "Setting Adaptive Dynamic Range Target to $DUMP1090_ADAPTIVE_DYNAMIC_RANGE_TARGET." && dump1090configuration="${dump1090configuration} --adaptive-range-target $DUMP1090_ADAPTIVE_DYNAMIC_RANGE_TARGET"
        fi
fi

if [[ "$DUMP1090_ADAPTIVE_BURST" == "true" ]]; then
        echo "Enabling Adaptive Burst." && dump1090configuration="${dump1090configuration} --adaptive-burst"
fi
if [[ "$DUMP1090_ADAPTIVE_BURST_LOUD_RATE" != "" ]]; then
        echo "Setting Adaptive Burst Loud Rate to $DUMP1090_ADAPTIVE_BURST_LOUD_RATE" && dump1090configuration="${dump1090configuration} --adaptive-burst-loud-rate $DUMP1090_ADAPTIVE_BURST_LOUD_RATE"
fi
if [[ "$DUMP1090_ADAPTIVE_BURST_QUIET_RATE" != "" ]]; then
        echo "Setting Adaptive Burst Quiet to $DUMP1090_ADAPTIVE_BURST_QUIET_RATE" && dump1090configuration="${dump1090configuration} --adaptive-burst-quiet-rate $DUMP1090_ADAPTIVE_BURST_QUIET_RATE"
fi

if [[ "$DUMP1090_ADAPTIVE_MIN_GAIN" != "" ]]; then
        echo "Setting Adaptive Minimum Gain to $DUMP1090_ADAPTIVE_MIN_GAIN." && dump1090configuration="${dump1090configuration} --adaptive-min-gain $DUMP1090_ADAPTIVE_MIN_GAIN"
fi

if [[ "$DUMP1090_ADAPTIVE_MAX_GAIN" != "" ]]; then
        echo "Setting Adaptive Maximum Gain to $DUMP1090_ADAPTIVE_MAX_GAIN." && dump1090configuration="${dump1090configuration} --adaptive-max-gain $DUMP1090_ADAPTIVE_MAX_GAIN"
fi

if [[ "$DUMP1090_SLOW_CPU" != "" ]]; then
        echo "Setting Slow CPU mode to $DUMP1090_SLOW_CPU." && dump1090configuration="${dump1090configuration} --adaptive-duty-cycle $DUMP1090_SLOW_CPU"
fi


# Start dump1090-fa and put it in the background.
/usr/bin/dump1090-fa $dump1090configuration &
  
# Start lighthttpd and put it in the background.
/usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf &
 
# Wait for any services to exit.
wait -n