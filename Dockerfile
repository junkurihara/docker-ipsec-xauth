FROM debian:buster-slim

LABEL maintainer="Original: Lin Song <linsongui@gmail.com>"
LABEL maintainer="Modified by: Jun Kurihara <kurihara@ieee.org>"

ENV REFRESHED_AT 2020-05-19
ENV SWAN_VER 3.32

WORKDIR /opt/src

RUN apt-get -yqq update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -yqq --no-install-recommends install \
         wget dnsutils openssl ca-certificates kmod iproute2 \
         gawk net-tools iptables bsdmainutils libcurl3-nss \
         libnss3-tools libevent-dev xl2tpd \
         libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
         libcap-ng-dev libcap-ng-utils libselinux1-dev \
         libcurl4-nss-dev flex bison gcc make \
    && wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://github.com/libreswan/libreswan/archive/v${SWAN_VER}.tar.gz" \
    || wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://download.libreswan.org/libreswan-${SWAN_VER}.tar.gz" \
    && tar xzf libreswan.tar.gz \
    && rm -f libreswan.tar.gz \
    && cd "libreswan-${SWAN_VER}" \
    && printf 'WERROR_CFLAGS = -w\nUSE_DNSSEC = false\nUSE_DH31 = false\n' > Makefile.inc.local \
    && printf 'USE_NSS_AVA_COPY = true\nUSE_NSS_IPSEC_PROFILE = false\n' >> Makefile.inc.local \
    && printf 'USE_GLIBC_KERN_FLIP_HEADERS = true\nUSE_SYSTEMD_WATCHDOG = false\n' >> Makefile.inc.local \
    && printf 'USE_DH2 = true\n' >> Makefile.inc.local \
    && make -s base \
    && make -s install-base \
    && cd /opt/src \
    && rm -rf "/opt/src/libreswan-${SWAN_VER}" \
    && apt-get -yqq remove \
         libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
         libcap-ng-dev libcap-ng-utils libselinux1-dev \
         libcurl4-nss-dev flex bison gcc make \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --set iptables /usr/sbin/iptables-legacy

COPY /docker-bin/run.sh /opt/src/run.sh
COPY /docker-bin/generate-mobileconfig.sh /opt/src/generate-mobileconfig.sh
RUN chmod 755 /opt/src/*.sh && \
    mkdir -p /data

EXPOSE 500/udp 4500/udp

#VOLUME ["/lib/modules"]
VOLUME ["/var/log/ipsec/", "/data"]

CMD ["/opt/src/run.sh"]

