# OneClip Homebrew 安装助手

## 一键安装

```bash
# 下载并运行安装脚本（推荐）
curl -fsSL https://gitee.com/Wcowin/homebrew-oneclip/raw/master/install.sh | bash
```

## 功能列表

### 交互式菜单

运行 `./install.sh` 进入交互式菜单：

```
╔════════════════════════════════════════════════════════════════════╗
║     OneClip - 专业剪贴板管理工具                                ║
║     安装助手 v1.0                                                ║
╚════════════════════════════════════════════════════════════════════╝

  当前状态:
    OneClip: v1.4.4

  请选择操作:

  安装/升级
    1) 🚀 快速安装 (一键安装最新版)
    2) ⬆️  升级到最新版本
    3) 🔄 重新安装 (清理后安装)

  维护
    4) 🔧 全面诊断 (检测并修复问题)
    5) 🧹 清理 Homebrew 缓存
    6) 🗑️  清理应用缓存
    7) 🌐 测试网络连接

  数据
    8) 💾 备份数据
    9) 📂 恢复数据

  卸载
   10) ❌ 卸载 OneClip

  其他
   11) ℹ️  显示详细状态
   12) 🍺 安装 Homebrew
    0) 退出
```

### 命令行参数

```bash
./install.sh install    # 快速安装
./install.sh upgrade    # 升级到最新版
./install.sh diagnose   # 全面诊断
./install.sh clean      # 清理缓存
./install.sh reinstall  # 重新安装
./install.sh uninstall  # 卸载
./install.sh status     # 显示状态
./install.sh backup     # 备份数据
./install.sh restore    # 恢复数据
./install.sh help       # 显示帮助
```

## 功能说明

### 🚀 快速安装
- 自动检测 Homebrew
- 自动检测并清理旧缓存
- 自动添加/更新 Tap
- 下载安装最新版本

### 🔧 全面诊断
- 检测 Homebrew 状态
- 检测 Tap 是否过期
- 检测版本是否最新
- 检测缓存问题
- 测试网络连接
- 验证下载地址
- 自动修复发现的问题

### 🧹 清理缓存
- 清理 Homebrew 通用缓存
- 清理 OneClip 下载缓存
- 刷新 Tap 配置
- 清理 API 缓存

### 💾 备份/恢复
- 备份应用数据到桌面
- 支持从备份恢复数据
- 保留剪贴板历史和设置

## 常见问题

### 1. 下载失败 (404 错误)

运行诊断并自动修复：
```bash
./install.sh diagnose
```

或手动清理：
```bash
./install.sh clean
./install.sh install
```

### 2. 版本过旧

```bash
./install.sh upgrade
```

### 3. 完全重新安装

```bash
./install.sh reinstall
```

### 4. 无法连接 Gitee

检查网络连接：
```bash
./install.sh
# 选择 7) 🌐 测试网络连接
```

## 手动安装

如果脚本不可用，可以手动安装：

```bash
# 清理缓存
brew cleanup --prune=all

# 添加 tap
brew untap wcowin/oneclip 2>/dev/null
brew tap wcowin/oneclip

# 安装
brew install --cask oneclip
```

## 相关链接

- 官网: https://oneclip.cloud
- 反馈: vip@oneclip.cloud
- Gitee: https://gitee.com/Wcowin/OneClip
