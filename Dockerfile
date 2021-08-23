FROM buildpack-deps:jessie

RUN apt-get update && apt-get install -y \
    libgmp-dev \
    iptables \
    xl2tpd \
    module-init-tools \
    supervisor

RUN mkdir /conf

ENV STRONGSWAN_VERSION 5.5.0

RUN mkdir -p /usr/src/strongswan \
    && curl -SL "https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.gz" | tar -zxC /usr/src/strongswan --strip-components 1 \
    && cd /usr/src/strongswan \
    && ./configure --prefix=/usr --sysconfdir=/etc --enable-eap-radius --enable-eap-mschapv2 --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2 --enable-eap-tls --enable-eap-ttls --enable-eap-peap --enable-eap-tnc --enable-eap-dynamic --enable-xauth-eap --enable-openssl \
    && make -j \
    && make install \
    && rm -rf /usr/src/strongswan

COPY etc/ipsec.conf /etc/ipsec.conf

COPY etc/strongswan.conf /etc/strongswan.conf

COPY etc/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf

COPY etc/options.xl2tpd /etc/ppp/options.xl2tpd

COPY etc/run.sh /run.sh

COPY usr/local/bin/* /usr/local/bin/

ENV VPN_USER=user
ENV VPN_PASSWORD=password
ENV VPN_PSK=password

VOLUME /etc/ipsec.d

EXPOSE 4500/udp 500/udp

RUN chmod +x /run.sh

CMD ["/run.sh"]