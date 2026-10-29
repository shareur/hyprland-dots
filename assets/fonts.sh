#!/usr/bin/env bash
# Install the fonts referenced by the overlay.
set -euo pipefail

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-dots/fonts"
NF_VERSION="${NF_VERSION:-v3.5.1}"
NF_BASE="https://github.com/ryanoasis/nerd-fonts/releases/download/$NF_VERSION"

info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }

mkdir -p "$FONT_DIR" "$CACHE"

install_zip() {
  local name="$1" dest="$FONT_DIR/$2" zip="$CACHE/$1.zip"
  if [ ! -f "$zip" ]; then
    info "下载 $1.zip ..."
    curl -fL --retry 3 --connect-timeout 20 -o "$zip" "$NF_BASE/$1.zip"
  fi
  mkdir -p "$dest"
  unzip -oq "$zip" -d "$dest"
  ok "字体 $2 -> $dest"
}

install_zip JetBrainsMono JetBrainsMonoNerd
install_zip FantasqueSansMono FantasqueSansMonoNerd
install_zip VictorMono VictorMono
install_zip NerdFontsSymbolsOnly NerdFontsSymbolsOnly

info "刷新字体缓存 ..."
fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1 || true

missing=0
for font in "JetBrainsMono Nerd Font" "FantasqueSansM Nerd Font" "Victor Mono"; do
  if fc-list 2>/dev/null | grep -qi "$font"; then
    ok "已识别 $font"
  else
    warn "fc-list 暂未识别 $font（可能需要重新登录）"
    missing=1
  fi
done

if ! fc-list 2>/dev/null | grep -qi "Fira Code"; then
  warn "缺少 Fira Code（GTK/Qt 界面字体）。Ubuntu 可执行：sudo apt install fonts-firacode fonts-open-sans"
fi

exit "$missing"
