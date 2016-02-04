# Docker-Postfix-autotls

This is work in progress.  This is just a basic postfix MTA install with create CA Authority and TLS Keys and Certs on the fly.

## How to run

You need to configure a volume for the SSL certs.  /opt/ssl is used by default.
-v /opt/testdomain1.com:/opt/ssl

- --hostname 	-	This configures main.cf
- --mydest	-	Configure main.cf

###Example
>docker run -p 1025:25 --hostname smtp -it -v /opt/testdomain1.com:/opt/ssl alexdw1/postfix-autotls --hostname smtp.testdomain1.com --debug --mydest=testdomain1.com

> or you can simply run:
> run-smtp.testdomain1.com.sh or run-smtp.testdomain2.com.sh
