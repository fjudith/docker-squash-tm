#! /bin/bash
#
#     This file is part of the Squashtest platform.
#     Copyright (C) 2010 - 2012 Henix, henix.fr
#
#     See the NOTICE file distributed with this work for additional
#     information regarding copyright ownership.
#
#     This is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     this software is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with this software.  If not, see <http://www.gnu.org/licenses/>.
#

# if we're linked to MySQL and thus have credentials already, let's use them
#set -e

function cfg_replace_option {
  grep "$1" "$3" > /dev/null
  if [ $? -eq 0 ]; then
    # replace option
    echo "replacing option  $1=$2  in  $3"
    sed -i "s#^\($1\s*=\s*\).*\$#\1$2#" $3
    if (( $? )); then
      echo "cfg_replace_option failed"
      exit 1
    fi
  else
    # add option if it does not exist
    echo "adding option  $1=$2  in  $3"
    echo "$1=$2" >> $3
  fi
}

SQUASH_TM_CFG_PROPERTIES=/usr/share/squash-tm/conf/squash.tm.cfg.properties

cd /usr/share/squash-tm/bin

# if we're linked to MySQL and thus have credentials already, let's use them
if [[ -v MYSQL_ENV_GOSU_VERSION ]]; then
    DB_TYPE='mysql'
    DB_HOST='mysql'
    DB_PORT='3306'
    DB_DRIVER='org.gjt.mm.mysql.Driver'
    DB_USERNAME=${MYSQL_ENV_MYSQL_USER:-'root'}
    
    if [ "${DB_USERNAME}" = 'root' ]; then
        DB_PASSWORD=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}
    fi
    
    DB_PASSWORD=${MYSQL_ENV_MYSQL_PASSWORD}
    DB_NAME=${MYSQL_ENV_MYSQL_DATABASE:-'squashtm'}

    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing required DB_PASSWORD environment variable'
        echo >&2 '  Did you forget to -e DB_PASSWORD=... ?'
        echo >&2
        echo >&2 '  (Also of interest might be DB_USERNAME and DB_NAME.)'
        exit 1
    fi
elif [[ -v POSTGRES_ENV_GOSU_VERSION ]]; then
    DB_TYPE='postgresql'
    DB_HOST='postgres'
    DB_PORT='5432'
    DB_DRIVER='org.postgresql.Driver'
    DB_USERNAME=${POSTGRES_ENV_POSTGRES_USER:-'root'}

    if [ "${DB_USERNAME}" = 'postgres' ]; then
        DB_PASSWORD=${DB_PASSWORD:-'postgres' }
    fi

    DB_PASSWORD=${POSTGRES_ENV_POSTGRES_PASSWORD}
    DB_NAME=${POSTGRES_ENV_POSTGRES_DB:-'squashtm'}

    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing required DB_PASSWORD environment variable'
        echo >&2 '  Did you forget to -e DB_PASSWORD=... ?'
        echo >&2
        echo >&2 '  (Also of interest might be DB_USERNAME and DB_NAME.)'
        exit 1
    fi
fi

DB_TYPE=${DB_TYPE:-'mysql'}
DB_HOST=${DB_HOST:-'mysql'}
DB_USERNAME=${DB_USERNAME:-'root'}
DB_PASSWORD=${DB_PASSWORD:-'root'}
DB_NAME=${DB_NAME:-'squashtm'}
# DB_PORT=${DB_PORT:-'3306'}
# DB_URL="jdbc:${DB_TYPE}://${DB_HOST}:${DB_PORT}/$DB_NAME"

if [[ "${DB_TYPE}" = "mysql" ]]; then
    echo 'Using MysQL'
    DB_PORT=${DB_PORT:-'3306'}
    DB_URL="jdbc:${DB_TYPE}://${DB_HOST}:${DB_PORT}/$DB_NAME"

    until nc -zv -w 5 ${DB_HOST} ${DB_PORT}; do echo waiting for mysql; sleep 2; done;

    if ! mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME -e "SELECT 1 FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name = 'ISSUE';" | grep 1 ; then
        echo 'Initializing MySQL database'
        mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME < ../database-scripts/mysql-full-install-version-$SQUASH_TM_VERSION.RELEASE.sql
    else
        echo 'Database already initialized'
    fi

    echo 'Updrading MysQL'
    if [[ -f "../database-scripts/mysql-upgrade-to-$SQUASH_TM_VERSION.sql" ]]; then
        mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME < ../database-scripts/mysql-upgrade-to-$SQUASH_TM_VERSION.sql
    fi
elif [[ "${DB_TYPE}" = "postgresql" ]]; then
    echo 'Using PostgreSQL'
    DB_PORT=${DB_PORT:-'5432'}
    DB_URL="jdbc:${DB_TYPE}://${DB_HOST}:${DB_PORT}/$DB_NAME"

    until nc -zv -w 5 ${DB_HOST} ${DB_PORT}; do echo waiting for postgresql; sleep 2; done;

    if ! psql postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME -c "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'issue';" | grep 1 ; then
        echo 'Initializing PostgreSQL database'
        psql postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:${DB_PORT}/$DB_NAME -f ../database-scripts/postgresql-full-install-version-$SQUASH_TM_VERSION.RELEASE.sql
    else
        echo 'Database already initialized'
    fi

    echo 'Updrading PostgreSQL'
    if [[ -f "../database-scripts/postgresql-upgrade-to-$SQUASH_TM_VERSION.sql" ]]; then
        psql postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:${DB_PORT}/$DB_NAME -f ../database-scripts/postgresql-upgrade-to-$SQUASH_TM_VERSION.sql
    fi
fi

# Implement database configuration in /usr/share/squash-tm/conf/squash.tm.cfg.properties
# https://bitbucket.org/nx/squashtest-tm/wiki/WarDeploymentGuide
cfg_replace_option spring.datasource.url $DB_URL $SQUASH_TM_CFG_PROPERTIES
cfg_replace_option spring.datasource.username $DB_USERNAME $SQUASH_TM_CFG_PROPERTIES
cfg_replace_option spring.datasource.password $DB_PASSWORD $SQUASH_TM_CFG_PROPERTIES
cfg_replace_option squash.path.root /usr/share/squash-tm $SQUASH_TM_CFG_PROPERTIES
cfg_replace_option spring.profiles.active $DB_TYPE $SQUASH_TM_CFG_PROPERTIES
cfg_replace_option squash.path.plugins-path $PLUGINS_DIR $SQUASH_TM_CFG_PROPERTIES

# Deploy webapp's context
# https://bitbucket.org/nx/squashtest-tm/wiki/WarDeploymentGuide
sed -i "s#@@DB_TYPE@@#$DB_TYPE#g" /usr/local/tomcat/conf/Catalina/localhost/squash-tm.xml
sed -i "s#@@DB_URL@@#$DB_URL#g" /usr/local/tomcat/conf/Catalina/localhost/squash-tm.xml

# Redirect from ROOT page to /squash-tm/
echo '<!DOCTYPE HTML><html><head><meta http-equiv="refresh" content="0; url=/squash-tm/"></head></html>' > /usr/local/tomcat/webapps/ROOT/index.html


# if we're enabling LDAP or Active Directory, Let's update Squash-TM properties file
if [[ "$LDAP_ENABLED" = "true" ]]; then
	if [[ "$LDAP_PROVIDER" = "ldap" ]]; then
		# Default
    	LDAP_PROVIDER=${LDAP_PROVIDER:-'ldap'}
    	LDAP_URL=${LDAP_URL:-'ldap://example.com:389'}
    	LDAP_SECURITY_MANAGERDN=${LDAP_SECURITY_MANAGERDN:-'ldapuser@example.com'}
    	LDAP_SECURITY_MANAGERPASSWORD=${LDAP_SECURITY_MANAGERPASSWORD:-'password'}
    	#LDAP_USER_DNPATTERNS=${LDAP_USER_DNPATTERNS:-uid={0},ou=people}
    	#LDAP_USER_SEARCHFILTER=${LDAP_USER_SEARCHFILTER:-'(&(objectclass\=user)(userAccountControl\:1.2.840.113556.1.4.803\:\=512))'}
    	#LDAP_USER_SEARCHBASE=${LDAP_USER_SEARCHBASE:-(uid={0})}
    	LDAP_FETCH_ATTRIBUTES=${LDAP_FETCH_ATTRIBUTES:-true}

    	cfg_replace_option authentication.provider "$LDAP_PROVIDER" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ldap.server.url "$LDAP_URL" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ldap.server.managerDn "$LDAP_SECURITY_MANAGERDN" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ldap.server.managerPassword "$LDAP_SECURITY_MANAGERPASSWORD" $SQUASH_TM_CFG_PROPERTIES
    
    	if [ -v LDAP_USER_DNPATTERNS ]; then
    		cfg_replace_option authentication.ldap.user.dnPatterns "$LDAP_USER_DNPATTERNS" $SQUASH_TM_CFG_PROPERTIES
    	fi
    
    	if [ -v LDAP_USER_SEARCHBASE ]; then
    		cfg_replace_option authentication.ldap.user.searchBase "$LDAP_USER_SEARCHBASE" $SQUASH_TM_CFG_PROPERTIES
    		cfg_replace_option authentication.ldap.user.searchFilter "$LDAP_USER_SEARCHFILTER" $SQUASH_TM_CFG_PROPERTIES
    	fi

    	cfg_replace_option authentication.ldap.user.fetchAttributes "$LDAP_FETCH_ATTRIBUTES" $SQUASH_TM_CFG_PROPERTIES
    fi

    if [[ "$LDAP_PROVIDER" = "ad.ldap" ]]; then
    	# Default
    	LDAP_PROVIDER=${LDAP_PROVIDER:-'ad.ldap'}
    	LDAP_URL=${LDAP_URL:-'ldap://example.com:389'}
    	AD_DOMAIN=${AD_DOMAIN:-'example.com'}
    	# LDAP_USER_SEARCHFILTER=${LDAP_USER_SEARCHFILTER:-(&(objectClass=user)(userPrincipalName={0})}
    	# LDAP_USER_SEARCHBASE=${LDAP_USER_SEARCHBASE:-(uid={0})}

    	cfg_replace_option authentication.provider "$LDAP_PROVIDER" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ad.server.url "$LDAP_URL" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ad.server.domain "$AD_DOMAIN" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ad.user.searchBase "$LDAP_USER_SEARCHBASE" $SQUASH_TM_CFG_PROPERTIES
    	cfg_replace_option authentication.ad.user.searchFilter "$LDAP_USER_SEARCHFILTER" $SQUASH_TM_CFG_PROPERTIES
    fi
fi

#That script will :
#- check that the java environnement exists,
#- the version is adequate,
#- will run the application

# Default variables
JAR_NAME="squash-tm.war"  # Java main library
HTTP_PORT=${HTTP_PORT:-8080}               # Port for HTTP connector (default 8080; disable with -1)
# Directory variables
TMP_DIR=../tmp                             # Tmp and work directory
BUNDLES_DIR=../bundles                     # Bundles directory
CONF_DIR=../conf                           # Configurations directory
LOG_DIR=../logs                            # Log directory
TOMCAT_HOME=../tomcat-home                 # Tomcat home directory
LUCENE_DIR=../luceneindexes                # Lucene indexes directory
PLUGINS_DIR=../plugins                     # Plugins directory
# DataBase parameters
DB_TYPE=${DB_TYPE:-"h2"}                       # Database type, one of h2, mysql, postgresql
DB_URL=${DB_URL:-"jdbc:h2:../data/squash-tm"}  # DataBase URL
DB_USERNAME=${DB_USERNAME:-"sa"}               # DataBase username
DB_PASSWORD=${DB_PASSWORD:-"sa"}               # DataBase password
## Do not configure a third digit here
REQUIRED_VERSION=1.7
# Extra Java args
JAVA_ARGS=${JAVA_ARGS:-"-Xms128m -Xmx512m -server"}

# Tests if java exists
echo -n "$0 : checking java environment... ";

java_exists=`java -version 2>&1`;

if [ $? -eq 127 ]
then
    echo;
    echo "$0 : Error : java not found. Please ensure that \$JAVA_HOME points to the correct directory.";
    echo "If \$JAVA_HOME is correctly set, try exporting that variable and run that script again. Eg : ";
    echo "\$ export \$JAVA_HOME";
    echo "\$ ./$0";
    exit -1;
fi

echo "done";

# Create logs , tmp and plugins directories if necessary
if [ ! -e "$LOG_DIR" ]; then
    mkdir $LOG_DIR
fi

if [ ! -e "$TMP_DIR" ]; then
    mkdir $TMP_DIR
fi

# Tests if the version is high enough
echo -n "checking version... ";

NUMERIC_REQUIRED_VERSION=`echo $REQUIRED_VERSION |sed 's/\./0/g'`;
java_version=`echo $java_exists | grep version |cut -d " " -f 3  |sed 's/\"//g' | cut -d "." -f 1,2 | sed 's/\./0/g'`;

if [ $java_version -lt $NUMERIC_REQUIRED_VERSION ]
then
    echo;
    echo "$0 : Error : your JRE does not meet the requirements. Please install a new JRE, required version ${REQUIRED_VERSION}.";
    exit -2;
fi

echo  "done";

# Let's go !
#echo "$0 : starting Squash TM... ";

#export _JAVA_OPTIONS="-Dspring.datasource.url=${DB_URL} -Dspring.datasource.username=${DB_USERNAME} -Dspring.datasource.password=${DB_PASSWORD} -Duser.language=${SQUASH_TM_LANGUAGE}"
#DAEMON_ARGS="${JAVA_ARGS} -Djava.io.tmpdir=${TMP_DIR} -Dlogging.dir=${LOG_DIR} -jar ${BUNDLES_DIR}/${JAR_NAME} --spring.profiles.active=${DB_TYPE} --spring.config.location=${CONF_DIR}/squash.tm.cfg.properties --logging.config=${CONF_DIR}/log4j.properties --squash.path.bundles-path=${BUNDLES_DIR} --squash.path.plugins-path=${PLUGINS_DIR} --hibernate.search.default.indexBase=${LUCENE_DIR} --server.port=${HTTP_PORT} --server.tomcat.basedir=${TOMCAT_HOME} "

# exec java ${DAEMON_ARGS}

cd $CATALINA_HOME

export CATALINA_OPTS="-Djava.io.tmpdir=${TMP_DIR} -Dlogging.dir=${LOG_DIR} "

if [[ -v REVERSE_PROXY_HOST ]]; then

    REVERSE_PROXY_PROTOCOL=${REVERSE_PROXY_PROTOCOL:-https}
    REVERSE_PROXY_PORT=${REVERSE_PROXY_PORT:-443}

    if grep -q $REVERSE_PROXY_HOST $CATALINA_HOME/conf/server.xml ; then
        echo "Updating reverse proxy for URL:\"$REVERSE_PROXY_PROTOCOL://$REVERSE_PROXY_HOST:$REVERSE_PROXY_PORT\""

        xmlstarlet ed \
        -P -S -L \
        -u '/Server/Service/Connector[@port="8080"]/@useBodyEncodingForURI' -v 'true' \
        -u '/Server/Service/Connector[@port="8080"]/@compression' -v 'on' \
        -u '/Server/Service/Connector[@port="8080"]/@compressableMimeType' -v 'text/html,text/xml,text/plain,text/css,application/json,application/javascript,application/x-javascript' \
        -u '/Server/Service/Connector[@port="8080"]/@secure' -v 'true' \
        -u '/Server/Service/Connector[@port="8080"]/@scheme' -v "$REVERSE_PROXY_PROTOCOL" \
        -u '/Server/Service/Connector[@port="8080"]/@proxyName' -v "$REVERSE_PROXY_HOST" \
        -u '/Server/Service/Connector[@port="8080"]/@proxyPort' -v "$REVERSE_PROXY_PORT" \
        $CATALINA_HOME/conf/server.xml
    else
        echo "Setting reverse proxy for URL:\"$REVERSE_PROXY_PROTOCOL://$REVERSE_PROXY_HOST:$REVERSE_PROXY_PORT\""

        xmlstarlet ed \
        -P -S -L \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n useBodyEncodingForURI -v 'true' \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n compression -v 'on' \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n compressableMimeType -v 'text/html,text/xml,text/plain,text/css,application/json,application/javascript,application/x-javascript' \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n secure -v 'true' \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n scheme -v "$REVERSE_PROXY_PROTOCOL" \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n proxyName -v "$REVERSE_PROXY_HOST" \
        -i '/Server/Service/Connector[@port="8080"]' -t attr -n proxyPort -v "$REVERSE_PROXY_PORT" \
        $CATALINA_HOME/conf/server.xml
    fi
fi

echo
echo 'Squash TM init process complete; ready for start up.'
echo

exec "$@"
