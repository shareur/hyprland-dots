# 跟随上游更新

上游仓库：[LinuxBeginnings/Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)
当前锁定版本见 [`upstream.lock`](../upstream.lock)。

本仓库的定位是 **overlay**：

- 上游负责：`hypr/` 的系统文件、`lua/`、`configs/`、`scripts/`、默认 `UserConfigs` 模板、其他应用默认配置。
- 本仓库负责：`UserConfigs/`、`UserScripts/`、个人额外文件、外观/输入法/终端配置。
- 上游的 `copy.sh` 明确会保留 `UserConfigs/` 和 `UserScripts/`，所以升级不会冲掉个人配置。

## 一、只更新运行中的系统

如果只是想让当前机器用上上游新版本：

```bash
git clone --depth=1 https://github.com/LinuxBeginnings/Hyprland-Dots.git ~/Hyprland-Dots
cd ~/Hyprland-Dots
./copy.sh --express-upgrade
```

或者继续使用上游的 TUI 安装器 / 更新菜单。

升级完成后重新应用一次个人覆盖层，确保 override 文件没有被覆盖：

```bash
cd ~/Projects/hyprland-dots
./install.sh
./doctor.sh
```

## 二、同时更新仓库锁定的基础版本

```bash
cd ~/Projects/hyprland-dots
./update.sh                          # 自动取最新 release
./update.sh Hyprland-Dots-v2.3.28    # 或指定 tag
```

`update.sh` 只修改 `upstream.lock`，不会动系统。之后按上面的步骤更新系统并
重新应用 overlay。

## 三、升级后重点检查的文件

这些是**完整覆盖上游**的文件，上游改了它们时不会自动合并：

- `overlay/.config/hypr/hyprlock.conf`
- `overlay/.config/hypr/hypridle.conf`

升级后建议对比一下：

```bash
git -C ~/Hyprland-Dots show HEAD:config/hypr/hyprlock.conf > /tmp/upstream-hyprlock.conf
diff -u /tmp/upstream-hyprlock.conf overlay/.config/hypr/hyprlock.conf
```

## 四、不要把上游文件复制进本仓库

以下内容属于上游或运行时生成，已在 `.gitignore` 中排除：

- `wallust-hyprland.conf`、`colors-*.css/.rasi`、`qml_color.json`
- `wallpaper_effects/`、`.current_wallpaper*`
- `monitors.conf`（机器相关）
- `hypr/UserConfigs/kitty-themes/01-Wallust.conf`

如果确实需要修改上游文件，优先用 `UserConfigs/user_*.lua` 覆盖；
只有当配置项没有用户覆盖入口时，才把整个文件放进 `overlay/` 并在
[`personal-changes.md`](personal-changes.md) 里记一笔。
