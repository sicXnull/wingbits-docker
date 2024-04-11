FROM ubuntu:20.04 AS base
LABEL maintainer="sic"

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 30154

ENV WINGBITS_DEVICE_ID=${WINGBITS_DEVICE_ID}
ENV RECEIVER_HOST=dump1090-fa
ENV RECEIVER_PORT=30005

ARG PERM_INSTALL="curl gettext-base tini" 

RUN apt-get update && \
    apt-get install -y ca-certificates --no-install-recommends $PERM_INSTALL sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM base AS buildstep

ARG READSB_COMMIT=f535e517996ad04ce8126a58757a9b91a82fe542
ARG TEMP_INSTALL="git build-essential debhelper libncurses5-dev zlib1g-dev python3-dev libzstd-dev"

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y --no-install-recommends $TEMP_INSTALL ca-certificates && \
    update-ca-certificates && \
    git clone --single-branch https://github.com/adsb-related-code/readsb && \
    cd readsb && \
    git checkout $READSB_COMMIT && \
    make -j3 AIRCRAFT_HASH_BITS=14 && \
    apt-get purge -y --auto-remove $TEMP_INSTALL && \
    rm -rf /var/lib/apt/lists/*

FROM base AS release

COPY wingbits_installer.sh /tmp
COPY start.sh /
COPY --from=buildstep /tmp/readsb/readsb /usr/bin/feed-wingbits

WORKDIR /tmp

RUN chmod +x /tmp/wingbits_installer.sh && \
    /tmp/wingbits_installer.sh && \
    chmod +x /start.sh && \
    mkdir -p /run/wingbits-feed && \
    rm -rf /tmp/*

COPY vector.yaml /etc/vector/vector.yaml

ENTRYPOINT ["/usr/bin/tini", "--", "/start.sh"]