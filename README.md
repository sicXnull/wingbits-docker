# Wingbits - Docker

Wingbits/Dump1090/Graphs1090 via Docker-Compose

## Install

To install with prebuilt containers. 

```cd /opt```

```wget https://raw.githubusercontent.com/sicXnull/wingbits-docker/main/docker-compose.yml```

Edit the following variables in docker-compose file

``LAT: ""`` 

```LONG: ""``` 

```WINGBITS_DEVICE_ID: ""```

```timezone ""```

Spin up the container

```docker-compose up -d```

## Optional Variables

The following can also be changed, or leave as is for default settings

      DUMP1090_DEVICE: "0" 
      DUMP1090_GAIN: "" #leave blank for default
      DUMP1090_PPM: "0" 
      DUMP1090_MAX_RANGE: "360" 
      DUMP1090_ADAPTIVE_DYNAMIC_RANGE: "" 
      DUMP1090_ADAPTIVE_BURST: "" 
      DUMP1090_ADAPTIVE_MIN_GAIN: "" 
      DUMP1090_ADAPTIVE_MAX_GAIN: "" 
      DUMP1090_SLOW_CPU: "" 

## Build from Source

```cd /opt```

```git clone https://github.com/sicXnull/wingbits-docker.git```

```docker-compose -f docker-compose-build.yml up -d```

