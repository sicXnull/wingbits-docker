FROM debian:bookworm
LABEL maintainer="sic"

EXPOSE 30001 30002 30003 30004 30005 30102 30104 30105 30106 8080

ENV DUMP1090_DEVICE=default_device
ENV DUMP1090_GAIN=default_gain
ENV DUMP1090_PPM=default_ppm
ENV DUMP1090_MAX_RANGE=default_max_range
ENV DUMP1090_ADAPTIVE_DYNAMIC_RANGE=default_adaptive_dynamic_range
ENV DUMP1090_ADAPTIVE_BURST=default_adaptive_burst
ENV DUMP1090_ADAPTIVE_MIN_GAIN=default_adaptive_min_gain
ENV DUMP1090_ADAPTIVE_MAX_GAIN=default_adaptive_max_gain
ENV DUMP1090_SLOW_CPU=default_slow_cpu

ARG PERM_INSTALL="tini lighttpd gettext-base libusb-1.0-0 libbladerf2 libhackrf0 liblimesuite22.09-1 librtlsdr0 rtl-sdr libsoapysdr0.8 libncurses6"

RUN apt update && \
	apt install -y $PERM_INSTALL && \
	apt clean && apt autoclean && apt autoremove && \
	rm -rf /var/lib/apt/lists/*


ARG DUMP1090_VERSION=v9.0
ARG TEMP_INSTALL="git build-essential fakeroot cmake debhelper pkg-config libncurses5-dev libbladerf-dev libhackrf-dev liblimesuite-dev libusb-1.0-0-dev libsoapysdr-dev librtlsdr-dev apt-utils apt-transport-https debhelper"

RUN apt update && \
	apt install -y $TEMP_INSTALL

WORKDIR /tmp

# Clone dump1090 repository, build the package, and copy the .deb files
RUN git clone https://github.com/flightaware/dump1090 && \
    cd dump1090 && \
    git checkout tags/${DUMP1090_VERSION} && \
    dpkg-buildpackage -b --no-sign

# Copy other necessary scripts
COPY start.sh /
COPY add-serial-1090.sh /
COPY showstrongmessages.sh /

RUN dpkg -i dump1090-fa_*.deb && \
	rm -rf /tmp/* && \
	mkdir -p /run/dump1090-fa && \
	chmod +x /start.sh && \
	chmod +x /add-serial-1090.sh && \
	chmod +x /showstrongmessages.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/start.sh"]