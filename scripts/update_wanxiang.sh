#!/bin/zsh

ARCHIVE_URL="https://github.com/amzxyz/rime_wanxiang/releases/latest/download/rime-wanxiang-base.zip"
FILE_URL="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"
TARGET_DIR="$HOME/.local/share/fcitx5/rime"

rm -rf "$TARGET_DIR"

if [[ ! -d "$TARGET_DIR" ]]; then
    mkdir -p "$TARGET_DIR"
fi

TEMP_ARCHIVE=$(mktemp)

curl -L -f -o "$TEMP_ARCHIVE" "$ARCHIVE_URL"
7z x "$TEMP_ARCHIVE" -o"$TARGET_DIR" -y
curl -L -f --output-dir "$TARGET_DIR" -O "$FILE_URL"