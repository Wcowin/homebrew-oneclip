# Homebrew Tap for OneClip

<div align="center">
  <img src="https://picx.zhimg.com/80/v2-34b000e56d1af7ef61092dcd031dfd9a_1440w.webp?source=2c26e567" alt="OneClip Logo" width="120" height="120">
  <h1>OneClip</h1>
  <p><strong>专业的 macOS 剪贴板管理工具</strong></p>
  <p>🚀 高效 · 🎨 现代 · ⚡ 流畅 · 🔒 安全</p>
</div>

OneClip 的 Homebrew tap。GitHub 为主仓库，Gitee 为镜像；应用安装包主要从 Gitee 下载。

## 🧰 维护仓库布局

发布脚本默认按同级目录查找 OneClip 主项目：

```text
Pictures/
├── OneClipPlusProMAX/
└── homebrew-oneclip/
```

运行 `./brew_release.sh` 时，会从 `../OneClipPlusProMAX/version.txt` 和 `../OneClipPlusProMAX/dist/releases/` 读取版本与 DMG。其他目录布局可以显式指定：

```bash
ONECLIP_PROJECT_DIR=/path/to/OneClipPlusProMAX ./brew_release.sh
```

## 🍺 安装

### 一键安装（推荐，GitHub 主源）
```bash
brew install --cask wcowin/oneclip/oneclip
```

### Gitee 镜像安装
```bash
brew tap wcowin/oneclip https://gitee.com/Wcowin/homebrew-oneclip.git
brew install --cask oneclip
```

## 🔄 更新

```bash
# 更新 Homebrew 和所有应用
brew update
brew upgrade --cask oneclip
```

## 切换 Tap 源

默认使用 GitHub 主源。如果 GitHub 访问不稳定，可以临时切换到 Gitee 镜像。

### 切换到 Gitee 镜像
```bash
brew untap wcowin/oneclip 2>/dev/null || true
rm -rf "$(brew --prefix)/Library/Taps/wcowin/homebrew-oneclip" 2>/dev/null || true
brew tap wcowin/oneclip https://gitee.com/Wcowin/homebrew-oneclip.git
```

### 恢复 GitHub 主源
```bash
brew untap wcowin/oneclip 2>/dev/null || true
rm -rf "$(brew --prefix)/Library/Taps/wcowin/homebrew-oneclip" 2>/dev/null || true
brew tap wcowin/oneclip https://github.com/Wcowin/homebrew-oneclip.git
```

### 查看当前 Tap 源
```bash
brew tap-info wcowin/oneclip
git -C "$(brew --repo wcowin/oneclip)" remote -v
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

- **官方网站**: [https://oneclip.cloud](https://oneclip.cloud/)
- **GitHub 主仓库**: [https://github.com/Wcowin/homebrew-oneclip](https://github.com/Wcowin/homebrew-oneclip)
- **Gitee 镜像**: [https://gitee.com/Wcowin/homebrew-oneclip](https://gitee.com/Wcowin/homebrew-oneclip)
- **QQ 群**: [1060157293](https://qm.qq.com/q/ckSQ6MXgLm)
- **TG 群组**: [点击加入](https://t.me/+I7S6R0pw5180YzRl)

## 问题反馈

如果在使用 Homebrew 安装过程中遇到问题：

1. **检查系统要求**：确保 macOS 12.0+ 且为 Apple Silicon
2. **更新 Homebrew**：`brew update`
3. **重新安装**：`brew uninstall --cask oneclip && brew install --cask oneclip`
4. **查看详细日志**：`brew install --cask oneclip --verbose`

如果问题仍然存在，请在 [GitHub Issues](https://github.com/Wcowin/homebrew-oneclip/issues) 反馈。

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
