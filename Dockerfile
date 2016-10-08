FROM openjdk:7-jdk
MAINTAINER Florian JUDITH <dmitry.berezovsky@logicify.com>

RUN apt-get -y update && apt-get -y install \
	sudo \
	nano 


RUN cd /usr/share  \
  && (curl -L http://www.squashtest.org/downloads/send/13-version-stable/230-squashtm-140-targz-2?lang=en | gunzip -c | tar x)


COPY startup.sh /usr/share/squash-tm/bin/startup.sh
RUN chmod +x /usr/share/squash-tm/bin/startup.sh

COPY conf /usr/share/squash-tm/bin/conf


WORKDIR /usr/share/squash-tm/bin
EXPOSE 8080
CMD ["./startup.sh"]