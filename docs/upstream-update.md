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

## 五、手动同步方式（2026-10-29 实际采用）

如果不想跑上游的交互式 `copy.sh`，可以手动同步，步骤可控：

```bash
REF=Hyprland-Dots-v2.3.28
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-dots/upstream-$REF"

git clone --depth 1 --branch "$REF" --filter=blob:none --sparse \
  https://github.com/LinuxBeginnings/Hyprland-Dots.git "$CACHE"
git -C "$CACHE" sparse-checkout set config

# 先备份
tar -czf "$HOME/hypr-config-$(date +%Y%m%d-%H%M%S).tar.gz" \
  "$HOME/.config/hypr" "$HOME/.config/kitty" "$HOME/.config/ghostty"

# 同步上游，保留 wallust/运行时生成文件
rsync -a \
  --exclude 'hypr/wallust/wallust-hyprland.conf' \
  --exclude 'hypr/rofi/wallust/colors-rofi.rasi' \
  --exclude 'hypr/waybar/wallust/colors-waybar.css' \
  --exclude 'hypr/UserConfigs/kitty-themes/01-Wallust.conf' \
  --exclude 'hypr/wallpaper_effects/' \
  --exclude 'quickshell/qml_color.json' \
  --exclude 'nwg-dock-hyprland/wallust/colors-wallust.css' \
  "$CACHE/config/" "$HOME/.config/"

# 恢复个人覆盖层
cd ~/Projects/hyprland-dots && ./install.sh

# 清理上游删除的文件（按两个 tag 的 diff 列出 D 项）
git -C "$CACHE" diff --name-status "$OLD_REF" "$REF" -- config/hypr | grep '^D'

hyprctl reload
hyprctl configerrors
```

本次升级已删除的旧文件包括：`LuaAutoReload.sh`、`LuaCycleWindow.sh`、
`LayoutKeybindDispatch.sh`、`keybinds_parser.py`、`lua/keybinds.lua`、
`lua/keybind_helpers.lua` 等。
