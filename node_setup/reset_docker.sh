#!/bin/sh

# docker stop $(docker ps -aq)
# docker rm $(docker ps -aq)
# docker rmi $(docker images -q)
# docker volume rm $(docker volume ls -q)
# docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
# docker system prune -af --volumes


systemctl stop docker
rm -rf /var/lib/docker
systemctl start docker
