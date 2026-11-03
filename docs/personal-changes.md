# 个人修改清单

这份清单说明 `overlay/` 里为什么有这些文件，以及和上游 v2.3.28 的差异。
升级上游后用它来检查哪些个人设置需要重新确认。

## Hyprland

- `UserConfigs/user_keybinds.lua`：以上游 v2.3.28 为基础，末尾保留个人
  `ALT+SPACE / D / X / C / V / K` 快捷键块。
- `UserConfigs/user_startup.lua`：以上游 v2.3.28 为基础，启动 `ags`、
  `blueman-applet`、`fcitx5 -d`。**未启用 `MonitorWatcher.sh`**，因为它会和
  下面的 nwg-displays 加载器抢显示器控制权；迁移到上游 DisplayProfile 后再启用。
- `UserConfigs/user_env.lua`：Flatpak 路径、`~/.local/bin`、fcitx5 环境变量、天气单位。
- `UserConfigs/user_settings.lua`：键盘/触控板设置（`kb_model = "pc105"`）；额外加了
  `cursor.no_hardware_cursors = 1`（NVIDIA/混合显卡），替代原来对
  `lua/settings.lua` 的直接修改。
- `lua/settings.lua`：以上游 v2.3.28 为基础 **整文件覆盖**，仅删除了
  `dwindle.special_scale_factor = 0.8`。该选项在 Hyprland 0.57 中已废弃且不再
  生效，保留会触发 “You are using 1 deprecated config option” 启动提示。上游
  目前（main）仍未删除，升级后需要确认本文件是否重新包含该行。
- `UserConfigs/user_decorations.lua`：采用上游 v2.3.28 的 wallust 动态边框颜色。
- `UserConfigs/user_animations.lua`、`user_defaults.lua`：动画/默认行为。
- `UserConfigs/user_laptops.lua`：采用上游 v2.3.28 的笔记本/外接显示器热插拔实现。
- `UserConfigs/workspaces.lua`：**不进仓库**。它由
  `PersistWorkspaceLayout.sh` 按当前显示器运行时写入，属于机器状态；
  当前系统里为空（没有自定义 workspace 规则），新机器会自行生成。
- `UserConfigs/monitors.lua`：读取 `~/.config/hypr/monitors.conf`，让
  `nwg-displays` 生成的布局可以直接生效。
- `UserConfigs/user_window_rules.lua`、`user_layer_rules.lua`。
- `UserConfigs/kitty.conf`、`ghostty.conf`、`hyprview-layout.conf`。
- `UserScripts/`：个人脚本目录（当前与上游一致，保留作为扩展位）。
- `hyprlock.conf`：锁屏天气缓存刷新改为 1 小时（其余已与上游 v2.3.28 一致）。
- `hypridle.conf`：保留旧版行为（休眠/唤醒后不重新拉起 WallpaperDaemon）；
  同时**注释掉 12 分钟自动关屏的 DPMS listener**。Hyprlock <= 0.9.6 在
  锁屏期间被 Hyprland 关屏时会崩溃，并把整个合成器一起带走
  （hyprwm/hyprlock#991）；上游修复前保持关闭，锁屏仍会按 5 分钟超时生效。
- `scripts/DarkLight.sh`、`scripts/ApplyThemeMode.sh`：个人新增脚本。
- `waybar/config -> configs/TOP-Default`、`style.css -> style/Extra-Arrow.css`：
  使用相对软链，换用户名不会断。

## 终端 / 应用

- `kitty/`：`FantasqueSansM Nerd Font Mono`、Monokai Soda 主题、
  `background_opacity 0.9`、关闭窗口缩放记忆、`allow_remote_control socket-only`
  （比原来的 `yes` 更安全，仍支持本地 socket 控制）。
  实际生效的是 `~/.config/hypr/UserConfigs/kitty.conf`（由
  `KITTY_CONFIG_DIRECTORY` 指定），`~/.config/kitty/` 是同内容的备用配置。
  两处都去掉了 `/home/<user>` 硬编码。
- `ghostty/config`：`JetBrainsMono Nerd Font Mono`。
- `cava/config` + `cava/shaders/` + `cava/themes/`：自定义频谱配置和着色器。
- `ags/user/style.css`：wallust 颜色路径修正为
  `~/.config/hypr/waybar/wallust/colors-waybar.css`（原来指向已不存在的
  `~/.config/waybar/`）。

## 桌面集成

- `systemd/user/hyprland-monitor-config-reload.{path,service}`：显示器配置热重载。
- `systemd/user/waybar.service`：**重新启用**的完整 unit（不再是 `-> /dev/null`）。
  `graphical-session.target.wants/waybar.service` 使用相对软链，登录后由
  systemd 启动；`waybar.service.d/override.conf` 把 `ExecStart` 指向
  `~/.config/hypr/waybar/{config,style.css}`。`WaybarStartup.sh` 不再负责启动。
- `systemd/user/*.service.d/override.conf`：portal / polkit 的启动顺序覆盖。
- `gtk-3.0/settings.ini`、`gtk-4.0/settings.ini`：Flat-Remix GTK、Flat-Remix 图标、
  Bibata 光标、Fira Code 14。
- `nwg-look/`：GTK 外观设置。`qt5ct/`、`qt6ct/`、`Kvantum/` 与上游完全一致，
  因此不放进 overlay，避免冻结上游更新。
- `environment.d/90-fcitx5.conf`：fcitx5 输入法环境变量。
- `fcitx5/`：输入法全局设置与输入法组（`rime` + `windinput`，默认
  `windinput`）。**不包含** `~/.config/fcitx5/conf/cached_layouts` 缓存。
- `WindInput/`：清风输入法的用户设置（方案 `shuangpin`、按键动作等）。
  **不包含** `data/` 用户词库/短语；`~/.local/share/fcitx5/rime`（约 211MB）
  也属于用户数据，需要时从旧盘单独复制。
- `autostart/`、`mimeapps.list`、`user-dirs.dirs`、`pavucontrol.ini`。

## Shell

- `.zshrc`：oh-my-zsh + starship + pokemon-colorscripts + fastfetch + lsd；
  已把 `/home/<user>/.opencode/bin` 改成 `$HOME`，linuxbrew 改为存在才加载。
- `.zprofile`、`.tmux.conf`。

## 有意没有带过来的差异

| 上游文件 | 处理方式 | 原因 |
|---|---|---|
| `hypr/lua/settings.lua` 的其余内容 | 跟随上游；只在 overlay 里整文件 override 以删除废弃项 | `no_hardware_cursors` 等可覆盖项仍写在 `user_settings.lua` |
| `hypr/scripts/MonitorWatcher.sh` | 暂不启动 | 与现有 `monitors.lua`（nwg-displays）冲突，迁移后再启用 |
| `hypr/scripts/keybinds_parser.py` | v2.3.28 已删除，改用 `lua/keybind_index.lua` | 上游重构 |
| `hypr/lua/keybinds.lua`、`keybind_helpers.lua` | v2.3.28 已删除 | 上游重构为 `window_actions.lua` |
| `hypr/monitors.conf` | 不进仓库，提供 `docs/monitors.md` | 显示器输出名/分辨率因机器而异 |
| `hypr/workspaces.conf`、`UserConfigs/workspaces.lua` | 不进仓库（已加入 `.gitignore`） | 都由 `PersistWorkspaceLayout.sh` 按当前显示器运行时生成 |
| `wallust-*.conf`、`colors-*.{css,rasi}`、`qml_color.json` | 不进仓库 | wallust 根据当前壁纸生成 |
| `hypr/rofi/.current_wallpaper*`、`wallpaper_effects/` | 不进仓库 | 运行时状态 |
| `kitty-themes/`、`fastfetch/`、`wlogout/`、`qt5ct/`、`qt6ct/`、`Kvantum/` 等 | 跟随上游 | 与上游完全一致，没必要重复保存 |
| `ags/`（除 `user/style.css`） | 跟随上游 | 只有颜色路径需要修正 |

## 升级记录

### 2026-11-03 — 与运行中系统对齐

- `hypridle.conf`：同步系统当前的改动，注释掉自动关屏 DPMS listener。
- `systemd/user/waybar.service`：系统已在 2026-11-01 重新启用 systemd 服务，
  overlay 从 `-> /dev/null` 改为真实 unit，并加入相对软链
  `graphical-session.target.wants/waybar.service`。
- `workspaces.lua`：系统当前为空且由 `PersistWorkspaceLayout.sh` 生成，
  从 overlay 移除并加入 `.gitignore`；`capture.sh` 同步排除。
- 新增 `fcitx5/`、`WindInput/` 用户配置（排除缓存和词库数据）。
- `capture.sh`：修复“目标已是软链时无法覆盖”、错误地把上游文件带进
  `UserConfigs`、以及绝对 `$HOME` 软链不可移植的问题。

### 2026-10-29 — v2.3.27.7 → v2.3.28

- 全量同步上游 `config/` 系统文件（`lua/`、`configs/`、`scripts/`、`waybar/` 等）。
- 删除上游已移除的文件：`LuaAutoReload.sh`、`LuaCycleWindow.sh`、
  `LayoutKeybindDispatch.sh`、`keybinds_parser.py`、`lua/keybinds.lua`、
  `lua/keybind_helpers.lua` 等。
- `user_keybinds.lua` 迁移到 v2.3.28 结构，保留个人 ALT 快捷键。
- `user_laptops.lua`、`user_decorations.lua` 改用上游 v2.3.28 实现。
- `user_startup.lua` 合并上游 `MonitorWatcher.sh` 逻辑，但按上面的原因暂时不启用。
- 备份：`~/.config-backup-20261029-180533/hypr-config.tar.gz`（升级前）、
  `~/.config-backup-20261029-180723/`（应用 overlay 前）。
- `hyprctl configerrors` 为空，Waybar 已重启并正常运行。
