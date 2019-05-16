#!/bin/bash

. xdocker/utils.sh

cat <<EOF
${green}${bold}
      ____             _
__  _|  _ \  ___   ___| | _____ _ __
\ \/ / | | |/ _ \ / __| |/ / _ \ '__|
 >  <| |_| | (_) | (__|   <  __/ |
/_/\_\____/ \___/ \___|_|\_\___|_|
${normal}
EOF

if ! (( $(program_is_installed gem) )); then
    echo "${red}Please before install ${fawn}\"gem\"${normal}"

    exit 0
fi

if ! (( $(program_is_installed docker-sync) )); then
    echo "${red}Please before run command: ${fawn}\"sudo gem install docker-sync\"${normal}"

    exit 0
fi

function update_database_parameters {
    DATABASE_URL="mysql:\/\/$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT\/$DATABASE_NAME"

    sed -i.bak 's/^DATABASE_HOST.*/DATABASE_HOST='${DATABASE_HOST}'/g' .env
    sed -i.bak 's/^DATABASE_NAME.*/DATABASE_NAME='${DATABASE_NAME}'/g' .env
    sed -i.bak 's/^DATABASE_USER.*/DATABASE_USER='${DATABASE_USER}'/g' .env
    sed -i.bak 's/^DATABASE_PASSWORD.*/DATABASE_PASSWORD='${DATABASE_PASSWORD}'/g' .env
    sed -i.bak 's/^DATABASE_PORT.*/DATABASE_PORT='${DATABASE_PORT}'/g' .env
    sed -i bak 's/^DATABASE_URL.*/DATABASE_URL="'${DATABASE_URL}'"/g' .env
    rm -f .*bak
}

function update_env_file {
    if [ ! -f ".env" ]; then
        cat ./.env.dist >> ./.env
    fi

    if cat .env | grep -iq "^NAME"; then
        sed -i.bak 's/^NAME.*/NAME='${NAME}'/g' .env
    else
        echo -e "\n###< xDocker ###\nNAME=$NAME" >> .env
    fi

    if cat .env | grep -iq "^HOST"; then
        sed -i.bak 's/^HOST.*/HOST='${HOST}'/g' .env
    else
        echo "HOST=$HOST" >> .env
    fi

    if cat .env | grep -iq "^DEFAULT_DOCKER_PORT"; then
        sed -i.bak 's/^DEFAULT_DOCKER_PORT.*/DEFAULT_DOCKER_PORT='${DEFAULT_PORT}':80/g' .env
    else
        echo -e "DEFAULT_DOCKER_PORT=$DEFAULT_PORT:80\n###< xDocker ###" >> .env
    fi

    $(update_database_parameters)
}

NAME=$(basename "$PWD")
DEFAULT_PORT=$(getport 9090)
HOST="$NAME.local"
DATABASE_HOST="mysql"
DATABASE_NAME="$NAME"
DATABASE_USER="$NAME"
DATABASE_PASSWORD="$NAME"
DATABASE_PORT="3306"

$(update_env_file)

if [ "$1" = "--dpu" ]; then
    echo "Default database host: ${cyan}${DATABASE_HOST}${fawn}"
    read USER_DATABASE_HOST
    if [[ ${USER_DATABASE_HOST} ]]; then
        DATABASE_HOST=${USER_DATABASE_HOST}
    else
        echo "${DATABASE_HOST}"
    fi

    echo "${normal}Default database name: ${cyan}${DATABASE_NAME}${fawn}"
    read USER_DATABASE_NAME
    if [[ ${USER_DATABASE_NAME} ]]; then
        DATABASE_NAME=${USER_DATABASE_NAME}
    else
        echo "${DATABASE_NAME}"
    fi

    echo "${normal}Default database user: ${cyan}${DATABASE_USER}${fawn}"
    read USER_DATABASE_USER
    if [[ ${USER_DATABASE_USER} ]]; then
        DATABASE_USER=${USER_DATABASE_USER}
    else
        echo "${DATABASE_USER}"
    fi

    echo "${normal}Default database password: ${cyan}${DATABASE_PASSWORD}${fawn}"
    read USER_DATABASE_PASSWORD
    if [[ ${USER_DATABASE_PASSWORD} ]]; then
        DATABASE_PASSWORD=${USER_DATABASE_PASSWORD}
    else
        echo "${DATABASE_PASSWORD}"
    fi

    echo "${normal}"

    $(update_database_parameters)
fi

echo "NGINX Proxy starting."
docker-compose -f docker-compose-proxy.yml -p proxy up -d
echo "NGINX Proxy started."

printf "\n"

echo "Preparing app..."
docker_sync_volume_create
docker-compose up -d
docker-sync start
echo "Project ready..."

printf "\n"

HAS_VENDOR=0

[[ -d "./vendor" ]] && HAS_VENDOR=1

MESSAGE="After composer installation is finished, you can run the project from ${bold}$HOST${normal}"

if [[ $HAS_VENDOR -eq 1 ]]; then
    MESSAGE="You can run the project from ${bold}$HOST${normal}"
fi

cat <<EOF
${green}============   Project Ready     ===========

--- ENV Variables ---
NAME=${NAME}
HOST=${HOST}
DEFAULT_DOCKER_PORT=${DEFAULT_PORT}
DATABASE_HOST=${DATABASE_HOST}
DATABASE_NAME=${DATABASE_NAME}
DATABASE_USER=${DATABASE_USER}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
DATABASE_PORT=${DATABASE_PORT}
DATABASE_URL="mysql://$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME"
--- ENV Variables ---

$(host_update ${HOST})

${MESSAGE}

${fawn}Good coding, good luck!${normal}
${green}============   Project Ready     ===========${normal}
EOF

if [[ $HAS_VENDOR -eq 0 ]]; then
    run_composer_run
fi