FROM tomcat:8-jre8-alpine

LABEL maintainer 'Florian JUDITH <florian.judith.b@gmail.com>'

ENV TERM='xterm'

ENV SQUASH_TM_VERSION='1.18.5'
ENV SQUASH_TM_URL="http://repo.squashtest.org/distribution/squash-tm-${SQUASH_TM_VERSION}.RELEASE.tar.gz"
ENV CATALINA_HOME='/usr/local/tomcat'
ENV JAVA_OPTS="-Xmx1024m -XX:MaxPermSize=256m"

RUN apk add \
	postgresql-client \
	mysql-client \
	xmlstarlet \
	curl \
	nano

RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost

COPY conf/squash-tm.xml /usr/local/tomcat/conf/Catalina/localhost/squash-tm.xml

RUN cd /usr/share && \
	curl -L ${SQUASH_TM_URL} | tar xzf -

# Copy WAR to webapps
RUN cp /usr/share/squash-tm/bundles/squash-tm.war ${CATALINA_HOME}/webapps/

COPY docker-entrypoint.sh /usr/share/squash-tm/bin/docker-entrypoint.sh

RUN chmod +x /usr/share/squash-tm/bin/docker-entrypoint.sh

COPY conf/log4j2.xml /usr/share/squash-tm/bin/conf/

EXPOSE 8080

WORKDIR ${CATALINA_HOME}

ENTRYPOINT ["/usr/share/squash-tm/bin/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]
