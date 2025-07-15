@ECHO off

ECHO [Stopping & Removing] Compose setup
docker compose down -v

ECHO [Stop] All containers
FOR /F "tokens=*" %%i IN ('docker ps -q') DO docker stop %%i

ECHO [Removing] All Containers
FOR /F "tokens=*" %%i IN ('docker ps -aq') DO docker rm %%i

ECHO [Removing] All images...
FOR /F "tokens=*" %%i IN ('docker images -q') DO docker rmi -f %%i

ECHO [Cleaning] Not used volumes
docker volume prune -f 

ECHO [Cleaning] Volume files
SET "path_file=%~dp0\file\"
DEL /q "%path_file%"
FOR /d %%D IN ("%path_file%\*") DO RD /S /Q "%%D"

ECHO [Cleaning] Not used networks
docker network prune -f

ECHO [Composing Up]
docker compose up

PAUSE