# Introduction
Squash TM is the test repository manager found in the open source Squash toolkit. It enables the management of requirements, test cases and campaigns execution in a multiproject context.

# Description
The Dockerfile builds from "openjdk:7jdk" see https://hub.docker.com/_/openjdk/

Only `startup.sh` is customized to allow seemless integration with external database as long as the link alias is `mysql` or `postgres`.

# Quick Start
Run the Squash-TM image:
```
docker run --name='squash-tm' -it -rm -p 8080:8080 fjudith/squash-tm
```

NOTE: Please allow a few minutes for the applicaton to start, especially if popylating the database for the first time. If you want to make sur that everything went fine, watch the log:

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

#### Database
Default `DB_TYPE` is H2
The following environmnet variables allows to change for MySQL or PostgreSQL.
* **DB_TYPE**: Database type, one of h2, mysql, postgresql; default=`h2`
* **DB_URL**: DataBase URL; default=`jdbc:h2:../data/squash-tm`
* **DB_USERNAME**: Database username; default=`sa`
* **DB_PASSWORD**: Database password; default=`sa`

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

Wait 2-3 minutes the time for Squash-TM to initialize. then login to http://localhost:32760/squash 

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

Wait 2-3 minutes the time for Squash-TM to initialize. then login to http://localhost:32760/squash 

### References

* http://www.squashtest.org
* https://github.com/Logicify/docker-squash-tm
