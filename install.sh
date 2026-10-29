#!/usr/bin/env bash
# ==================================================
#  Personal KoolDots overlay installer
#  Base: https://github.com/LinuxBeginnings/Hyprland-Dots (GPL-3.0)
# ==================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY="$REPO_DIR/overlay"
LOCK="$REPO_DIR/upstream.lock"

DRY_RUN=0
NO_BACKUP=0
WITH_ASSETS=0
USE_BASE=0

usage() {
  cat <<'EOF'
用法: ./install.sh [选项]

把本仓库的 overlay/ 合并到 $HOME（主要是 ~/.config），不会删除其它文件。

选项:
  --base        如果系统还没有 Hyprland 配置，先拉取 upstream.lock 中锁定的
                KoolDots 版本作为基础配置（新系统请优先运行 Ubuntu-Hyprland 安装器）
  --assets      同时安装字体、GTK 主题/图标、壁纸
  --no-backup   不备份将被覆盖的文件（不推荐）
  --dry-run     只显示会做什么，不写入任何文件
  -h, --help    显示帮助

推荐流程（Ubuntu 26.04 全新安装）:
  1. 先运行上游 Ubuntu-Hyprland 安装器，选择安装 KoolDots 配置
  2. 重新登录 Hyprland
  3. git clone <this repo> && cd <this repo>
  4. ./install.sh --assets
  5. 重新登录
EOF
}

die() { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
ok() { printf '\033[32m[OK]\033[0m %s\n' "$*"; }

for arg in "$@"; do
  case "$arg" in
    --base) USE_BASE=1 ;;
    --assets) WITH_ASSETS=1 ;;
    --no-backup) NO_BACKUP=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $arg（用 --help 查看用法）" ;;
  esac
done

[ -d "$OVERLAY" ] || die "找不到 overlay 目录: $OVERLAY"
[ -f "$LOCK" ] || die "找不到 upstream.lock"
# shellcheck disable=SC1090
source "$LOCK"
: "${UPSTREAM_REPO:?upstream.lock 缺少 UPSTREAM_REPO}"
: "${UPSTREAM_REF:?upstream.lock 缺少 UPSTREAM_REF}"

command -v rsync >/dev/null || die "需要 rsync: sudo apt install rsync"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-dots/upstream-$UPSTREAM_REF"

fetch_upstream() {
  if [ ! -d "$CACHE_DIR/.git" ]; then
    info "拉取上游 KoolDots $UPSTREAM_REF ..."
    mkdir -p "$(dirname "$CACHE_DIR")"
    git clone --depth 1 --branch "$UPSTREAM_REF" \
      --filter=blob:none --sparse "$UPSTREAM_REPO" "$CACHE_DIR"
    git -C "$CACHE_DIR" sparse-checkout set config
  fi
}

check_hyprland_version() {
  command -v hyprctl >/dev/null || {
    warn "找不到 hyprctl。基础包还没装好；本脚本只负责配置覆盖。"
    return
  }
  local ver major minor
  ver="$(hyprctl version 2>/dev/null | sed -n 's/^Hyprland \([0-9][0-9.]*\).*/\1/p' | head -n1)"
  [ -n "$ver" ] && info "检测到 Hyprland $ver（Lua 配置需要 >= 0.55，推荐 0.56.x）"
  major="${ver%%.*}"
  minor="$(printf '%s' "$ver" | cut -d. -f2)"
  if [ -n "${major:-}" ] && [ -n "${minor:-}" ]; then
    if [ "$major" -eq 0 ] && [ "$minor" -lt 55 ]; then
      warn "Hyprland $ver 可能无法加载本仓库的 Lua 配置，请使用 cppiber/hyprland PPA 的 0.56.x"
    fi
  fi
}

# --- 0. sanity ------------------------------------------------------------
check_hyprland_version

if [ ! -f "$HOME/.config/hypr/hyprland.lua" ]; then
  if [ "$USE_BASE" -eq 1 ]; then
    fetch_upstream
    info "写入上游基础配置到 ~/.config ..."
    if [ "$DRY_RUN" -eq 1 ]; then
      rsync -an --itemize-changes "$CACHE_DIR/config/" "$HOME/.config/" | sed -n '1,20p'
    else
      rsync -a "$CACHE_DIR/config/" "$HOME/.config/"
    fi
  else
    die "没有找到 ~/.config/hypr/hyprland.lua。
请先运行上游 Ubuntu-Hyprland 安装器（推荐），或加 --base 使用锁定版本初始化。"
  fi
fi

# --- 1. backup ------------------------------------------------------------
backup_existing() {
  local backup count=0 rel src
  backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
  while IFS= read -r -d '' src; do
    rel="${src#"$OVERLAY"/}"
    if [ -e "$HOME/$rel" ] || [ -L "$HOME/$rel" ]; then
      mkdir -p "$backup/$(dirname "$rel")"
      cp -a "$HOME/$rel" "$backup/$rel"
      count=$((count + 1))
    fi
  done < <(find "$OVERLAY" -mindepth 1 \( -type f -o -type l \) -print0)
  if [ "$count" -gt 0 ]; then
    ok "已备份 $count 个将被覆盖的文件到 $backup"
  fi
}

if [ "$NO_BACKUP" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  backup_existing
elif [ "$NO_BACKUP" -eq 1 ]; then
  warn "已跳过备份（--no-backup）"
fi

# --- 2. apply overlay -----------------------------------------------------
info "应用个人 overlay 到 $HOME ..."
if [ "$DRY_RUN" -eq 1 ]; then
  rsync -an --itemize-changes "$OVERLAY/" "$HOME/" | sed -n '1,80p'
else
  rsync -a "$OVERLAY/" "$HOME/"
fi

# --- 3. permissions / systemd --------------------------------------------
if [ "$DRY_RUN" -eq 0 ]; then
  find "$HOME/.config/hypr/scripts" "$HOME/.config/hypr/UserScripts" \
    -type f -name '*.sh' -exec chmod +x {} + 2>/dev/null || true

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now hyprland-monitor-config-reload.path 2>/dev/null || true
  fi
fi

# --- 4. optional assets ---------------------------------------------------
if [ "$WITH_ASSETS" -eq 1 ]; then
  info "安装字体 / 图标 / 主题 / 壁纸 ..."
  bash "$REPO_DIR/assets/fonts.sh"
  bash "$REPO_DIR/assets/gtk-themes-icons.sh"
  bash "$REPO_DIR/assets/wallpapers.sh" || warn "壁纸安装被跳过（可稍后手动运行 assets/wallpapers.sh）"
fi

ok "完成。"
cat <<'EOF'

后续：
  1. 完全注销并重新登录 Hyprland（或重启）。
  2. 首次进入后运行：~/.config/hypr/scripts/Refresh.sh
  3. 检查：./doctor.sh
  4. 壁纸目录默认是 ~/Pictures/wallpapers；没有的话运行 assets/wallpapers.sh。
EOF
