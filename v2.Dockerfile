FROM xuvin/s6overlay:alpine-latest

ARG VERSION=2.0.0
ARG PKGNAME=xteve_linux_amd64
ARG DOWN_LINK=https://github.com/xteve-project/xTeVe-Downloads/blob/master/${PKGNAME}.zip?raw=true
ARG BUILD_DIR=/tmp/build

ENV APPDIR=/app

ADD ${DOWN_LINK} ${BUILD_DIR}/

RUN echo "**** upgrade system ****" && \
    apk upgrade --no-cache && \
    echo "**** install build packages ****" && \
    apk add --no-cache --virtual .install-pkg unzip && \
    echo "**** install curl for healthcheck and ffmpeg for buffering****" && \
    apk add --no-cache curl ffmpeg && \
    echo "**** install XTEVE ****" && \
    unzip ${BUILD_DIR}/${PKGNAME}.zip -d ${APPDIR}/ && \
    chown -R app:app ${APPDIR} && \
    chmod -R 770 ${APPDIR} && \
    echo "**** clean up ****" && \
    apk del .install-pkg && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

ADD rootfs /

WORKDIR ${APPDIR}

#VOLUME [ "/app/config" ]
#VOLUME [ "/tmp/xteve" ]

EXPOSE 8080

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost:33440/web || exit 1

ENTRYPOINT [ "/init" ]

