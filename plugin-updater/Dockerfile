FROM alpine:3.17.3

RUN apk add --no-cache docker-cli bash jq curl unzip

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
