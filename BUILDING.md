# 本地搭建 ZMK 编译环境和编译 Handpad20

以下步骤按 Windows + PowerShell 写。

## 0. 更简单的方式

如果你只是想拿到固件，不一定要本地搭环境。把这个仓库推到 GitHub 后，GitHub Actions 会自动编译。

这个仓库现在同时支持两种产物：

- SWD 裸烧：`e73_handpad40 + handpad20`，产物是 `zmk.hex`。
- UF2 拖拽：`nice_nano_v2 + handpad20`，产物是 `zmk.uf2`。

## 1. 需要安装的软件

先安装这些：

1. Git for Windows
2. Python 3.11 或 3.12
3. CMake
4. Ninja
5. Zephyr SDK
6. Nordic nRF Command Line Tools
7. SEGGER J-Link Software

推荐按 ZMK 官方 Native Toolchain 文档走一遍。

## 2. 准备工作目录

建议不要把 ZMK 主仓库直接放进这个配置仓库里。比如这样：

```powershell
mkdir D:\ZMK_Firmware_cxze\zmk-work
cd D:\ZMK_Firmware_cxze\zmk-work
```

## 3. 创建 Python 虚拟环境

```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install west
```

如果 PowerShell 不允许激活虚拟环境，先执行一次：

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## 4. 拉取 ZMK

```powershell
git clone --branch v0.3 https://github.com/zmkfirmware/zmk.git D:\ZMK_Firmware_cxze\zmk-work\zmk
cd zmk
west init -l app
west update
west zephyr-export
pip install -r zephyr\scripts\requirements.txt
```

## 5. 编译 SWD 裸烧 hex

如果编译时报：

```text
Could not find a package configuration file provided by "Zephyr-sdk"
```

说明 Zephyr SDK 还没有安装，或者没有被 CMake 找到。

你现在用的 ZMK `v0.3` 拉到的是 Zephyr `3.5.0`，推荐安装 Zephyr SDK `0.16.3`。

下载 Windows 版 SDK：

```text
https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.3/zephyr-sdk-0.16.3_windows-x86_64.7z
```

解压到：

```text
D:\ZMK_Firmware_cxze\zephyr-sdk\zephyr-sdk-0.16.3
```

进入目录运行一次安装脚本：

```powershell
cd D:\ZMK_Firmware_cxze\zephyr-sdk\zephyr-sdk-0.16.3
.\setup.cmd
```

然后在当前 PowerShell 里设置 SDK 路径：

```powershell
$env:ZEPHYR_TOOLCHAIN_VARIANT = "zephyr"
$env:ZEPHYR_SDK_INSTALL_DIR = "D:/ZMK_Firmware_cxze/zephyr-sdk/zephyr-sdk-0.16.3"
```

如果想永久保存环境变量，可以执行：

```powershell
[Environment]::SetEnvironmentVariable("ZEPHYR_TOOLCHAIN_VARIANT", "zephyr", "User")
[Environment]::SetEnvironmentVariable("ZEPHYR_SDK_INSTALL_DIR", "D:/ZMK_Firmware_cxze/zephyr-sdk/zephyr-sdk-0.16.3", "User")
```

执行后重新打开一个 PowerShell，让永久环境变量生效。

这个配置仓库路径是：

```text
D:\ZMK_Firmware_cxze
```

在 `D:\ZMK_Firmware_cxze\zmk-work\zmk` 目录里执行：

```powershell
west build -p always -d build\handpad40_swd -b e73_handpad40 app -- -DSHIELD=handpad20 "-DZMK_CONFIG=D:/ZMK_Firmware_cxze/config" "-DZMK_EXTRA_MODULES=D:/ZMK_Firmware_cxze"
```

编译成功后，固件通常在：

```text
D:\ZMK_Firmware_cxze\zmk-work\zmk\build\handpad40_swd\zephyr\zmk.hex
```

这个 `.hex` 可以用 J-Link / nrfjprog 烧录。

也可以直接运行脚本：

```powershell
D:\ZMK_Firmware_cxze\scripts\build-swd.ps1
```

## 6. 编译 UF2 固件

如果你已经烧入了 UF2 bootloader，电脑能识别成 U 盘，则编译 UF2：

```powershell
cd D:\ZMK_Firmware_cxze\zmk-work\zmk

west build -p always -d build\handpad40_uf2 -b nice_nano_v2 app -- -DSHIELD=handpad20 "-DZMK_CONFIG=D:/ZMK_Firmware_cxze/config" "-DZMK_EXTRA_MODULES=D:/ZMK_Firmware_cxze"
```

产物通常在：

```text
D:\ZMK_Firmware_cxze\zmk-work\zmk\build\handpad40_uf2\zephyr\zmk.uf2
```

也可以直接运行脚本：

```powershell
D:\ZMK_Firmware_cxze\scripts\build-uf2.ps1
```

## 7. SWD 烧录

第一次烧录建议整片擦除：

```powershell
nrfjprog --family NRF52 --recover
```

然后烧录：

```powershell
nrfjprog --family NRF52 --program D:\ZMK_Firmware_cxze\zmk-work\zmk\build\handpad40_swd\zephyr\zmk.hex --sectorerase --verify --reset
```

## 7. 如果编译失败

常见问题：

- 找不到 `west`：确认虚拟环境已激活。
- 找不到 `cmake` 或 `ninja`：确认软件已安装并加入 PATH。
- 找不到 `Zephyr-sdk`：安装 Zephyr SDK `0.16.3`，运行 `setup.cmd`，再设置 `$env:ZEPHYR_TOOLCHAIN_VARIANT = "zephyr"` 和 `$env:ZEPHYR_SDK_INSTALL_DIR = "D:/ZMK_Firmware_cxze/zephyr-sdk/zephyr-sdk-0.16.3"`。
- 找不到 `handpad20` shield：确认 `-DZMK_EXTRA_MODULES=D:/ZMK_Firmware_cxze` 没写错。
- 找不到 keymap：确认 `-DZMK_CONFIG=D:/ZMK_Firmware_cxze/config` 没写错。
- 提示 `D:, given in ZEPHYR_EXTRA_MODULES, is not a valid zephyr module`：说明路径被写成了 `D: /ZMK_Firmware_cxze`，`D:` 后面多了空格。复制上面的带引号命令重新编译。
- 移动目录后还出现 `D:/zmk-work/zmk/...`：删除旧构建目录 `D:\ZMK_Firmware_cxze\zmk-work\zmk\build\handpad40_swd` 后重新编译。
- 烧录失败：确认 J-Link 的 SWDIO、SWCLK、GND、VTref、RESET 接线。
