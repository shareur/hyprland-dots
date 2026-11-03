# 已知问题 / 未解决

本文件记录当前仍存在、但暂不处理的问题。每条都保留测量数据和已经试过的
方向，避免以后重复排查。

---

## 1. 开机到登录界面、登录到桌面各有一段黑屏（未解决）

**状态：** 未解决，暂不修复。属于观感问题，不影响登录和桌面使用。

### 现象

- 从 Plymouth 启动画面结束到 SDDM 登录界面出现，中间有约 **4.3 秒**纯黑屏。
- 输入密码登录后到 Hyprland 桌面完全显示（状态栏 + 壁纸），中间有约
  **2 ～ 3 秒**黑屏。Hyprland 第一帧前约 1.5 秒是纯黑；之后状态栏等已经出现，
  但背景在壁纸应用前（约 2.8 秒）仍是黑色。
- 两段都是稳定复现，不是偶发。安装 Hyprland 后开始出现，升级/重配后仍在。

### 环境

| 项目 | 值 |
|---|---|
| 系统 | Ubuntu 26.04 LTS |
| 显示管理器 | SDDM，`DisplayServer=x11`，主题 `simple_sddm_2` |
| 桌面 | Hyprland 0.57.0（`start-hyprland`，非 uwsm） |
| 显卡 | NVIDIA RTX 5060 Ti，驱动 595.99.02（open kernel module） |
| 显示器 | Acer VG270 S3，HDMI，1920x1080@120Hz |
| 内核 | 7.0.0-42-generic |

### 测量结果

数据来自 `2026-11-03 19:46` 这次启动（boot `c803913c`），日志均为
`journalctl -b -o short-precise` 的真实时间。

#### 第一段：Plymouth → SDDM 登录界面

| 事件 | 时间 | 距 Plymouth 退出 |
|---|---|---|
| `plymouth-quit.service` 完成 | 19:46:38.257 | 0 |
| SDDM `Display server started` | 19:46:40.664 | +2.41s |
| Qt 登录界面加载 `Main.qml` | 19:46:41.121 | +2.86s |
| 登录界面首帧 `Adding view for "HDMI-0"` | 19:46:42.522 | **+4.27s** |

- 实测黑屏：**约 4.3 秒**。
- 历史启动（boot -5 ～ 0，共 6 次）同一区间为 **4.26 ～ 4.44 秒**，非常稳定。
- Xorg 日志显示这段主要花在：NVIDIA 驱动匹配约 1 秒、读取显示器并设置
  `1920x1080_120` 约 1 秒，Xorg 初始化合计约 2.3 秒；随后 Qt6 greeter 启动并
  渲染首帧约 1.9 秒。

#### 第二段：输入密码 → Hyprland 桌面

| 事件 | 时间 | 距认证成功 |
|---|---|---|
| SDDM `Authentication ... successful` | 19:47:17.850 | 0 |
| greeter 退出、Wayland session 启动 | 19:47:18.06 ～ 18.10 | +0.21 ～ 0.25s |
| Hyprland 实例目录建立 | 19:47:18.466 | +0.62s |
| Hyprland IPC socket 就绪 | 19:47:19.441 | +1.59s |
| `waybar.service` 启动 | 19:47:19.923 | **+2.07s** |
| 壁纸软链更新（`rofi/.current_wallpaper`） | 19:47:20.647 | +2.80s |
| wallust 配色模板写完 | 19:47:20.703 | +2.85s |

- 纯黑屏约 **1.3 ～ 1.6 秒**，到 Hyprland 开始出画面为止。
- 状态栏出现约 **2.1 秒**，壁纸正常显示约 **2.8 秒**。
- 最近两次启动（boot -1、0）从认证到 Waybar 分别为 2.15 秒、2.07 秒，
  结果一致。
- Hyprland 日志没有报错；aquamarine 正常枚举 `/dev/dri/card1`、创建 GL
  renderer，并按 `1920x1080@120Hz` 完成 modeset。

### 诊断结论

1. **第一段黑屏是 SDDM 的 X11 greeter 启动时间，不是启动失败。**
   Plymouth 退出时 Xorg / greeter 还没准备好：Xorg 还要约 2.4 秒完成 NVIDIA
   初始化并建立显示，Qt6 greeter 再花约 1.9 秒渲染首帧。日志中没有错误或
   重试，属于顺序上的空档。

2. **第二段黑屏是 Xorg greeter（VT2）切换到 Hyprland（VT1）的合成器首帧延迟。**
   认证后 SDDM 很快关闭 greeter 并启动 Hyprland；Hyprland 需要初始化
   aquamarine/NVIDIA DRM、创建 GL renderer 并完成 modeset，约 1.5 秒后才出
   第一帧。之后 Waybar 和壁纸再分别启动，所以“完全正常”约 2.8 秒。

3. **与更早的固件/引导阶段无关。**
   `systemd-analyze time` 显示 firmware 29.4 秒、loader 7.4 秒、kernel 2.9 秒、
   initrd 4.7 秒；这些是 BIOS/GRUB/内核阶段，不计入上面两段。另有一段
   `simpledrm` → `nvidia-drm` 的 framebuffer 交接（约 2.4 秒）可能造成开机早期
   的短暂黑屏，但发生在 Plymouth 出现之前，和登录界面这两段不是同一问题。

### 已经试过、但没有解决的方向

以下记录来自同机的 Ubuntu 运维项目（本仓库之外，路径
`/data/Projects/Ubuntu`）。这些修复目前大多已经生效，但两段黑屏仍然存在，
所以不要再把同一批改动当成新方案重复实施。

- **`docs/207-login-desktop-transition.md`**
  - 安装 Qt6 SVG 插件（本机已安装 `qt6-svg-plugins`）。
  - 把 `~/.profile` 的 `source /etc/profile` 改成 `. /etc/profile`（本机已改）。
  - Hyprland 启动命令从 `sh -lc` 改成 `sh -c`，避免重复初始化 `im-config`
    （本机启动 helper 已使用 `sh -c`）。
  - 只保留一个 `hypridle`，由 systemd user service 管理（本机已是一个实例）。
  - DPMS 恢复后重贴壁纸、修复 `color: 000000`。
  - 结论：这些改动减少了启动日志错误和“黑壁纸”，但没有消除两段黑屏时间。

- **`docs/304-sddm-wayland-greeter.md`**
  - 试过 SDDM Wayland greeter + weston，想绕开 Xorg greeter。
  - 2026-09-14 验证后回滚：对登录黑屏时间没有实质改善，当前仍为
    `DisplayServer=x11`。

- **`docs/305-display-1080p120-test.md`**
  - 试过让 SDDM greeter 与 Hyprland 都使用 1920x1080@120Hz，排除模式切换
    导致显示器重新同步。
  - 当前 Xorg 日志里 greeter 确实已设为 `1920x1080_120`，Hyprland 也是
    119.997Hz，但黑屏仍在。

- **`docs/311-early-nvidia-dracut.md`**
  - 试过在 initramfs 早期加载 NVIDIA 模块，解决 framebuffer 交接的花屏/残帧。
  - 本机内核命令行已带 `rd.driver.pre=nvidia*`，NVIDIA 在启动早期加载。
  - 该问题针对的是交接瞬间的残帧，不是 SDDM/登录延迟。

### 复现和取证命令

```bash
# 第一段：Plymouth 退出到登录界面首帧
journalctl -b -o short-precise | grep -E \
  'plymouth-quit.service|sddm.service|Display server started|Adding view for'

# 第二段：认证成功到 Hyprland、Waybar、壁纸
journalctl -b -o short-precise | grep -E \
  'Authentication for user.*successful|Wayland user session|Started waybar.service'
stat -c '%y %n' ~/.config/hypr/rofi/.current_wallpaper \
  ~/.cache/wallust/wallust-swww.log

# 合成器和模式信息
hyprctl monitors
systemd-analyze time
```

### 暂不修复的原因

- 两段都是数秒级的观感问题，登录和桌面功能正常，没有服务失败或数据风险。
- 之前在 Ubuntu 项目里尝试过 Wayland greeter、120Hz 同步、启动脚本和
  hypridle 清理，均未实际缩短这两段黑屏，继续改动的收益不明确。
- 若以后要再处理，建议先确认 NVIDIA 驱动/SDDM/Hyprland 版本是否有变化，
  再重新测量上面的时间点，不要直接套用旧脚本。
