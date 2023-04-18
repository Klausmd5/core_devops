#!/bin/bash -eu

CONFIG_PATH=/data/mainframe-config.json

FRONTEND_PATH=/data/plugins/frontend
BACKEND_PATH=/data/plugins/backend

update_plugin() {
    local PLUGIN_ID=$1
    local PLUGIN_URL=$2

    echo "Downloading $PLUGIN_ID"
    curl -L "$PLUGIN_URL/releases/latest/download/backend.zip" --create-dirs -o "$BACKEND_PATH/$PLUGIN_ID/backend.zip"
    unzip -jqo "$BACKEND_PATH/$PLUGIN_ID/backend.zip" -d "$BACKEND_PATH/$PLUGIN_ID"
    rm "$BACKEND_PATH/$PLUGIN_ID/backend.zip"

    curl -L "$PLUGIN_URL/releases/latest/download/frontend.zip" --create-dirs -o "$FRONTEND_PATH/$PLUGIN_ID/frontend.zip"
    unzip -jqo "$FRONTEND_PATH/$PLUGIN_ID/frontend.zip" -d "$FRONTEND_PATH/$PLUGIN_ID"
    rm "$FRONTEND_PATH/$PLUGIN_ID/frontend.zip"
}

update_all_plugins() {
    for PLUGIN_ID in $(jq -r '.plugins | keys[]' "$CONFIG_PATH"); do
        local PLUGIN_URL=$(jq -r ".plugins[\"$PLUGIN_ID\"] .repoUrl //null" "$CONFIG_PATH")

        if grep -q "https" <<<"$PLUGIN_URL"; then
            update_plugin "$PLUGIN_ID" "$PLUGIN_URL"
        else
            echo "Skipping $PLUGIN_ID due to invalid URL: $PLUGIN_URL"
        fi
    done
}

compute_folder_hash() {
    find "$1" -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum | cut -d ' ' -f 1
}

restart_container_if_exists() {
    local CONTAINER_NAME=$1
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        echo "Restarting $CONTAINER_NAME..."
        docker restart "$CONTAINER_NAME"
    else
        echo "Couldn't find container $CONTAINER_NAME for restart"
    fi
}

update_with_restart_check() {
    local OLD_BACKEND_HASH=$(compute_folder_hash "$BACKEND_PATH")
    local OLD_FRONTEND_HASH=$(compute_folder_hash "$FRONTEND_PATH")
    update_all_plugins
    local NEW_BACKEND_HASH=$(compute_folder_hash "$BACKEND_PATH")
    local NEW_FRONTEND_HASH=$(compute_folder_hash "$FRONTEND_PATH")

    echo "$0: Backend: $OLD_BACKEND_HASH -> $NEW_BACKEND_HASH"
    if [ "$OLD_BACKEND_HASH" != "$NEW_BACKEND_HASH" ]; then
        restart_container_if_exists core-backend
    fi

    echo "$0: Frontend: $OLD_FRONTEND_HASH -> $NEW_FRONTEND_HASH"
    if [ "$OLD_FRONTEND_HASH" != "$NEW_FRONTEND_HASH" ]; then
        restart_container_if_exists core-frontend
    fi
}

while true; do
    update_with_restart_check
    echo "Sleeping for 10 minutes..."
    sleep 600
done
