FROM openjdk:22-jdk-slim

ENV KAFKA_URL="https://downloads.apache.org/kafka/3.5.1/kafka_2.13-3.5.1.tgz"

RUN set -x \
	&& DEBIAN_FRONTEND=noninteractive apt-get update --quiet \
	&& DEBIAN_FRONTEND=noninteractive apt-get upgrade --quiet --yes \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --quiet --yes --no-install-recommends \
	curl \
	tar \
	netcat-traditional \
	&& DEBIAN_FRONTEND=noninteractive apt-get autoremove --yes \
	&& DEBIAN_FRONTEND=noninteractive apt-get clean


RUN set -x \
	&& mkdir -p "/kafka" \
	&& curl -Ls "${KAFKA_URL}" | tar -xz --directory /kafka --strip-components=1 --no-same-owner

COPY files/server.properties /server.properties.template
COPY files/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/kafka/bin/kafka-server-start.sh","/server.properties"]
