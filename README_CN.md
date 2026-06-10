# Handpad20 ZMK 固件

这是为 E73-2G4M08S1C / nRF52840 主控和两块相同 4x5 PCB 编写的
Handpad20 固件。左侧 PCB 安装主控，右侧 PCB 作为无主控被动矩阵，
组合后形成 4 行 10 列、共 40 键的键盘。

## 快速开始

新的 Windows 电脑直接双击仓库根目录的：

```text
一键部署并构建.cmd
```

脚本会安装或配置 Git、Python、west、ZMK `v0.3.0` 和 Zephyr SDK
`0.16.3`，最后生成：

```text
firmware/handpad20_studio_uf2.uf2
```

详细步骤见 [Windows 从零构建指南](docs/BUILD_WINDOWS_CN.md)。

固件支持：

- USB HID 键盘
- Bluetooth Low Energy 键盘
- 5 个蓝牙主机配置
- ZMK Studio 在线改键
- Office 和 Game 两套布局
- UF2 拖拽更新
- J-Link / SWD 烧录
- Studio 配置掉电保存

## 硬件连接

矩阵二极管方向为 `col2row`。

左侧 PCB 本地按键使用主控的 `COL12` 到 `COL16`。右侧被动 PCB 的
5 个按键列连接如下：

```text
主控 COL7  -> 右板 COL12
主控 COL8  -> 右板 COL13
主控 COL9  -> 右板 COL14
主控 COL10 -> 右板 COL15
主控 COL11 -> 右板 COL16
```

行线一一对应：

```text
主控 ROW1 -> 右板 ROW1
主控 ROW2 -> 右板 ROW2
主控 ROW3 -> 右板 ROW3
主控 ROW4 -> 右板 ROW4
```

GPIO 定义：

```text
ROW1 = P0.02
ROW2 = P1.13
ROW3 = P0.28
ROW4 = P0.03

COL7  = P0.17
COL8  = P0.20
COL9  = P0.13
COL10 = P0.22
COL11 = P0.24
COL12 = P1.00
COL13 = P1.04
COL14 = P0.09
COL15 = P1.06
COL16 = P0.10
```

左右两块 PCB 都必须安装方向正确的矩阵二极管。

## 键位布局

### Office

```text
Q      W    E    R    T      Y      U    I    O     P
A      S    D    F    G      H      J    K    L     Backspace
Shift  Z    X    C    V      B      N    M    Caps  Enter
Ctrl   GUI  Alt  Esc  Space  .      '    ;    Del   Fn
```

### Game

```text
Esc    Q    W    E    R      T      Y    U    I    O
Tab    A    S    D    F      G      H    J    K    L
Shift  Z    X    C    V      B      N    M    M    Enter
Ctrl   Del  GUI  Alt  Space  Space  .    '    Del  Fn
```

## Fn 功能

Office 和 Game 均使用右下角按键作为 `Fn`。

| 组合键 | 功能 |
| --- | --- |
| `Fn + Q` | 选择蓝牙配置 1 |
| `Fn + W` | 选择蓝牙配置 2 |
| `Fn + E` | 选择蓝牙配置 3 |
| `Fn + R` | 选择蓝牙配置 4 |
| `Fn + T` | 选择蓝牙配置 5 |
| `Fn + B` | 将键盘输出切换到蓝牙 |
| `Fn + Space` | 将键盘输出切换到 USB |
| `Fn + Esc` | 解锁 ZMK Studio，锁定功能启用时使用 |

布局切换：

```text
Office -> Game：Fn + G
Game -> Office：Fn + G
```

由于两层中 `G` 的物理位置不同，应按当前层中标记为 `G` 的按键。

清除当前蓝牙配置：

```text
Office：Fn + Backspace
Game：Fn + Del
```

Game 层有两个 `Del`，两个位置都可以清除当前蓝牙配对。

## 蓝牙配对

首次连接电脑：

1. 按 `Fn + Q` 选择蓝牙配置 1。
2. 按 `Fn + B` 切换到蓝牙输出。
3. 在 Windows 打开“设置 -> 蓝牙和设备 -> 添加设备 -> 蓝牙”。
4. 选择键盘名称并完成配对。

连接第二台设备时，使用 `Fn + W` 选择配置 2，然后重复配对流程。
最多可以保存 5 台主机。

如果 Windows 能看到键盘但无法连接：

1. 在 Windows 中删除或忘记该键盘。
2. 选择对应配置，例如按 `Fn + Q`。
3. 按 `Fn + Backspace` 清除键盘中当前配置的配对记录。
4. 等待数秒后重新搜索并配对。

电脑端和键盘端的旧配对记录必须同时清除，否则双方安全密钥不一致，
会反复连接失败。

蓝牙配置、所选主机和所选输出端点会保存在 nRF52840 内部 Flash 中，
掉电后不会丢失。

## ZMK Studio

使用 Chrome、Edge 或 ZMK Studio 桌面程序连接：

1. 使用 USB 连接键盘。
2. 按 `Fn + Space`，确保输出端点为 USB。
3. 打开 <https://zmk.studio/>。
4. 选择键盘对应的 USB 串口。

当前 Studio 构建关闭了 Studio 锁定，因此通常无需按解锁键。如果以后
启用 `CONFIG_ZMK_STUDIO_LOCKING`，使用 `Fn + Esc` 解锁。

Studio 中修改后点击保存，等待至少 2 到 3 秒再断电。固件将修改写入
内部 Flash 的 settings/NVS 分区。

Studio 修改不会自动写回 `.keymap` 或 UF2。需要批量复制到其他键盘时，
应将最终键位人工同步到：

```text
config/handpad20_studio.keymap
```

然后重新编译并给其他键盘烧录相同 UF2。

如果烧录了新的源码键位，但设备仍显示旧的 Studio 键位，请在 Studio
中执行 `Restore Stock Settings`。Studio 的持久化设置优先于源码默认值。

## 编译 Studio UF2

打开 PowerShell：

```powershell
Set-Location <仓库目录>
.\scripts\build.ps1 -Target Studio
```

生成文件：

```text
firmware/handpad20_studio_uf2.uf2
```

脚本会自动：

- 激活 Studio overlay 和 Studio keymap
- 启用 `studio-rpc-usb-uart`
- 启用 ZMK Studio
- 将 settings 写入延迟设为 1 秒
- 生成带固定名称的 UF2

## UF2 烧录

1. 双击复位键，让键盘进入 UF2 U 盘模式。
2. 将以下文件复制到 UF2 U 盘：

```text
firmware/handpad20_studio_uf2.uf2
```

3. U 盘会自动弹出，键盘重新启动。

如果烧录后 Studio 仍显示旧设置，在 Studio 中执行
`Restore Stock Settings`。

## SWD / J-Link

构建 SWD 版本：

```powershell
Set-Location <仓库目录>
.\scripts\build.ps1 -Target SWD
```

查找生成的 HEX：

```powershell
Get-Item .\firmware\handpad20_swd.hex
```

J-Link Commander 常用命令：

```text
device NRF52840_XXAA
if SWD
speed 4000
r
loadfile D:\完整路径\zmk.hex
r
g
exit
```

UF2 固件是为已经存在 UF2 bootloader 的设备生成的。通过 SWD 裸烧时，
应使用 `build-swd.ps1` 生成的 SWD 版本，不要把 UF2 文件当作裸机 HEX。

## 修改键盘名称

编辑：

```text
boards/shields/handpad20/Kconfig.defconfig
```

修改：

```kconfig
config ZMK_KEYBOARD_NAME
    default "Handpad20"
```

蓝牙名称可能被 Windows 缓存。改名后应在 Windows 中删除旧设备，并清除
键盘当前蓝牙配置后重新配对。

## 主要源文件

```text
boards/shields/handpad20/handpad20_studio.overlay
boards/shields/handpad20/handpad20_layouts.dtsi
config/handpad20_studio.keymap
scripts/build-studio-uf2.ps1
boards/arm/e73_handpad40_uf2/e73_handpad40_uf2.dts
```

## 常见问题

### USB 正常，但蓝牙没有按键输出

按 `Fn + B` 切换到 BLE 输出。ZMK 允许 USB 只负责供电，而按键输出到蓝牙。

### Studio 无法连接

- 确认烧录的是 `handpad40_zmk_studio.uf2`
- 确认 Windows 中出现 USB 串口
- 按 `Fn + Space` 切换到 USB 输出
- 使用 Chrome、Edge 或 Studio 桌面程序

### Studio 修改掉电后消失

- 修改后点击保存
- 等待至少 2 到 3 秒再断电
- 确认没有启用 `CONFIG_ZMK_SETTINGS_RESET_ON_START`
- 确认 Flash 中存在有效的 storage 分区

### 新源码键位没有生效

Studio 的持久化键位会覆盖源码默认键位。在 Studio 中执行
`Restore Stock Settings` 后重新检查。
