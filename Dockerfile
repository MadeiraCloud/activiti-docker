#
# Ubuntu 14.04 with activiti Dockerfile
#
# Pull base image.
#FROM java:openjdk-8u66-jdk
FROM java:openjdk-7u85-jdk
MAINTAINER Jimmy Xu "xjimmyshcn@gmail.com"

RUN apt-get update

EXPOSE 8080

ENV TOMCAT_VERSION 8.0.28
ENV ACTIVITI_VERSION 5.19.0
ENV MYSQL_CONNECTOR_JAVA_VERSION 5.1.37

# Download package
RUN wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.zip -O /tmp/mysql-connector-java.zip
RUN wget http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/catalina.tar.gz
RUN wget https://github.com/Activiti/Activiti/releases/download/activiti-${ACTIVITI_VERSION}/activiti-${ACTIVITI_VERSION}.zip -O /tmp/activiti.zip
#COPY download/mysql-connector-java.zip /tmp/mysql-connector-java.zip
#COPY download/catalina.tar.gz /tmp/catalina.tar.gz
#COPY download/activiti.zip /tmp/activiti.zip

# Unpack
RUN tar xzf /tmp/catalina.tar.gz -C /opt
RUN ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat
RUN rm /tmp/catalina.tar.gz

RUN unzip /tmp/activiti.zip -d /opt/activiti

# Remove unneeded apps
RUN rm -rf /opt/tomcat/webapps/examples
RUN rm -rf /opt/tomcat/webapps/docs

# To install jar files first we need to deploy war files manually
RUN unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-explorer.war -d /opt/tomcat/webapps/activiti-explorer
RUN unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-rest.war -d /opt/tomcat/webapps/activiti-rest

# Add mysql connector to application
RUN unzip /tmp/mysql-connector-java.zip -d /tmp
RUN cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-rest/WEB-INF/lib/
RUN cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-explorer/WEB-INF/lib/

# Add font
COPY assets/font/YaHei.Consolas.1.12.ttf /usr/share/fonts/truetype/YaHei/YaHei.Consolas.1.12.ttf
RUN apt-get install -y xfonts-utils
RUN mkfontscale && mkfontdir && fc-cache -fv

# Patch(support CORS, chinese fonts)
ADD assets/patch/activiti-explorer /opt/tomcat/webapps/activiti-explorer/
COPY assets/patch/activiti-rest /opt/tomcat/webapps/activiti-rest/
COPY assets/config/tomcat/ROOT /opt/tomcat/webapps/ROOT/

# Add roles
ADD assets/config /assets/config/
ADD assets/init /assets/init
RUN cp /assets/config/tomcat/tomcat-users.xml /opt/apache-tomcat-${TOMCAT_VERSION}/conf/

ENV JAVA_OPTS="-Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -server -XX:PermSize=64M -XX:MaxPermSize=256m"

CMD ["/assets/init"]
