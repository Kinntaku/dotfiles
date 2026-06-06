#!/bin/bash

DOTFILES_DIR=$(
	cd "$(dirname "$0")"
	pwd
)

# home
for item in "$DOTFILES_DIR/home"/* "$DOTFILES_DIR/home"/.[!.]*; do
	base_name=$(basename "$item")
	target="$HOME/$base_name"
	if [ -e "$target" ] || [ -L "$target" ]; then
		rm -rf "$target"
	fi
	ln -snf "$item" "$target"
	echo "Linked: $base_name -> $target"
done
find "$HOME" -maxdepth 1 -xtype l -delete

# config
for item in "$DOTFILES_DIR/config"/*; do
	base_name=$(basename "$item")
	target="$HOME/.config/$base_name"
	if [ -e "$target" ] || [ -L "$target" ]; then
		rm -rf "$target"
	fi
	ln -snf "$item" "$target"
	echo "Linked: $base_name -> $target"
done
find "$HOME/.config" -maxdepth 1 -xtype l -delete

# others
declare -A OTHERS_MAP
OTHERS_MAP=(
	# ["settings.json"]="$HOME/.config/VSCodium/User"
	# ["keybindings.json"]="$HOME/.config/VSCodium/User"
	# ["tasks.json"]="$HOME/.config/VSCodium/User"
	["custom_phrase.txt"]="$HOME/.local/share/fcitx5/rime/"
	["default.custom.yaml"]="$HOME/.local/share/fcitx5/rime/"
	["wanxiang.custom.yaml"]="$HOME/.local/share/fcitx5/rime/"
	["opencode.json"]="$HOME/.config/opencode/"
	["auth.json"]="$HOME/.local/share/opencode/"
)

for item in "${!OTHERS_MAP[@]}"; do
	base="$DOTFILES_DIR/others/$item"
	target_dir="${OTHERS_MAP[$item]}"
	if [ ! -e "$base" ]; then
		echo "No $item found"
		continue
	fi
	if [ ! -d "$target_dir" ]; then
		mkdir -p "$target_dir"
		echo "Create: $target_dir"
	fi
	(
		cd "$target_dir" || exit 1
		if [ -e "$item" ] || [ -L "$item" ]; then
			rm -rf "$item"
		fi
		ln -snf "$base" .
	)
	echo "Linked: $item -> $target_dir/$item"
	find "$target_dir" -maxdepth 1 -xtype l -delete
done
