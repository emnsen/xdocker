#!/usr/bin/env bash

normal=$'\e[0m'                           # (works better sometimes)
bold=$(tput bold)                         # make colors bold/bright
red="$bold$(tput setaf 1)"                # bright red text
green=$(tput setaf 2)                     # dim green text
fawn=$(tput setaf 3); beige="$fawn"       # dark yellow text
yellow="$bold$fawn"                       # bright yellow text
darkblue=$(tput setaf 4)                  # dim blue text
blue="$bold$darkblue"                     # bright blue text
purple=$(tput setaf 5); magenta="$purple" # magenta text
pink="$bold$purple"                       # bright magenta text
darkcyan=$(tput setaf 6)                  # dim cyan text
cyan="$bold$darkcyan"                     # bright cyan text
gray=$(tput setaf 7)                      # dim white text
darkgray="$bold"$(tput setaf 0)           # bold black = dark gray text
white="$bold$gray"                        # bright white text

function checkport () {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null
    then
        return 1;
    else
        return 0;
    fi
}

function getport() {
    if checkport $1; then
        echo "$1"
    else
       PORT=$(($1 + 1))

       getport $PORT
    fi
}

function database_name {
    database_name=$(grep -i "database_name" $1)
    echo ${database_name#*:}
}

function database_user {
    database_user=$(grep -i "database_user" $1)
    echo ${database_user#*:}
}

function database_password {
    database_password=$(grep -i "database_password" $1)
    echo ${database_password#*:}
}

function host_update {
    HOST=$1

    HOST_LINE=$(grep "127.0.0.1 $HOST #xdocker-host" /etc/hosts)

    if echo "${HOST_LINE}" | grep -q "^#"; then
        REPLACE='sed -i -e "/'$HOST_LINE'/d" /etc/hosts'
        sudo sh -c "${REPLACE}"
        HOST_LINE=${HOST_LINE:1}

        sudo sh -c 'echo "127.0.0.1 '${HOST_LINE}' #xdocker-host" >> /etc/hosts'
        echo "Hosts file updated 127.0.0.1 $HOST_LINE"
    else
        if grep -q "127.0.0.1 $HOST" /etc/hosts; then
            echo "127.0.0.1 $HOST already exists. Hosts file not updated."
        else
            sudo sh -c 'echo "127.0.0.1 '${HOST}' #xdocker-host" >> /etc/hosts'
            echo "Hosts file updated 127.0.0.1 $HOST"
        fi
    fi
}

function host_remove {
    HOST=$1
    HOST_LINE=$(grep "127.0.0.1 $HOST #xdocker-host" /etc/hosts)
    REPLACE='sed -i -e "/'$HOST_LINE'/d" /etc/hosts'

    sudo sh -c "${REPLACE}"
}

function find_default_ip {
    IPS=$(sh -c 'docker network inspect proxy_default | grep "IPv4Address" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"')

    echo $IPS | sed 's/ /,/g'
}

function run_composer_run {
    docker-compose exec php-fpm composer install
}

function docker_sync_volume_create {
    APP_NAME=$(cat .env | grep "^NAME=" | sed "s/NAME=//g")
    VOLUME_EXISTS=$(docker volume ls | grep "$APP_NAME-sync")

    if [[ ! $VOLUME_EXISTS ]]; then
        docker volume create --name="$APP_NAME-sync" >/dev/null
        echo "Docker volume was created with the name ${bold}${purple}\"$APP_NAME-sync\"${normal}."
    else
        echo "Docker ${bold}${purple}\"$APP_NAME-sync\"${normal} volume exists."
    fi
}

# ref: https://gist.github.com/JamieMason/4761049
function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}
