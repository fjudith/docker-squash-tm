FROM openjdk:7-jdk
MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

RUN apt-get -y update && apt-get -y install \
	sudo \
	supervisor \
	postgresql-client \
	mysql-client \
	nano 

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor

RUN cd /usr/share  \
  && (curl -L http://www.squashtest.org/downloads/send/13-version-stable/230-squashtm-140-targz-2?lang=en | gunzip -c | tar x)


COPY startup.sh /usr/share/squash-tm/bin/startup.sh
RUN chmod +x /usr/share/squash-tm/bin/startup.sh

COPY conf/log4j.properties /usr/share/squash-tm/bin/conf

EXPOSE 8080

WORKDIR /usr/share/squash-tm/bin

CMD ["./startup.sh"]
# CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf -n