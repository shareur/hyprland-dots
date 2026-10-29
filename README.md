# hyprland-dots

个人 Hyprland 桌面配置（Ubuntu 26.04），基于
[LinuxBeginnings/Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)（KoolDots）。

这个仓库采用 **overlay（覆盖层）** 方式：主体配置跟随上游，仓库只保存个人差异。
这样既能保持“一套配置到处用”，又不会因为 fork 整个仓库而难以跟进上游更新。

- 上游锁定版本：见 [`upstream.lock`](upstream.lock)
- 当前验证环境：Ubuntu 26.04 LTS + Hyprland 0.56.2（`ppa:cppiber/hyprland`）
- 许可证：GPL-3.0（继承上游）

## 快速开始（新 Ubuntu）

```bash
# 1. 先安装上游完整环境（Hyprland、waybar、quickshell、依赖包）
#    详细步骤见 docs/fresh-ubuntu.md
git clone -b 26.04 https://github.com/LinuxBeginnings/Ubuntu-Hyprland.git
cd Ubuntu-Hyprland && ./install.sh

# 2. 应用个人覆盖层
git clone git@github.com:<你的用户名>/hyprland-dots.git ~/Projects/hyprland-dots
cd ~/Projects/hyprland-dots
./install.sh --assets

# 3. 检查并重新登录
./doctor.sh
```

已有 Hyprland 环境只想应用配置：

```bash
./install.sh --dry-run   # 先看会改什么
./install.sh             # 自动备份到 ~/.config-backup-<时间>
```

## 仓库结构

```text
.
├── install.sh              # 应用 overlay 到 $HOME（自动备份）
├── capture.sh              # 把当前机器上的个人配置反向同步回 overlay/
├── update.sh               # 更新 upstream.lock 中锁定的上游版本
├── doctor.sh               # 只读体检：版本、命令、字体、主题、软链
├── upstream.lock           # 上游仓库 + 锁定 tag
├── overlay/                # 真正部署到 $HOME 的文件
│   ├── .config/
│   │   ├── hypr/           # UserConfigs / UserScripts / 个人覆盖文件
│   │   ├── kitty/ ghostty/ cava/ ags/
│   │   ├── gtk-3.0/ gtk-4.0/ nwg-look/
│   │   ├── environment.d/ autostart/ systemd/user/
│   │   └── mimeapps.list user-dirs.dirs ...
│   ├── .zshrc .zprofile .tmux.conf
├── assets/
│   ├── fonts.sh            # Nerd Fonts（JetBrainsMono / Fantasque / VictorMono）
│   ├── gtk-themes-icons.sh # Flat-Remix + Bibata
│   └── wallpapers.sh       # 上游壁纸库，或从旧盘复制
├── packages/apt-extra.txt  # 上游安装器没覆盖到的额外包
└── docs/
    ├── fresh-ubuntu.md     # 全新安装步骤
    ├── upstream-update.md  # 跟随上游更新
    ├── personal-changes.md # 个人修改清单
    └── monitors.md         # 显示器布局
```

## 哪些东西不在仓库里

- **壁纸**（本机约 882MB）：用 `assets/wallpapers.sh --from <旧盘路径>` 恢复。
- **字体/图标/主题二进制**：`assets/*.sh` 从上游 release 下载。
- **机器相关状态**：`monitors.conf`、wallust 生成的颜色、锁屏壁纸缓存等。
- **隐私数据**：浏览器 profile、SSH key、token、`~/.cache`、Steam 等。

## 日常维护

改了桌面配置后，把改动收回仓库：

```bash
./capture.sh          # 或 ./capture.sh --dry-run
git diff
git commit -m "tweak: ..."
```

跟随上游：

```bash
./update.sh                       # 查看/切换最新上游 tag
# 按 docs/upstream-update.md 更新系统，然后：
./install.sh && ./doctor.sh
```

## 已知前提

- 配置是 **Hyprland Lua 格式**，需要 Hyprland >= 0.55，推荐 0.56.x。
- Waybar / Quickshell / wallust / awww 由上游 Ubuntu 安装器编译到
  `/usr/local/bin`，不是 apt 包。
- 需要 `fcitx5`、`Fira Code`、Nerd Fonts；`doctor.sh` 会逐项检查。

## 致谢

- [LinuxBeginnings/Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)（KoolDots，GPL-3.0）
- [Ubuntu-Hyprland](https://github.com/LinuxBeginnings/Ubuntu-Hyprland)
- [GTK-themes-icons](https://github.com/LinuxBeginnings/GTK-themes-icons)、
  [Wallpaper-Bank](https://github.com/LinuxBeginnings/Wallpaper-Bank)
- Nerd Fonts、Flat-Remix、Bibata、Catppuccin 等上游项目
