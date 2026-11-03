#!/usr/bin/env bash
# Install/upgrade WindInput (清风输入法) from GitHub Releases.
#
# WindInput is a Fcitx5 addon shipped as a .deb and is not in the Ubuntu
# archive. This script picks the latest amd64/arm64 build, verifies its
# sha256 and installs it with apt (which pulls the fcitx5 dependencies).
#
# Usage: ./assets/windinput.sh [--dry-run]
set -euo pipefail

REPO="huanfeng/WindInput"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m[OK]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || die "需要 curl: sudo apt install curl"
command -v dpkg >/dev/null || die "需要 dpkg"
[ "$(id -u)" -eq 0 ] && die "不要用 root 运行；脚本会在需要时调用 sudo"

arch="$(dpkg --print-architecture)"
case "$arch" in
  amd64|arm64) ;;
  *) die "不支持的架构: $arch（WindInput 只提供 amd64/arm64）" ;;
esac

api="https://api.github.com/repos/$REPO/releases/latest"
info "查询最新版本: $REPO"
release_json="$(curl -fsSL "$api")" || die "无法访问 GitHub API（检查网络/代理）"
tag="$(printf '%s' "$release_json" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
[ -n "$tag" ] || die "无法解析最新 release tag"

deb_name="WindInput-${tag#v}-linux-${arch}.deb"
deb_url="$(printf '%s' "$release_json" \
  | grep -o '"browser_download_url":[[:space:]]*"[^"]*"' \
  | cut -d'"' -f4 | grep -F "/$deb_name" | head -n1 || true)"
[ -n "$deb_url" ] || die "release $tag 里找不到 $deb_name"

info "版本: $tag"
info "安装包: $deb_url"
if [ "$DRY_RUN" -eq 1 ]; then
  info "dry-run：不会下载或安装"
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

info "下载安装包和 sha256 ..."
curl -fL --retry 3 -o "$tmp_dir/$deb_name" "$deb_url"
curl -fL --retry 3 -o "$tmp_dir/$deb_name.sha256" "$deb_url.sha256"

info "验证 sha256 ..."
( cd "$tmp_dir" && sha256sum -c "$deb_name.sha256" ) || die "sha256 校验失败"

info "安装（需要 sudo，会安装 fcitx5 依赖）..."
sudo apt install -y "$tmp_dir/$deb_name"

ok "WindInput $tag 安装完成。"
cat <<'EOF'

后续：
  1. 运行 fcitx5 -rd 或注销重新登录。
  2. 打开「Fcitx 5 配置」(fcitx5-configtool)，确认「清风输入法」已启用。
  3. 仓库里的 ~/.config/fcitx5 和 ~/.config/WindInput 会提供相同的输入法组/按键设置。
EOF
