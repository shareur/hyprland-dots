#!/usr/bin/env bash
# Read-only health check for this overlay on a (new) Ubuntu machine.
set -u

ok_count=0
warn_count=0
fail_count=0
ok()   { printf '\033[32m[ OK ]\033[0m %s\n' "$*"; ok_count=$((ok_count+1)); }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; warn_count=$((warn_count+1)); }
fail() { printf '\033[31m[FAIL]\033[0m %s\n' "$*"; fail_count=$((fail_count+1)); }

need_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "命令 $1"
  else
    fail "缺少命令 $1（$2）"
  fi
}

echo "== 基础命令 =="
need_cmd hyprctl "hyprland"
need_cmd waybar "waybar"
need_cmd qs "quickshell"
need_cmd wallust "wallust"
need_cmd awww "awww / swww"
need_cmd swaync "swaync"
need_cmd rofi "rofi"
need_cmd kitty "kitty"
need_cmd fcitx5 "fcitx5"

echo
echo "== 配置文件 =="
for f in \
  "$HOME/.config/hypr/hyprland.lua" \
  "$HOME/.config/hypr/UserConfigs/user_settings.lua" \
  "$HOME/.config/hypr/UserConfigs/user_keybinds.lua" \
  "$HOME/.config/kitty/kitty.conf" \
  "$HOME/.config/ghostty/config" \
  "$HOME/.config/gtk-3.0/settings.ini"; do
  [ -f "$f" ] && ok "$f" || fail "缺少 $f"
done

echo
echo "== Hyprland 版本 =="
ver="$(hyprctl version 2>/dev/null | sed -n 's/^Hyprland \([0-9][0-9.]*\).*/\1/p' | head -n1)"
if [ -z "$ver" ]; then
  fail "无法获取 hyprctl version（当前不在 Hyprland 会话？）"
else
  minor="$(printf '%s' "$ver" | cut -d. -f2)"
  if [ "${minor:-0}" -ge 55 ]; then
    ok "Hyprland $ver（支持 Lua 配置）"
  else
    fail "Hyprland $ver 太旧，Lua 配置需要 >= 0.55（推荐 0.56.x）"
  fi
fi

echo
echo "== 配置健康 =="
if hyprctl version >/dev/null 2>&1; then
  deprecated="$(hyprctl deprecated-config 2>/dev/null || true)"
  if [ -z "$deprecated" ] || printf '%s' "$deprecated" | grep -q '^all good'; then
    ok "没有废弃配置项"
  else
    warn "存在废弃配置项（hyprctl deprecated-config）："
    printf '%s\n' "$deprecated"
  fi

  config_errors="$(hyprctl configerrors 2>/dev/null || true)"
  if [ -z "$config_errors" ] || printf '%s' "$config_errors" | grep -qi '^no errors'; then
    ok "没有配置错误"
  else
    warn "存在配置错误（hyprctl configerrors）："
    printf '%s\n' "$config_errors"
  fi
else
  warn "当前不在 Hyprland 会话，跳过配置健康检查"
fi

echo
echo "== 字体 =="
for font in "JetBrainsMono Nerd Font" "FantasqueSansM Nerd Font" "Fira Code"; do
  if fc-list 2>/dev/null | grep -qi "$font"; then
    ok "字体 $font"
  else
    warn "未找到字体 $font（运行 assets/fonts.sh）"
  fi
done

echo
echo "== 主题 / 图标 =="
[ -d "$HOME/.themes/Flat-Remix-GTK-Blue-Dark" ] && ok "Flat-Remix GTK" || warn "缺少 Flat-Remix GTK（assets/gtk-themes-icons.sh）"
[ -d "$HOME/.icons/Flat-Remix-Blue-Dark" ] && ok "Flat-Remix 图标" || warn "缺少 Flat-Remix 图标（assets/gtk-themes-icons.sh）"
[ -d "$HOME/.icons/Bibata-Modern-Ice" ] && ok "Bibata 光标" || warn "缺少 Bibata 光标（assets/gtk-themes-icons.sh）"

echo
echo "== 壁纸 =="
[ -d "$HOME/Pictures/wallpapers" ] && ok "$HOME/Pictures/wallpapers" || warn "缺少壁纸目录（assets/wallpapers.sh）"

echo
echo "== 可移植性 =="
bad_links="$(find "$HOME/.config/hypr" -type l -lname '/home/*' 2>/dev/null || true)"
if [ -n "$bad_links" ]; then
  warn "存在绝对路径软链，换用户名会断："
  printf '%s\n' "$bad_links"
else
  ok "没有绝对路径软链"
fi

echo
printf '结果: %d ok, %d warn, %d fail\n' "$ok_count" "$warn_count" "$fail_count"
[ "$fail_count" -eq 0 ]
