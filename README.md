[![](https://images.microbadger.com/badges/image/fjudith/squash-tm.svg)](https://microbadger.com/images/fjudith/squash-tm "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/fjudith/docker-squash-tm.svg?branch=master)](https://travis-ci.org/fjudith/docker-squash-tm)

# Introduction
Squash TM is the test repository manager found in the open source Squash toolkit. It enables the management of requirements, test cases and campaigns execution in a multiproject context.

# Description
The Dockerfile builds from "Tomcat:8-jre7" see https://hub.docker.com/_/tomcat/

[1.19.0](https://github.com/fjudith/docker-squash-tm/tree/1.19.0/debian)
[1.19.0-alpine, alpine](https://github.com/fjudith/docker-squash-tm/tree/1.19.0/alpine)
[1.18.5](https://github.com/fjudith/docker-squash-tm/tree/1.18.5/debian)
[1.18.5-alpine, alpine](https://github.com/fjudith/docker-squash-tm/tree/1.18.5/alpine)
[1.18.4](https://github.com/fjudith/docker-squash-tm/tree/1.18.4/debian)
[1.18.4-alpine, alpine](https://github.com/fjudith/docker-squash-tm/tree/1.18.4/alpine)
[1.18.0](https://github.com/fjudith/docker-squash-tm/tree/1.18.0/debian)
[1.18.0-alpine](https://github.com/fjudith/docker-squash-tm/tree/1.18.0/alpine)
[1.17.4](https://github.com/fjudith/docker-squash-tm/tree/1.17.4)
[1.17.0](https://github.com/fjudith/docker-squash-tm/tree/1.17.0)
[1.16.0](https://github.com/fjudith/docker-squash-tm/tree/1.16.0)
[1.15.4](https://github.com/fjudith/docker-squash-tm/tree/1.15.4)
[1.15.3](https://github.com/fjudith/docker-squash-tm/tree/1.15.3)
[1.15.1](https://github.com/fjudith/docker-squash-tm/tree/1.15.1)
[1.15.0](https://github.com/fjudith/docker-squash-tm/tree/1.15.0)
[1.14.2](https://github.com/fjudith/docker-squash-tm/tree/1.14.2)

[Kubernetes](https://github.com/fjudith/docker-squash-tm/tree/master/kubernetes)

# Roadmap

* [X] Implement support Reverse-proxy via environment variable.
* [X] Fix container restart issue when Reverse-proxy configured.
* [X] LDAP authentication support

# Quick Start
Run the Squash-TM image:

```
docker run --name='squash-tm' -it --rm -p 8080:8080 fjudith/squash-tm
```

NOTE: Please allow a few minutes for the applicaton to start, especially if populating the database for the first time. If you want to make sur that everything went fine, watch the log:

```
docker exec -it squash-tm bash
tail -f ../logs/squash-tm.log
```

Go to `http://localhost:8080/squash` or point to the IP of your docker host.  On
Mac or Windows, replace `localhost` with the IP address of your Docker host which you can get using

```bash
docker-machine ip default
```

The default username and password are:
* username: **admin**
* password: **admin**

# Configuration

## Persistent Volumes

If you use this image in production, you'll probably want to persist the following locations in a volume

```
/usr/share/squash-tm/tmp                         # Jetty tmp and work directory
/usr/share/squash-tm/bundles                     # Bundles directory
/usr/share/squash-tm/conf                        # Configurations directory
/usr/share/squash-tm/logs                        # Log directory
/usr/share/squash-tm/jettyhome                   # Jetty home directory
/usr/share/squash-tm/luceneindexes               # Lucene indexes directory
/usr/share/squash-tm/plugins                     # Plugins directory
```

## Environment variables

Default `DB_TYPE` is H2
The following environment variables allows to change for MySQL or PostgreSQL.

* **DB_TYPE**: Database type, one of h2, mysql, postgresql; default=`mysql`
* **DB_HOST**: Hostname of the database container; default=`mysql`
* **DB_PORT**: database engine listen port (3306=mysql, 5432=postgres); default=`3306`
* **DB_NAME**: Name of the database; default=`squash-tm`
* **DB_USERNAME**: Database username; default=`root`
* **DB_PASSWORD**: Database password; default=`root`
* **DB_URL**: DataBase URL; default=`jdbc:${DB_TYPE}://${DB_HOST}:${DB_PORT}/$DB_NAME`

The following environment variables enable the support of  reverse-proxy (e.g. haproxy with https frontend)

* **REVERSE_PROXY_HOST**: Fully Qualified name _(e.g. squashtm.example.com)_
* **REVERSE_PROXY_PORT**: Port listening at de reverse-proxy side; default=`443`
* **REVERSE_PROXY_PROTOCOL**: _http_ or _https_; default=`https` 

the following environment variables enable the support of LDAP

* **LDAP_ENABLED**: Enables LDAP Authentication; default=`false`
* **LDAP_PROVIDER**: Choose between "ldap" and "ad-ldap"; example=`not configured`
* **LDAP_URL**: URL to LDAP server including tcp port; default=`ldap://example.com:389`
* **LDAP_SECURITY_MANAGERDN**: Distinguished Name of the user that manage LDAP authentication; default=`ldapuser@example.com`
* **LDAP_SECURITY_MANAGERPASSWORD**: Password of the user that manage LDAP authentication; default=`password`
* **LDAP_FETCH_ATTRIBUTES**: default=`true`

  _Search option 1_
  * **LDAP_USER_DNPATTERNS**: example=`uid={0},ou=people`

  _Search option 2 (Recommended)_
  * **LDAP_USER_SEARCHFILTER**: Search for user objects; example=`(&(objectclass\=user)(userAccountControl\:1.2.840.113556.1.4.803\:\=512))`
  * **LDAP_USER_SEARCHBASE**: Attributes for login name (Use "sAMAccountName" instead of "uid" with Active Directory); default=`(uid={0})`

### Deployment using PostgreSQL

Database is created by the database container and automatically populated by the application container on first run.

```bash
docker run -it -d --name squash-tm-pg \
--restart=always \
-e POSTGRES_USER=squashtm \
-e POSTGRES_PASSWORD=Ch4ng3M3 \
-e POSTGRES_DB=squashtm \
-v squash-tm-db:/var/lib/postgresql \
postgres

sleep 10

docker run -it -d --name=squash-tm \
--link squash-tm-pg:postgres \
--restart=always \
-p 32760:8080 \
fjudith/squash-tm
```

Wait 2-3 minutes the time for Squash-TM to initialize. then login to http://localhost:32760/squash-tm

### Deployment using MySQL

Database is created by the database container and automatically populated by the application container on first run.

```bash
docker run -it -d --name squash-tm-md \
-e MYSQL_ROOT_PASSWORD=Ch4ng3M3 \
-e MYSQL_USER=squashtm \
-e MYSQL_PASSWORD=Ch4ng3M3 \
-e MYSQL_DATABASE=squashtm \
-v squash-tm-db:/var/lib/mysql \
mariadb --character-set-server=utf8_bin --collation-server=utf8_bin

sleep 10

docker run -it -d --name=squash-tm \
--link squash-tm-md:mysql \
-p 32760:8080 \
fjudith/squash-tm
```

Wait 2-3 minutes the time for Squash-TM to initialize. then login to http://localhost:32760/squash-tm

## Docker-Compose

The following example enables Postgres database and Reverse-Proxy support for SSL offloading.

```
squash-tm-pg:
  environment:
    POSTGRES_DB: squashtm
    POSTGRES_PASSWORD: Ch4ng3M3
    POSTGRES_USER: squashtm
  image: postgres
  volumes:
  - squash-tm-db:/var/lib/postgresql

squash-tm:
  environment:
    REVERSE_PROXY_HOST: squashtm.example.com
    REVERSE_PROXY_PORT: 443
    REVERSE_PROXY_PROTOCOL: https
  ports:
  - 32760:8080/tcp
  image: fjudith/squash-tm
  links:
  - squash-tm-pg:postgres
  volumes:
  - squash-tm-tmp:/usr/share/squash-tm/tmp
  - squash-tm-bundles:/usr/share/squash-tm/bundles
  - squash-tm-logs:/usr/share/squash-tm/logs
  - squash-tm-jettyhome:/usr/share/squash-tm/jettyhome
  - squash-tm-luceneindexes:/usr/share/squash-tm/luceneindexes
  - squash-tm-plugins:/usr/share/squash-tm/plugins
```

## Cloud Foundry manifest.yml

```
---
applications:
- name: squashtm
  docker:
    image: fjudith/squash-tm
  instances: 1
  memory: 1G
  disk_quota: 1G
  env: 
    DB_HOST: <database-service-host>
    DB_PORT: <database-service-port>
    DB_TYPE: <database-type>
    DB_NAME: <database-name>
    DB_USERNAME: <username>
    DB_PASSWORD: <password>
    REVERSE_PROXY_HOST: squashtm.your-cf.domain
    REVERSE_PROXY_PORT: 443
    REVERSE_PROXY_PROTOCOL: https
```
More info: https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html#docker 

## References

* http://www.squashtest.org
* https://github.com/Logicify/docker-squash-tm
* https://bitbucket.org/nx/squashtest-tm/wiki/WarDeploymentGuide
* https://confluence.atlassian.com/bitbucketserver/securing-bitbucket-server-behind-haproxy-using-ssl-779303273.html
