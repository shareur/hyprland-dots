#!/usr/bin/env bash
# Capture live personal files from ~/.config back into overlay/.
# Use this after tweaking the running desktop so the repo stays the source of truth.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY="$REPO_DIR/overlay"
HOME_DIR="${HOME:?}"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

TRACKED=(
  ".config/hypr/UserConfigs"
  ".config/hypr/UserScripts"
  ".config/hypr/hyprlock.conf"
  ".config/hypr/hypridle.conf"
  ".config/hypr/scripts/DarkLight.sh"
  ".config/hypr/scripts/ApplyThemeMode.sh"
  ".config/kitty"
  ".config/ghostty/config"
  ".config/cava"
  ".config/ags"
  ".config/systemd/user"
  ".config/gtk-3.0"
  ".config/gtk-4.0"
  ".config/qt5ct"
  ".config/qt6ct"
  ".config/Kvantum"
  ".config/nwg-look"
  ".config/environment.d"
  ".config/autostart"
  ".config/mimeapps.list"
  ".config/user-dirs.dirs"
  ".config/pavucontrol.ini"
  ".zshrc"
  ".zprofile"
  ".tmux.conf"
)

info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }

for rel in "${TRACKED[@]}"; do
  src="$HOME_DIR/$rel"
  dst="$OVERLAY/$rel"
  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    warn "跳过不存在的 $rel"
    continue
  fi
  info "capture $rel"
  if [ "$DRY_RUN" -eq 1 ]; then
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -d "$src" ]; then
    args=(-a --delete)
    case "$rel" in
      .config/hypr/UserConfigs)
        args+=(--exclude 'kitty-themes/' --exclude '00-Readme') ;;
      .config/systemd/user)
        args+=(--exclude 'default.target.wants/') ;;
      .config/gtk-3.0)
        args+=(--exclude 'bookmarks') ;;
    esac
    rsync "${args[@]}" "$src/" "$dst/"
  else
    cp -a "$src" "$dst"
  fi
done

if [ "$DRY_RUN" -eq 0 ]; then
  # Keep waybar selections portable instead of absolute /home/<user> links.
  for f in config style.css; do
    link="$HOME_DIR/.config/hypr/waybar/$f"
    [ -L "$link" ] || continue
    target="$(readlink "$link")"
    case "$target" in
      */configs/*) ln -sfn "configs/${target##*/}" "$OVERLAY/.config/hypr/waybar/$f" ;;
      */style/*)   ln -sfn "style/${target##*/}"   "$OVERLAY/.config/hypr/waybar/$f" ;;
    esac
  done
  ok "已同步到 overlay/，请 git diff 检查后再提交。"
fi
