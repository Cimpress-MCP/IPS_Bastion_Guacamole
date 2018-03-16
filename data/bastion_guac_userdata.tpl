#!/bin/bash

# Copy the properties files created before with RDS endpoint, DB and DUO info

cd /etc/guacamole
aws s3 cp "s3://${bucket_name}/guacamole.properties" guacamole.properties

#Verify if DUO needs to be enabled (duo_enable is a boolean variable, 0=false, 1=true); if yes, copy the extension package to the right location
cd /home/ubuntu/
if [ ${duo_enabled} -eq 1 ]; then cp guacamole-auth-duo-0.9.14/guacamole-auth-duo-0.9.14.jar /etc/guacamole/extensions/;
fi


# Check if guacamole db is already configured with the right schema; if not, configure it

if [ "`mysql -u ${db_user} -p${db_pwd} -h ${mysql_hostname} ${db_name} -sse "show tables;"`" != "" ]
	then 
		echo "DB Schema already configured, exiting..."
	else 
		echo "Creating Guacamole DB Schema..." && cat guacamole-auth-jdbc-0.9.14/mysql/schema/001-create-schema.sql | mysql -u ${db_user} -p${db_pwd} -h ${mysql_hostname} ${db_name}
fi

# Create admin_username in MySQL
mysql -u ${db_user} -p${db_pwd} -h ${mysql_hostname} ${db_name} -e "

-- Generate salt
SET @salt = UNHEX(SHA2(UUID(), 256));
-- Create user and hash password with salt

INSERT INTO guacamole_user (username, password_salt, password_hash, password_date)
VALUES ('${admin_username}', @salt,UNHEX(SHA2(CONCAT('${admin_password}', HEX(@salt)), 256)),NOW());

-- Grant this user all system permissions
INSERT INTO guacamole_system_permission
SELECT user_id, permission
FROM (
          SELECT '${admin_username}'  AS username, 'CREATE_CONNECTION'       AS permission
    UNION SELECT '${admin_username}'  AS username, 'CREATE_CONNECTION_GROUP' AS permission
    UNION SELECT '${admin_username}'  AS username, 'CREATE_SHARING_PROFILE'  AS permission
    UNION SELECT '${admin_username}'  AS username, 'CREATE_USER'             AS permission
    UNION SELECT '${admin_username}'  AS username, 'ADMINISTER'              AS permission
) permissions
JOIN guacamole_user ON permissions.username = guacamole_user.username;

-- Grant admin permission to read/update/administer self
INSERT INTO guacamole_user_permission
SELECT guacamole_user.user_id, affected.user_id, permission
FROM (
          SELECT '${admin_username}' AS username, '${admin_username}' AS affected_username, 'READ'       AS permission
    UNION SELECT '${admin_username}' AS username, '${admin_username}' AS affected_username, 'UPDATE'     AS permission
    UNION SELECT '${admin_username}' AS username, '${admin_username}' AS affected_username, 'ADMINISTER' AS permission
) permissions
JOIN guacamole_user          ON permissions.username = guacamole_user.username
JOIN guacamole_user affected ON permissions.affected_username = affected.username;"


# Restarting tomcat due to changes to the guacamole.properties.

/etc/init.d/guacd restart

tomcat_ver=`ls /etc/init.d/ | grep -o -P 'tomcat.{0,2}'`
/etc/init.d/$tomcat_ver restart