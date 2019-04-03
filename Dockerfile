FROM xuvin/s6overlay:alpine-v1.22.1.0

ARG VERSION=1.4.3
ARG DOWN_LINK=https://xteve.de/download/xteve_linux.zip 
ARG BUILD_DIR=/tmp/build

ENV APPDIR=/app

ADD ${DOWN_LINK} ${BUILD_DIR}/

RUN echo "**** upgrade system ****" && \
        apk upgrade --no-cache && \
    echo "**** install build packages ****" && \
        apk add --no-cache --virtual .install-pkg unzip && \
    echo "**** install XTEVE ****" && \
        unzip ${BUILD_DIR}/xteve_linux.zip -d ${APPDIR}/ && \
        #adduser -D -H app && \
        #echo 'app:pwstr' | chpasswd && \
        rm -rf /config && \
        chown -R app:app ${APPDIR} && \
        chmod -R 770 ${APPDIR} && \
        #chmod +x ${APPDIR}/xteve && \
    echo "**** clean up ****" && \
        apk del .install-pkg && \
        rm -rf /var/cache/apk/* && \
        rm -rf /tmp/*

ADD rootfs /

ENTRYPOINT [ "/init" ]

EXPOSE 8080

