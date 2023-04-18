#!/bin/sh -eu

MAINFRAME_INPUT=/srv/mainframe-config.input.json
MAINFRAME_OUTPUT=/srv/mainframe/mainframe-config.json
CADDYFILE_INPUT=/srv/input.Caddyfile
CADDYFILE_OUTPUT=/etc/caddy/Caddyfile

echo "$0: Adding plugin subdomains to Caddyfile"

rm "$CADDYFILE_OUTPUT"
cp "$CADDYFILE_INPUT" "$CADDYFILE_OUTPUT"

for PLUGIN_FOLDER in /srv/plugins/*/; do
    # Convert full path to only folder name
    PLUGIN_FOLDER="${PLUGIN_FOLDER%/}"
    PLUGIN_FOLDER="${PLUGIN_FOLDER##*/}"

    echo "

${PLUGIN_FOLDER}.plugin.{\$DOMAIN_NAME} {
    import spa-host /srv/plugins/$PLUGIN_FOLDER
}
" >>$CADDYFILE_OUTPUT
done

echo "$0: Replacing domain name in mainframe config $MAINFRAME_INPUT"

sed "s|@@DOMAIN_NAME@@|$DOMAIN_NAME|g" "$MAINFRAME_INPUT" >$MAINFRAME_OUTPUT

echo "$0: Writing new mainframe config to $MAINFRAME_OUTPUT"

echo "$0: Starting Caddy..."

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
