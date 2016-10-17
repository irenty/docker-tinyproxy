FROM alpine:latest

MAINTAINER irenty <irek@gmail.com>

RUN apk update \
    && apk add \
	bash \
        tinyproxy

ADD checkCountry.sh /checkCountry.sh
RUN chmod +x /checkCountry.sh

ADD run.sh /opt/docker-tinyproxy/run.sh
RUN chown nobody /opt/docker-tinyproxy/run.sh && chmod +x /opt/docker-tinyproxy/run.sh

ENTRYPOINT ["/opt/docker-tinyproxy/run.sh"]
