#!/bin/bash

cd ~/git/Omnimed-solutions/omnimed-config-server
skaffold run

cd ~/git/Omnimed-solutions/omnimed-healthrecord/omnimed.healthrecord.deploy.app/
mvn install -P VirgoDocker -Dvirgo-docker-build.phase=install -Dmaven.test.skip=true

cd ~/git/Omnimed-solutions/omnimed-common/omnimed.common.api.app/
mvn install -P VirgoDocker -Dvirgo-docker-build.phase=install -Dmaven.test.skip=true

cd ~/git/Omnimed-solutions/
ant -buildfile ~/git/Omnimed-solutions/build-tools/workspace/processResources.xml processResources-karaf-authorization

cd ~/git/Omnimed-solutions/omnimed-activemq/
skaffold run &&

echo "PID = "$PID
wait $PID

cd ~/git/Omnimed-solutions/
skaffold run | tee ~/Documents/stacks/k8s/"$(date +"%Y-%m-%d\ %H:%M:%S")"-omnimed-solutions.log &&
echo Deployment of Omnimed-Solutions done!
