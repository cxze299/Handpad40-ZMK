# Windows 从零搭建 ZMK 环境

本文说明如何在一台新的 Windows 10/11 电脑上部署 Handpad20 的 ZMK
编译环境，并生成 UF2 或 SWD HEX。

## 1. 系统要求

- Windows 10 或 Windows 11，64 位
- 至少 15 GB 可用空间
- 稳定的 GitHub 网络连接
- Windows App Installer 提供的 `winget`
- PowerShell 5.1 或更高版本

部署脚本会优先使用 Python 3.11。若系统没有 Git 或 Python，默认通过
`winget` 自动安装。

## 2. 获取固件仓库

安装 Git 后，使用仓库实际地址执行：

```powershell
git clone https://github.com/<你的用户名>/<仓库名>.git
Set-Location <仓库名>
```

也可以下载 GitHub ZIP 并解压，但使用 Git 更方便后续更新。

路径中可以包含中文和空格；不过为了减少第三方工具兼容问题，推荐使用：

```text
D:\Handpad20-ZMK
```

## 3. 一键部署并构建

最简单的方法是双击：

```text
一键部署并构建.cmd
```

或者在 PowerShell 中运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\一键部署并构建.ps1 -Target Studio
```

脚本将执行：

1. 安装或检查 Git 和 Python。
2. 创建 `zmk-work/.venv`。
3. 安装 west、CMake、Ninja 和 Python 依赖。
4. 克隆 ZMK `v0.3.0`。
5. 执行 `west init`、`west update`、`west zephyr-export`。
6. 下载并解压 Zephyr SDK `0.16.3`。
7. 构建 Studio UF2。

生成文件：

```text
firmware/handpad20_studio_uf2.uf2
```

## 4. 分步部署

只安装环境，不构建：

```powershell
.\scripts\setup.ps1
```

可选参数：

```powershell
# 删除并重新创建 venv、ZMK 源码和 SDK
.\scripts\setup.ps1 -Force

# Git/Python 已经手动安装
.\scripts\setup.ps1 -SkipPrerequisites

# Zephyr SDK 已经放在 zephyr-sdk/zephyr-sdk-0.16.3
.\scripts\setup.ps1 -SkipSdk
```

部署完成后的目录：

```text
仓库根目录/
  zmk-work/
    .venv/
    zmk/
    zephyr/
    modules/
  zephyr-sdk/
    zephyr-sdk-0.16.3/
```

这些目录体积很大，已经被 `.gitignore` 排除，不应上传 GitHub。

## 5. 构建固件

### Studio UF2

```powershell
.\scripts\build.ps1 -Target Studio
```

输出：

```text
firmware/handpad20_studio_uf2.uf2
```

该版本包含：

- USB HID
- Bluetooth Low Energy
- ZMK Studio USB 串口
- Office/Game 布局
- 5 个蓝牙配置
- settings/NVS 掉电保存

### UF2

```powershell
.\scripts\build.ps1 -Target UF2
```

输出：

```text
firmware/handpad20_uf2.uf2
```

当前 UF2 目标仍保留 ZMK Studio 和蓝牙功能。

### SWD HEX

```powershell
.\scripts\build.ps1 -Target SWD
```

输出：

```text
firmware/handpad20_swd.hex
```

该 HEX 从地址 `0x00000000` 开始，供 J-Link/SWD 裸烧使用。

### 同时构建

```powershell
.\scripts\build.ps1 -Target All
```

## 6. UF2 烧录

1. 双击键盘复位键，进入 UF2 U 盘。
2. 将 `firmware/handpad20_studio_uf2.uf2` 复制到 U 盘。
3. U 盘自动弹出后等待键盘重新连接。

UF2 版本依赖键盘中已经存在兼容 bootloader。不要把 UF2 文件交给
J-Link Commander。

## 7. J-Link/SWD 烧录

J-Link Commander：

```text
device NRF52840_XXAA
if SWD
speed 4000
r
loadfile D:\Handpad20-ZMK\firmware\handpad20_swd.hex
r
g
exit
```

使用 Nordic `nrfjprog`：

```powershell
nrfjprog --family NRF52 --recover
nrfjprog --family NRF52 --program .\firmware\handpad20_swd.hex --verify
nrfjprog --family NRF52 --reset
```

`--recover` 会擦除整片 Flash，包括 bootloader、蓝牙配对和 Studio 设置。

## 8. 修改键位

源码键位：

```text
config/handpad20_studio.keymap
```

修改后重新构建：

```powershell
.\scripts\build.ps1 -Target Studio
```

如果键盘以前被 ZMK Studio 修改过，芯片中的 Studio 设置会覆盖新源码。
烧录后打开 Studio，执行 `Restore Stock Settings`。

## 9. 修改设备名称

编辑：

```text
boards/shields/handpad20/Kconfig.defconfig
```

修改 `ZMK_KEYBOARD_NAME`，然后重新构建。Windows 可能缓存旧蓝牙名称，
需要同时删除电脑端和键盘端的旧配对。

## 10. 常见错误

### `pkg_resources` 不存在

本仓库固定 `setuptools==80.9.0`。重新运行：

```powershell
.\scripts\setup.ps1
```

### `ZEPHYR_EXTRA_MODULES` 显示 `D:` 无效

通常是手工命令把路径写成了：

```text
D: /目录
```

使用本仓库的构建脚本可以避免 PowerShell 路径拆分问题。

### 找不到 Zephyr SDK

确认目录存在：

```text
zephyr-sdk/zephyr-sdk-0.16.3
```

然后重新执行：

```powershell
.\scripts\setup.ps1
```

### Studio 修改重启后消失

在 Studio 点保存后等待 2 到 3 秒再拔电。当前构建将 settings 写入延迟
设置为 1 秒。

## 11. 更新仓库

```powershell
git pull
.\scripts\setup.ps1
.\scripts\build.ps1 -Target Studio
```

不要直接在 `zmk-work/zmk` 中执行 `git pull` 升级 ZMK。项目固定在
`v0.3.0`，任意升级都可能需要迁移设备树和自定义 board。
