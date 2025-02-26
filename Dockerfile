FROM alpine:3
ARG TARGETARCH
ARG SPEEDTEST_VERSION=1.2.0

COPY entrypoint.sh speedtest2mqtt.sh /opt/
COPY crontab.yml /home/foo/

RUN addgroup -S foo && adduser -S foo -G foo && \
    chmod +x /opt/speedtest2mqtt.sh /opt/entrypoint.sh && \
    chown foo:foo /home/foo/crontab.yml && \
    apk --no-cache add bash mosquitto-clients jq python3

RUN apk --no-cache add wget --virtual .build-deps && \
    echo "Target Arch $TARGETARCH" && \
    if test "$TARGETARCH" = 'amd64'; then wget https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-x86_64.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if test "$TARGETARCH" = 'arm'; then wget https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-armel.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if test "$TARGETARCH" = 'arm64'; then wget https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-armhf.tgz -O /var/tmp/speedtest.tar.gz; fi && \

    tar xf /var/tmp/speedtest.tar.gz -C /var/tmp && \
    mv /var/tmp/speedtest /usr/local/bin && \
    rm /var/tmp/speedtest.tar.gz && \
    apk del --no-cache .build-deps

RUN apk --no-cache add gcc musl-dev python3-dev --virtual .build-deps && \
    python3 -m venv yacronenv && \
    . yacronenv/bin/activate && \
    pip install yacron && \
    apk del --no-cache .build-deps

USER foo
ENTRYPOINT /opt/entrypoint.sh
