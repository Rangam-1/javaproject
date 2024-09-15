# Use a specific Ubuntu version
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    openjdk-11-jdk \
    && apt-get clean

# Download and install Tomcat
RUN wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz && \
    tar -zxvf apache-tomcat-9.0.93.tar.gz && \
    mv apache-tomcat-9.0.93 /opt/tomcat && \
    rm apache-tomcat-9.0.93.tar.gz

# Copy WAR file into the container (adjust the path as needed)
COPY target/your-app.war /opt/tomcat/webapps/

# Configure Tomcat user roles
RUN sed -i '$d' /opt/tomcat/conf/tomcat-users.xml && \
    echo '<role rolename="manager-gui"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '<role rolename="manager-script"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '<role rolename="manager-jmx"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '<role rolename="manager-status"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '<role rolename="admin-gui"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '<role rolename="admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '<user username="venky" password="venky" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml && \
    echo '</tomcat-users>' >> /opt/tomcat/conf/tomcat-users.xml

# Configure Tomcat Manager context
RUN mkdir -p /opt/tomcat/webapps/manager/META-INF && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' > /opt/tomcat/webapps/manager/META-INF/context.xml && \
    echo '<Context antiResourceLocking="false" privileged="true" >' >> /opt/tomcat/webapps/manager/META-INF/context.xml && \
    echo '<CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor" sameSiteCookies="strict" />' >> /opt/tomcat/webapps/manager/META-INF/context.xml && \
    echo '<Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>' >> /opt/tomcat/webapps/manager/META-INF/context.xml && \
    echo '</Context>' >> /opt/tomcat/webapps/manager/META-INF/context.xml

# Expose Tomcat port
EXPOSE 8080

# Set the entrypoint to run Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
