# Supprimer l'image actuelle
# docker images | grep "omnimed-docker-postgresql-init" | awk '{print $3}' | exec docker image rm {}

# Générer l'initdb
ant -buildfile ~/git/Omnimed-solutions/build-tools/workspace/processResources.xml generateSchema

cd ~/git/Omnimed-solutions/omnimed-postgresql/
skaffold run & disown
