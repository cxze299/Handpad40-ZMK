# Handpad20 ZMK Firmware

Handpad20 是一套面向 E73/nRF52840 自制 4x10 键盘的 ZMK 固件。

支持 USB、蓝牙、ZMK Studio、Office/Game 布局、UF2 更新和 J-Link/SWD
裸烧。硬件接线、键位和使用说明见 [README_CN.md](README_CN.md)。

## Windows 一键部署与构建

首次使用时，在仓库根目录双击：

```text
一键部署并构建.cmd
```

它会自动完成：

1. 检查并安装 Git、Python 3.11。
2. 创建独立 Python 虚拟环境。
3. 下载固定版本 ZMK `v0.3.0`。
4. 下载 ZMK 所需的 west/Zephyr 模块。
5. 下载 Zephyr SDK `0.16.3`。
6. 构建带蓝牙和 ZMK Studio 的 UF2。

输出文件：

```text
firmware/handpad20_studio_uf2.uf2
```

首次部署需要下载数 GB 内容，请保持网络稳定。

## PowerShell 用法

如果 PowerShell 禁止执行脚本，可以在当前终端运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

仅部署环境：

```powershell
.\scripts\setup.ps1
```

构建 Studio UF2：

```powershell
.\scripts\build.ps1 -Target Studio
```

构建 SWD HEX：

```powershell
.\scripts\build.ps1 -Target SWD
```

同时构建 UF2 和 SWD：

```powershell
.\scripts\build.ps1 -Target All
```

强制重新安装本地工作区：

```powershell
.\scripts\setup.ps1 -Force
```

详细环境说明见 [Windows 从零构建指南](docs/BUILD_WINDOWS_CN.md)。

## 发布到 GitHub

安装并登录 GitHub CLI 后：

```powershell
winget install --id GitHub.cli
gh auth login
.\scripts\publish-github.ps1 -Repository Handpad20-ZMK -Visibility public
```

脚本会创建或使用现有的 `origin`，提交源码并推送。大型本地依赖和固件
产物由 `.gitignore` 排除。

## 固定版本

为了保证当前自定义 board、ZMK Studio 和 nanopb 可以重复构建，本仓库固定：

```text
ZMK             v0.3.0
Zephyr          v3.5.0+zmk-fixes
Zephyr SDK      0.16.3
west            1.5.0
setuptools      80.9.0
```

不要直接将 ZMK 切换到 `main`。新版 ZMK 使用更新的 Zephyr 和 SDK，可能需要
同步迁移自定义 board、设备树和 Studio 配置。

## 主要文件

```text
boards/                         自定义 E73 board 和 handpad20 shield
config/handpad20_studio.keymap  最终键位和蓝牙功能
scripts/setup.ps1               环境部署
scripts/build.ps1               统一构建入口
一键部署并构建.cmd               Windows 一键入口
README_CN.md                    完整键盘说明
```
# Handpad40-ZMK
