#!/bin/bash

function print_help {
cat <<EOF
     Postfix MTA-IN ONLY Startup Script
===============================================
This will spin up postfix ONLY for incoming mails.

Other functions like SpamAssassin, Mail Delivery are
in other containers.

docker run sneakyscampi/mta-in-postfix (OPTIONS)
	-h | --help		Print this help
	-m | --hostname		Postfix: myhostname 
	-e | --mydest		Postfix: mydestination domains (comma seperate)
	-c | --sslconfigpath	SSL CONFIGPATH (VOLUME) default /opt/ssl
	-d | --debug		Drop into a shell
_______________________________________________
by SneakyScampi
EOF
}

DEBUG=false
OPTS=`getopt -o hm:de:c: --long help,hostname:,debug,mydest:,configpath: -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo #OPTS
eval set -- "$OPTS"
while true; do
  case "$1" in
	-h | --help ) 		print_help; exit 0; shift ;;
	-m | --hostname )	MYHOSTNAME="$2"; shift; shift ;;
	-e | --mydest )		MYDESTINATION="$2"; shift; shift ;;
	-c | --configpath )	CONFIGPATH="$2"; shift; shift ;;
	-d | --debug ) 		echo "Debug Mode..."; DEBUG=true; shift ;;
	-- ) shift; break ;;
	* ) break ;;
  esac
done

if [ -z "$CONFIGPATH" ]; then
	CONFIGPATH=/opt/ssl
fi

#______________CONFIGURE SYSTEM________________________

###SET THE HOSTNAME
echo $MYHOSTNAME >> /etc/mailname
postconf -e myhostname=$MYHOSTNAME
postconf -e "smtpd_banner = \$myhostname ESMTP"

##CONFIGURE POSTFIX RELAY SECURITY
postconf -e "mydestination = $MYDESTINATION"
postconf -e "myorigin = $MYDESTINATION"


#_____________SET PERMISSIONS__________________________

chown postfix /var/spool/postfix/private


#_____________GENERATE SSL__________________________

if [ ! -d "$CONFIGPATH/ca" ]; then

	echo "Creating Certificate Authority (CA)"
	createCA -d $MYDESTINATION -c $CONFIGPATH
	createServerKeyAndSign -d $MYDESTINATION -c $CONFIGPATH 
fi


#______________START SERVICES__________________________


echo "Starting rsyslog"
service rsyslog start
echo "Starting postfix"
service postfix start

#DROP TO A BASH SHELL IF DEBUG ENABLED
if $DEBUG; then
	tail /var/log/mail.*
	/bin/bash
	exit 0
fi

# print logs
#echo ">> printing the logs"
#touch /var/log/mail.log /var/log/mail.err /var/log/mail.warn
#chmod a+rw /var/log/mail.*
tail -F /var/log/mail.*
