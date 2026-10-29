#!/usr/bin/env bash
# Install wallpapers into ~/Pictures/wallpapers (the path used by KoolDots).
#
# The 882 MB personal collection is intentionally NOT stored in git.
# Options:
#   ./assets/wallpapers.sh                  # clone upstream Wallpaper-Bank
#   ./assets/wallpapers.sh --from /mnt/old # copy from an old disk / backup
#   ./assets/wallpapers.sh --force ...      # overwrite non-empty target
set -euo pipefail

TARGET="$HOME/Pictures/wallpapers"
SRC=""
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --from) SRC="${2:?--from 需要目录参数}"; shift 2 ;;
    --target) TARGET="${2:?--target 需要目录参数}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }

if [ -d "$TARGET" ] && [ -n "$(find "$TARGET" -maxdepth 1 -type f -print -quit 2>/dev/null)" ] && [ "$FORCE" -eq 0 ]; then
  warn "$TARGET 已有文件，跳过。要覆盖请加 --force"
  exit 0
fi

mkdir -p "$TARGET"

if [ -n "$SRC" ]; then
  [ -d "$SRC" ] || { echo "源目录不存在: $SRC"; exit 1; }
  info "从 $SRC 复制壁纸 ..."
  rsync -a "$SRC"/ "$TARGET"/
else
  CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-dots/wallpaper-bank"
  if [ ! -d "$CACHE/.git" ]; then
    info "克隆上游 Wallpaper-Bank ..."
    rm -rf "$CACHE"
    git clone --depth 1 https://github.com/LinuxBeginnings/Wallpaper-Bank.git "$CACHE"
  fi
  info "复制壁纸到 $TARGET ..."
  rsync -a "$CACHE/wallpapers"/ "$TARGET"/
fi

count="$(find "$TARGET" -maxdepth 1 -type f | wc -l)"
ok "完成，共 $count 个文件：$TARGET"
