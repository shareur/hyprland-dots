#!/usr/bin/env bash
# Bump the pinned upstream KoolDots version.
# It does NOT modify the running desktop; apply the overlay afterwards.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCK="$REPO_DIR/upstream.lock"

info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }

# shellcheck disable=SC1090
source "$LOCK"
current="$UPSTREAM_REF"

latest="$(
  curl -fsSL "https://api.github.com/repos/LinuxBeginnings/Hyprland-Dots/releases/latest" \
    | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n1
)" || true

target="${1:-${latest:-}}"
[ -n "$target" ] || { warn "无法获取最新 release，请显式传入 tag：./update.sh Hyprland-Dots-v2.3.28"; exit 1; }

info "当前锁定: $current"
info "目标版本: $target"

if [ "$target" = "$current" ]; then
  ok "已经是最新锁定版本。"
  exit 0
fi

sed -i "s|^UPSTREAM_REF=.*|UPSTREAM_REF=$target|" "$LOCK"
ok "upstream.lock 已更新为 $target"

cat <<EOF

接下来：
  1. 更新运行中的系统（上游会保留 UserConfigs/UserScripts）：
       cd ~/Hyprland-Dots-Ubuntu && git pull && ./copy.sh --express-upgrade
     （如果是用官方安装器安装的，也可以用安装器自带的更新菜单）
  2. 重新应用个人覆盖层：
       cd "$REPO_DIR" && ./install.sh
  3. 重点检查本仓库里 override 的系统文件（hyprlock.conf / hypridle.conf）：
       git diff -- overlay/.config/hypr/hyprlock.conf overlay/.config/hypr/hypridle.conf
  4. 运行 ./doctor.sh，然后重新登录。

发布说明: https://github.com/LinuxBeginnings/Hyprland-Dots/releases/tag/$target
EOF
