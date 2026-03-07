# Homebrew Tap for OneClip

<div align="center">
  <img src="https://picx.zhimg.com/80/v2-34b000e56d1af7ef61092dcd031dfd9a_1440w.webp?source=2c26e567" alt="OneClip Logo" width="120" height="120">
  <h1>OneClip</h1>
  <p><strong>专业的 macOS 剪贴板管理工具</strong></p>
  <p>🚀 高效 · 🎨 现代 · ⚡ 流畅 · 🔒 安全</p>
</div>

OneClip 的 Homebrew tap，让您可以轻松通过命令行安装和管理 OneClip。

## 🍺 安装

### 快速安装
```bash
# 添加 tap
brew tap wcowin/oneclip

# 安装 OneClip
brew install --cask oneclip
```

### 一键安装（推荐）
```bash
brew install --cask wcowin/oneclip/oneclip
```

## 🔄 更新

```bash
# 更新 Homebrew 和所有应用
brew update
brew upgrade --cask oneclip
```

## 从 Gitee 迁移到 GitHub（老用户必读）

如果你之前通过 Gitee tap 安装了 OneClip，请按以下步骤切换到 GitHub 源：

### 方法一：自动切换（推荐）
```bash
# 移除旧的 Gitee tap
brew untap wcowin/oneclip

# 重新安装（会自动添加 GitHub tap 并升级到最新版本）
brew install --cask wcowin/oneclip/oneclip
```

### 方法二：手动切换
```bash
# 1. 移除旧的 Gitee tap
brew untap wcowin/oneclip

# 2. 添加新的 GitHub tap
brew tap wcowin/oneclip

# 3. 升级到最新版本
brew upgrade --cask oneclip
```

### 验证迁移成功
```bash
# 查看 tap 源地址（应该显示 GitHub）
brew tap-info wcowin/oneclip

# 查看当前版本
brew info --cask oneclip
```

> **注意**：迁移过程不会影响你的剪贴板数据和设置，所有用户数据都会保留。

## 🗑️ 卸载

```bash
# 卸载 OneClip
brew uninstall --cask oneclip

# 完全清理（包括用户数据）
brew uninstall --zap --cask oneclip
```

## 📋 关于 OneClip

OneClip 是一款专为 macOS 打造的专业级剪贴板管理工具，采用 100% SwiftUI 原生技术。

### ✨ 主要特性

- **📋 智能记录**：自动保存剪贴板历史，支持文本、图片、文件等格式
- **🔎 极速搜索**：随打随搜，多维筛选快速定位  
- **🗂️ 全格式支持**：图片/视频/音频/文档等，完整保留元数据
- **⌨️ 全局快捷键**：`Cmd+Option+V` 呼出主界面，支持自定义组合
- **🔄 快捷回复**：`Cmd+Option+R` 呼出快捷回复界面
- **🎯 菜单栏集成**：一键粘贴最近内容，状态实时可见
- **🎨 现代界面**：遵循 macOS 设计规范，毛玻璃与暗黑模式适配

### 🖥️ 系统要求

- macOS 12.0 (Monterey) 及以上
- Apple Silicon (M 系列芯片) 优先适配

## 🔗 相关链接

- ** 官方网站**: [https://oneclip.cloud](https://oneclip.cloud/)
- ** 源码仓库**: [https://github.com/Wcowin/OneClip](https://github.com/Wcowin/OneClip)
- ** 直接下载**: [GitHub Releases](https://github.com/Wcowin/OneClip/releases)
- ** QQ 群**: [1060157293](https://qm.qq.com/q/ckSQ6MXgLm)

## 问题反馈

如果在使用 Homebrew 安装过程中遇到问题：

1. **检查系统要求**：确保 macOS 12.0+ 且为 Apple Silicon
2. **更新 Homebrew**：`brew update`
3. **重新安装**：`brew uninstall --cask oneclip && brew install --cask oneclip`
4. **查看详细日志**：`brew install --cask oneclip --verbose`

如果问题仍然存在，请在 [GitHub Issues](https://github.com/Wcowin/OneClip/issues) 反馈。

## 📊 使用统计

```bash
# 查看 Cask 信息
brew info --cask oneclip

# 查看安装的应用
brew list --cask | grep oneclip
```

## 🤝 贡献

欢迎为这个 tap 做出贡献！如果你发现问题或有改进建议：

1. Fork 这个仓库
2. 创建功能分支
3. 提交你的更改
4. 创建 Pull Request

## 📜 许可证

此 Homebrew tap 遵循 MIT 许可证。OneClip 应用本身的许可证请参考主仓库。

---

<div align="center">
  <p><strong>OneClip - 让剪贴板管理更简单</strong></p>
  <p>© 2026 Wcowin. All rights reserved.</p>
</div>
