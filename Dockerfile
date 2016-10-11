FROM openjdk:7-jdk
MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ARG SQUASH_TM_LANGUAGE='en'

ENV SQUASH_TM_VERSION=1.14.0

RUN apt-get -y update && apt-get -y install \
	sudo \
	supervisor \
	postgresql-client \
	mysql-client \
	nano 

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

COPY conf/install_squash-tm.sh /tmp/install_squash-tm.sh
RUN chmod +x /tmp/install_squash-tm.sh
RUN exec /tmp/install_squash-tm.sh

COPY startup.sh /usr/share/squash-tm/bin/startup.sh
RUN chmod +x /usr/share/squash-tm/bin/startup.sh

COPY conf/log4j.properties /usr/share/squash-tm/bin/conf

EXPOSE 8080

WORKDIR /usr/share/squash-tm/bin

CMD ["./startup.sh"]
# CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf -n