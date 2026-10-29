# 全新 Ubuntu 26.04 安装

目标：新系统装完后，得到和旧机器一致的 Hyprland 桌面。

> 本仓库是**个人覆盖层**，不是完整的 dotfiles。主体配置（Hyprland、Waybar、
> Quickshell、脚本、主题模板）由上游 KoolDots 提供，本仓库只保存个人差异。

## 0. 准备

- Ubuntu 26.04 LTS（对应上游 `Ubuntu-Hyprland` 的 `26.04` 分支）
- 能联网，普通用户（不要用 root 跑安装器）
- NVIDIA 用户：先按上游 Wiki 处理驱动，建议先备份系统

## 1. 安装系统依赖 + 上游 KoolDots

用上游官方安装器（会安装 Hyprland 0.56.x PPA、编译 waybar/quickshell/wallust/awww、安装字体和图标等）：

```bash
sudo apt update
sudo apt install -y git curl

git clone -b 26.04 https://github.com/LinuxBeginnings/Ubuntu-Hyprland.git
cd Ubuntu-Hyprland
chmod +x install.sh
./install.sh
```

安装过程中选择 **安装 KooL's Hyprland Dots**（即上游配置）。
安装完成后重启，登录 Hyprland，确认桌面能正常起来。

> 也可以使用上游的一行命令：
> `sh <(curl -L https://raw.githubusercontent.com/LinuxBeginnings/Ubuntu-Hyprland/26.04/auto-install.sh)`

## 2. 部署个人覆盖层

```bash
git clone git@github.com:<你的用户名>/hyprland-dots.git ~/Projects/hyprland-dots
cd ~/Projects/hyprland-dots
chmod +x install.sh capture.sh update.sh doctor.sh assets/*.sh

# 先看会改哪些文件
./install.sh --dry-run

# 正式应用（自动备份到 ~/.config-backup-<时间>）
./install.sh
```

## 3. 安装字体、图标、主题、壁纸

```bash
./assets/fonts.sh
./assets/gtk-themes-icons.sh

# 方案 A：用上游壁纸库
./assets/wallpapers.sh

# 方案 B：从旧硬盘/备份复制你原来的 882MB 壁纸
./assets/wallpapers.sh --from /data/Pictures/wallpapers
```

壁纸路径固定为 `~/Pictures/wallpapers`，因为上游脚本这样引用。

## 4. 显示器布局

`monitors.conf` 与机器相关，没有进仓库。装好后用 `nwg-displays` 生成，
或者从旧机器复制后改输出名。详见 [`monitors.md`](monitors.md)。

## 5. 验证

```bash
./doctor.sh
```

然后**完全注销并重新登录**。首次进入后可以运行：

```bash
~/.config/hypr/scripts/Refresh.sh
```

## 常见问题

- **Hyprland 起不来 / Lua 配置报错**：确认版本是 0.56.x（`hyprctl version`）。
  Ubuntu 官方源的 0.53.3 不支持 Lua 配置，必须用 `ppa:cppiber/hyprland`。
- **Waybar 不显示**：确认 `/usr/local/bin/waybar` 存在，且
  `~/.config/hypr/waybar/config` 软链指向 `configs/TOP-Default`。
- **中文字体/输入法**：`fcitx5 -d` 会由 `user_startup.lua` 启动；确认
  `environment.d/90-fcitx5.conf` 已生效。
- **终端字体不对**：kitty 使用 `~/.config/hypr/UserConfigs/kitty.conf`
  （通过 `KITTY_CONFIG_DIRECTORY`），需要 `FantasqueSansM Nerd Font Mono`。
