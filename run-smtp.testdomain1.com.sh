docker stop postfix-autotls
docker rm postfix-autotls
docker build -t alexdw1/postfix-autotls .
docker run -p 1025:25 --hostname smtp -it -v /opt/testdomain1.com:/opt/ssl alexdw1/postfix-autotls --hostname smtp.testdomain1.com --debug --mydest=testdomain1.com
