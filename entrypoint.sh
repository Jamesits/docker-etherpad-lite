#!/bin/bash
set -e

: ${MYSQL_PORT_3306_TCP_ADDR:=mysql}

if [ -z "$MYSQL_PORT_3306_TCP_ADDR" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

# if we're linked to MySQL, and we're using the root user, and our linked
# container has a default "root" password set up and passed through... :)
: ${ETHERPAD_DB_USER:=root}
if [ "$ETHERPAD_DB_USER" = 'root' ]; then
	: ${ETHERPAD_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${ETHERPAD_DB_NAME:=etherpad}

ETHERPAD_DB_NAME=$( echo $ETHERPAD_DB_NAME | sed 's/\./_/g' )

if [ -z "$ETHERPAD_DB_PASSWORD" ]; then
	echo >&2 'error: missing required ETHERPAD_DB_PASSWORD environment variable'
	echo >&2 '  Did you forget to -e ETHERPAD_DB_PASSWORD=... ?'
	echo >&2
	echo >&2 '  (Also of interest might be ETHERPAD_DB_USER and ETHERPAD_DB_NAME.)'
	exit 1
fi

: ${ETHERPAD_TITLE:=Etherpad}
: ${ETHERPAD_PORT:=9001}

# Check if database already exists
RESULT=`mysql -u${ETHERPAD_DB_USER} -p${ETHERPAD_DB_PASSWORD} \
	-h${MYSQL_PORT_3306_TCP_ADDR} --skip-column-names \
	-e "SHOW DATABASES LIKE '${ETHERPAD_DB_NAME}'"`

if [ "$RESULT" != $ETHERPAD_DB_NAME ]; then
	# mysql database does not exist, create it
	echo "Creating database ${ETHERPAD_DB_NAME}"

	mysql -u${ETHERPAD_DB_USER} -p${ETHERPAD_DB_PASSWORD} -h${MYSQL_PORT_3306_TCP_ADDR} \
	      -e "create database ${ETHERPAD_DB_NAME}"
fi

if [ ! -f settings.json ]; then

	cat <<- EOF > settings.json
	{
	  "title": "${ETHERPAD_TITLE}",
	  "ip": "0.0.0.0",
	  "port": ${ETHERPAD_PORT},
	  "maxAge": "${ETHERPAD_MAXAGE:-3600}",
	  "minify": true,
	  "dbType" : "mysql",
	  "dbSettings" : {
			    "user"    : "${ETHERPAD_DB_USER}",
			    "host"    : "${MYSQL_PORT_3306_TCP_ADDR}",
			    "password": "${ETHERPAD_DB_PASSWORD}",
			    "database": "${ETHERPAD_DB_NAME}"
			  },
	EOF

	if [ $ETHERPAD_ADMIN_PASSWORD ]; then

		: ${ETHERPAD_ADMIN_USER:=admin}

		cat <<- EOF >> settings.json
		  "users": {
		    "${ETHERPAD_ADMIN_USER}": {
		      "password": "${ETHERPAD_ADMIN_PASSWORD}",
		      "is_admin": true
		    }
		  },
		EOF
	fi

	cat <<- EOF >> settings.json
	}
	EOF
fi

if [ $ETHERPAD_PLUGINS ]; then
	IFS=',' read -r -a PLUGIN_LIST <<< "$ETHERPAD_PLUGINS"
	for PLUGIN in "${PLUGIN_LIST[@]}"
	do
	    npm install ${PLUGIN}
	done
fi
exec "$@"
