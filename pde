#!/bin/bash

if [ -L "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$( cd "$(dirname $(readlink "${BASH_SOURCE[0]}"))" &> /dev/null && pwd )"
else
  SCRIPT_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )"
fi

function doInit() {
  export CURRENT_DIR=$(pwd)
  export PARENT_DIR=$(dirname $CURRENT_DIR)
  export COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-$(basename $CURRENT_DIR)}
  export PROJECT_NAME=${PROJECT_NAME:-$COMPOSE_PROJECT_NAME}
  export NETWORK=${NETWORK:-"dev_network"}
  export NETWORK_PROXY_PORT=${NETWORK_PROXY_PORT:-80}
  export PROJECT_DIR=${PROJECT_DIR:-$CURRENT_DIR}
  export NGINX_CONF=${NGINX_CONF:-"$SCRIPT_DIR/defaults/default.conf.template"}
  export FPM_ENTRYPOINT=${FPM_ENTRYPOINT:-"$SCRIPT_DIR/defaults/fpm-entrypoint"}
  export TOOL_ENTRYPOINT=${FPM_ENTRYPOINT:-"$SCRIPT_DIR/defaults/tool-entrypoint"}

  cat "$SCRIPT_DIR/env.tpl" | envsubst > .pde
}

function compose() {
  CURRENT_DIR=$(pwd)
  cd $SCRIPT_DIR
  docker-compose --env-file "$CURRENT_DIR/.pde" $@
}

function doHelp() {
  NAME=$(basename ${BASH_SOURCE[0]})

  echo "Usage: $NAME <command> [args]"

  echo "Commands:"
  echo "  init               - create settings file"
  echo "  start              - start fpm and nginx containers"
  echo "  stop               - stop fpm and nginx containers"
  echo "  compose <args>     - run docker-compose <args>"
  echo "  destroy            - run docker-compose down"
  echo "  proxy <start|stop> - start or stop jwilder/nginx-proxy"
  echo "  tool <command>     - run command in tool container"
  echo ""
  echo "Init env variables:"
  echo "  COMPOSE_PROJECT_NAME - name of docker-compose project"
  echo "  PROJECT_NAME         - name of current project"
  echo "  NETWORK              - name of docker network"
  echo "  NETWORK_PROXY_PORT   - port for http proxy"
  echo "  PROJECT_DIR          - path to project sources (for mount)"
  echo "  NGINX_CONF           - path to nginx default.conf.template"
  echo "  FPM_ENTRYPOINT       - path to entrypoint script for fpm container"
  echo "  TOOL_ENTRYPOINT      - path to entrypoint script for tool container"
}

case $1 in
  init)
    shift
    doInit $@
    ;;
  compose)
    shift
    compose $@
    ;;
  start)
    compose up -d php nginx
    ;;
  stop)
    compose stop php nginx
    ;;
  tool)
    shift
    compose run --rm tool $@
    ;;
  destroy)
    compose down
    ;;
  proxy)
    shift
    case $1 in
      start)
        compose up -d proxy
        ;;
      stop)
        compose stop proxy
        ;;
      *)
        doHelp
        ;;
    esac
    ;;
  *)
    doHelp
    ;;
esac