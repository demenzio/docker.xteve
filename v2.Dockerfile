FROM xuvin/s6overlay:alpine-v1.22.1.0

ARG VERSION=2.0.0
ARG PKGNAME=xteve_2_linux_amd64
ARG DOWN_LINK=https://xteve.de/download/${PKGNAME}.zip
ARG BUILD_DIR=/tmp/build

ENV APPDIR=/app

ADD ${DOWN_LINK} ${BUILD_DIR}/

RUN echo "**** upgrade system ****" && \
        apk upgrade --no-cache && \
    echo "**** install build packages ****" && \
        apk add --no-cache --virtual .install-pkg unzip && \
    echo "**** install curl for healthcheck ****" && \
        apk add --no-cache curl && \
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

