#!/bin/bash
# WORKING ON UBUNTU 16.04 WITH GUAC 0.9.14 AND TOMCAT7
# Note from Cimpress IPS: Here is missing all the configuration related to MySQL and guacamole.properties file, because there are handled by the terraform module (RDS+user_data)

# Version numbers of Guacamole and MySQL Connector/J to download
GUACVERSION="0.9.14"
MCJVERSION="5.1.45"

# Tomcat Version
TOMCAT="tomcat7"

#Install Packages/Dependencies for Guacamole
apt-get -y install awscli build-essential libcairo2-dev libjpeg-turbo8-dev libpng12-dev libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev mysql-client mysql-common mysql-utilities ${TOMCAT} freerdp-x11 ghostscript wget dpkg-dev

#Install inspector and chrony (for NTP)
wget https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install
bash install
apt-get -y install chrony && service chrony start


# Set SERVER to be the preferred download server from the Apache CDN
SERVER="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUACVERSION}"

# Download Guacamole Server
wget -O guacamole-server-${GUACVERSION}.tar.gz ${SERVER}/source/guacamole-server-${GUACVERSION}.tar.gz

# Download Guacamole Client
wget -O guacamole-${GUACVERSION}.war ${SERVER}/binary/guacamole-${GUACVERSION}.war

# Download Guacamole authentication extensions
wget -O guacamole-auth-jdbc-${GUACVERSION}.tar.gz ${SERVER}/binary/guacamole-auth-jdbc-${GUACVERSION}.tar.gz

# Download Guacamole DUO extension
wget -O guacamole-auth-duo-${GUACVERSION}.tar.gz ${SERVER}/binary/guacamole-auth-duo-${GUACVERSION}.tar.gz

# Download Guacamole OpenID extension
wget -O guacamole-auth-openid-${GUACVERSION}.tar.gz ${SERVER}/binary/guacamole-auth-openid-${GUACVERSION}.tar.gz

# Download MySQL Connector-J
wget -O mysql-connector-java-${MCJVERSION}.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MCJVERSION}.tar.gz

# Extract Guacamole files
tar -xzf guacamole-server-${GUACVERSION}.tar.gz
tar -xzf guacamole-auth-jdbc-${GUACVERSION}.tar.gz
tar -xzf guacamole-auth-duo-${GUACVERSION}.tar.gz
tar -xzf guacamole-auth-openid-${GUACVERSION}.tar.gz
tar -xzf mysql-connector-java-${MCJVERSION}.tar.gz

# MAKE DIRECTORIES
mkdir -p /etc/guacamole/lib
mkdir /etc/guacamole/extensions

# Install GUACD
cd guacamole-server-${GUACVERSION}
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl enable guacd
cd ..

# Get build-folder
BUILD_FOLDER=$(dpkg-architecture -qDEB_BUILD_GNU_TYPE)

# Move files to correct locations
mv guacamole-${GUACVERSION}.war /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/${TOMCAT}/webapps/
ln -s /usr/local/lib/freerdp/guac*.so /usr/lib/${BUILD_FOLDER}/freerdp/
cp mysql-connector-java-${MCJVERSION}/mysql-connector-java-${MCJVERSION}-bin.jar /etc/guacamole/lib/
cp guacamole-auth-jdbc-${GUACVERSION}/mysql/guacamole-auth-jdbc-mysql-${GUACVERSION}.jar /etc/guacamole/extensions/

# Create empty guacamole.properties, it will be configured by the terraform module
touch /etc/guacamole/guacamole.properties

# Restart Tomcat Service
service ${TOMCAT} restart

# Ensure guacd is started
service guacd start