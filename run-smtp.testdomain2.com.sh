docker stop postfix-autotls
docker rm postfix-autotls
docker build -t alexdw1/postfix-autotls .
docker run -p 1026:25 --hostname smtp -it -v /opt/testdomain2.com:/opt/ssl alexdw1/postfix-autotls --hostname smtp.testdomain2.com --debug --mydest=testdomain1.com
