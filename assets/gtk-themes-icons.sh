#!/usr/bin/env bash
# Install the GTK themes, icon themes and cursor used by gtk-3.0/gtk-4.0/qt settings.
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-dots/gtk-themes-icons"
REPO="https://github.com/LinuxBeginnings/GTK-themes-icons.git"

info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }

command -v unzip >/dev/null || { echo "需要 unzip: sudo apt install unzip"; exit 1; }

if [ ! -d "$CACHE/.git" ]; then
  info "拉取 GTK-themes-icons ..."
  rm -rf "$CACHE"
  git clone --depth 1 "$REPO" "$CACHE"
else
  git -C "$CACHE" pull --ff-only --depth 1 >/dev/null 2>&1 || true
fi

mkdir -p "$HOME/.icons" "$HOME/.themes"

if compgen -G "$CACHE/icon/*.zip" >/dev/null; then
  info "安装图标/光标 ..."
  unzip -oq "$CACHE"/icon/*.zip -d "$HOME/.icons"
fi

if compgen -G "$CACHE/theme/*.tar.gz" >/dev/null; then
  info "安装 GTK 主题 ..."
  for f in "$CACHE"/theme/*.tar.gz; do
    tar -xzf "$f" -C "$HOME/.themes" --overwrite
  done
fi

for dir in "$HOME/.icons"/*; do
  [ -d "$dir" ] || continue
  [ -f "$dir/index.theme" ] && gtk-update-icon-cache -f -t "$dir" >/dev/null 2>&1 || true
done

ok "主题/图标安装完成：$HOME/.themes  $HOME/.icons"
