#!/bin/bash

#TOMCAT_VERSION="8.0.28"
#ACTIVITI_VERSION="5.19.0"
#MYSQL_CONNECTOR_JAVA_VERSION="5.1.37"
#wget -c http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O download/catalina.tar.gz
#wget -c https://github.com/Activiti/Activiti/releases/download/activiti-${ACTIVITI_VERSION}/activiti-${ACTIVITI_VERSION}.zip -O download/activiti.zip
#wget -c http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.zip -O download/mysql-connector-java.zip

mkdir -p download
mkdir -p mysql/data

docker build -t mrbot/activiti:5.19.0 .
 
