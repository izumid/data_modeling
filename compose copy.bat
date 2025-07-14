@ECHO off
ECHO [Stop] All containers
FOR /F "tokens=*" %%i IN ('docker ps -q') DO docker stop %%i

ECHO [Removing] All Containers
FOR /F "tokens=*" %%i IN ('docker ps -aq') DO docker rm %%i

ECHO [Removing] All images...
FOR /F "tokens=*" %%i IN ('docker images -q') DO docker rmi -f %%i

ECHO [Cleaning] Not used volumes
docker volume prune -f 

ECHO [Cleaning] Volume files
RD /S /Q "C:\Users\Serv\Desktop\data_modeling\file"

ECHO [Cleaning] Not used networks
docker network prune -f

ECHO [Composing Up]

docker compose up

PAUSE