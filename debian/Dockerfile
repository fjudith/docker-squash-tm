FROM tomcat:8-jre8
MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ENV TERM='xterm'

ENV SQUASH_TM_VERSION='1.18.4'
ENV SQUASH_TM_URL='https://www.squashtest.org/telechargements/send/13-version-stable/298-stm-1184-targz'
ENV CATALINA_HOME='/usr/local/tomcat'
ENV JAVA_OPTS="-Xmx1024m -XX:MaxPermSize=256m"

RUN apt-get -y update && apt-get -y install \
	postgresql-client \
	mysql-client \
	xmlstarlet \
	netcat \
	nano && \
	apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost

COPY conf/squash-tm.xml /usr/local/tomcat/conf/Catalina/localhost/squash-tm.xml

RUN cd /usr/share && \
	curl -L ${SQUASH_TM_URL} | gunzip -c | tar x

# Copy WAR to webapps
RUN cp /usr/share/squash-tm/bundles/squash-tm.war ${CATALINA_HOME}/webapps/

COPY docker-entrypoint.sh /usr/share/squash-tm/bin/docker-entrypoint.sh

RUN chmod +x /usr/share/squash-tm/bin/docker-entrypoint.sh

COPY conf/log4j2.xml /usr/share/squash-tm/bin/conf/

EXPOSE 8080

WORKDIR ${CATALINA_HOME}

ENTRYPOINT ["/usr/share/squash-tm/bin/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]
