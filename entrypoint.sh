#!/bin/sh

PB_HOST=${PB_HOST:-0.0.0.0}
PB_PORT=${PB_PORT:-8090}

PB_ADMIN_EMAIL=${PB_ADMIN_EMAIL:-"admin@admin.com"}
PB_ADMIN_PASSWORD=${PB_ADMIN_PASSWORD:-"password"}

PB_DATA=${PB_DATA:-"/pb_data"}
PB_PUBLIC=${PB_PUBLIC:-"/pb_public"}
PB_HOOKS=${PB_HOOKS:-"/pb_hooks"}

DEFAULT_ARGS="serve --http=${PB_HOST}:${PB_PORT} --dir=${PB_DATA} --publicDir=${PB_PUBLIC} --hooksDir=${PB_HOOKS}"
if [ $# -eq 0 ]; then
    SERVE_ARGS=${DEFAULT_ARGS}
else
    SERVE_ARGS="$@"
fi

create_superuser() {
    if [ -n "$PB_ADMIN_EMAIL" ] && [ -n "$PB_ADMIN_PASSWORD" ]; then
        /bin/pocketbase superuser upsert "$PB_ADMIN_EMAIL" "$PB_ADMIN_PASSWORD" --dir=/pb_data
    fi
}

VERSION=$(grep -m 1 '^## ' CHANGELOG.md | sed 's/^## //;s/ .*//')

echo "====================================="
echo "PocketBase $VERSION"
echo "email: $PB_ADMIN_EMAIL"
echo "password: $PB_ADMIN_PASSWORD"
echo "====================================="
echo "Starting PocketBase with args: '$SERVE_ARGS'"
echo "Data Path: $PB_DATA"
echo "Public Path: $PB_PUBLIC"
echo "Hooks Path: $PB_HOOKS"


if [ ! -d "${PB_DATA}/data.db" ]; then
    create_superuser
fi


exec /bin/pocketbase $SERVE_ARGS
