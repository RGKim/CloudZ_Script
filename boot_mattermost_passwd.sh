sed -i "s/'\$OLD_PASSWORD'/'\$NEW_PASSWORD'/g" /opt/mattermost/config/config.json
	

cd /opt/mattermost/bin

./platform user password admin@cloudz.co.kr \$NEW_PASSWORD
