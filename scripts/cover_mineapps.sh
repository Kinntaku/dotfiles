#!/bin/sh

MIME_FILE="$HOME/.config/mimeapps.list"
BAK_FILE="$DOTFILES/others/mimeapps.list"

cp -f "$BAK_FILE" "$MIME_FILE"

while true; do
    inotifywait -e modify -e attrib "$MIME_FILE" 2>/dev/null
    cp -f "$BAK_FILE" "$MIME_FILE"
done
