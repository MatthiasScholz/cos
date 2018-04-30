# fluentd/Dockerfile
FROM alpine:3.5
COPY hello.sh /
CMD chmod +x /hello.sh

RUN apk add --update \
    curl bind-tools wget \
    && rm -rf /var/cache/apk/*

ENTRYPOINT /hello.sh