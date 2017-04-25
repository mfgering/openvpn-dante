# Transmission and OpenVPN
#
# Version 1.15

FROM ubuntu:14.04
MAINTAINER Mike Gering

VOLUME /data
VOLUME /config

ENV DANTE_VER 1.4.2
ENV DANTE_URL https://www.inet.no/dante/files/dante-$DANTE_VER.tar.gz
ENV DANTE_SHA baa25750633a7f9f37467ee43afdf7a95c80274394eddd7dcd4e1542aa75caad
ENV DANTE_FILE dante.tar.gz
ENV DANTE_TEMP dante
ENV DANTE_DEPS build-essential curl

# Update packages and install software
RUN set -xe \
    && apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository multiverse \
    && apt-get update \
    && apt-get install -y openvpn curl rar unrar zip unzip wget $DANTE_DEPS \
    && curl -sLO https://github.com/Yelp/dumb-init/releases/download/v1.0.1/dumb-init_1.0.1_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -rf dumb-init_*.deb \
    && mkdir $DANTE_TEMP \
        && cd $DANTE_TEMP \
        && curl -sSL $DANTE_URL -o $DANTE_FILE \
        && echo "$DANTE_SHA *$DANTE_FILE" | shasum -c \
        && tar xzf $DANTE_FILE --strip 1 \
        && ./configure \
        && make install \
        && cd .. \
        && rm -rf $DANTE_TEMP \    
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && curl -L https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz | tar -C /usr/local/bin -xzv \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc \
    && true

ADD openvpn/ /etc/openvpn/
ADD sockd.conf /etc/sockd.conf
ADD start_socks /etc/openvpn/start_socks

ENV CFGFILE /etc/sockd.conf
ENV PIDFILE /tmp/sockd.pid
ENV WORKERS 10

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    PUID=\
    PGID=

EXPOSE 1080

CMD ["dumb-init", "/etc/openvpn/start.sh"]
#CMD sockd -f $CFGFILE -p $PIDFILE -N $WORKERS
#CMD ["/bin/bash"]