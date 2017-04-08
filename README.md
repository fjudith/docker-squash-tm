# Introduction
Squash TM is the test repository manager found in the open source Squash toolkit. It enables the management of requirements, test cases and campaigns execution in a multiproject context.

# Description
The Dockerfile builds from "Tomcat:8-jre7" see https://hub.docker.com/_/tomcat/

Only `startup.sh` is customized to allow seemless integration with external database as long as the link alias is `mysql` or `postgres`.

# Roadmap
* [x] Apache Tomcat support
* [x] LDAP authentication
* [x] Reverse proxy support

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

### Configuration

#### Persistent Volumes

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

#### Environment variables
Default `DB_TYPE` is H2
The following environment variables allows to change for MySQL or PostgreSQL.
* **DB_TYPE**: Database type, one of h2, mysql, postgresql; default=`h2`
* **DB_URL**: DataBase URL; default=`jdbc:h2:../data/squash-tm`
* **DB_USERNAME**: Database username; default=`sa`
* **DB_PASSWORD**: Database password; default=`sa`

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

#### Docker-Compose (english language)
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
  ports:
  - 32760:8080/tcp
  image: fjudith/squash-tm
  links:
  - squash-tm-pg:postgres
  volumes:
  - squash-tm-tmp:/usr/share/squash-tm/tmp
  - squash-tm-bundles:/usr/share/squash-tm/bundles
  - squash-tm-conf:/usr/share/squash-tm/conf
  - squash-tm-logs:/usr/share/squash-tm/logs
  - squash-tm-jettyhome:/usr/share/squash-tm/jettyhome
  - squash-tm-luceneindexes:/usr/share/squash-tm/luceneindexes
  - squash-tm-plugins:/usr/share/squash-tm/plugins
```

#### Docker-Compose (french language)
```
squash-tm-pg:
  environment:
    POSTGRES_DB: squashtm
    POSTGRES_PASSWORD: Ch4ng3M3
    POSTGRES_USER: squashtm
  image: fjudith/postgres-fr
  volumes:
  - squash-tm-db:/var/lib/postgresql

squash-tm:
  ports:
  - 32760:8080/tcp
  image: fjudith/squash-tm:fr
  links:
  - squash-tm-pg:postgres
  volumes:
  - squash-tm-tmp:/usr/share/squash-tm/tmp
  - squash-tm-bundles:/usr/share/squash-tm/bundles
  - squash-tm-conf:/usr/share/squash-tm/conf
  - squash-tm-logs:/usr/share/squash-tm/logs
  - squash-tm-jettyhome:/usr/share/squash-tm/jettyhome
  - squash-tm-luceneindexes:/usr/share/squash-tm/luceneindexes
  - squash-tm-plugins:/usr/share/squash-tm/plugins
```

### Deployment using MySQL (Unstable)
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

### References

* http://www.squashtest.org
* https://github.com/Logicify/docker-squash-tm
* https://bitbucket.org/nx/squashtest-tm/wiki/WarDeploymentGuide
* https://confluence.atlassian.com/bitbucketserver/securing-bitbucket-server-behind-haproxy-using-ssl-779303273.html