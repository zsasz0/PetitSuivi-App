#!/bin/bash

set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-petitsuivi-cloudflared}"

usage() {
    echo "Usage: $0 {start|stop|restart|status|logs}"
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

case "$1" in
    start)
        docker start "$CONTAINER_NAME"
        ;;
    stop)
        docker stop "$CONTAINER_NAME"
        ;;
    restart)
        docker restart "$CONTAINER_NAME"
        ;;
    status)
        docker ps -a --filter "name=^${CONTAINER_NAME}$" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
        ;;
    logs)
        docker logs --tail 50 "$CONTAINER_NAME"
        ;;
    *)
        usage
        exit 1
        ;;
esac
