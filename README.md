# Homebrew Tap for OneClip

OneClip 的 Homebrew Cask 配置和发布脚本。

## 🚀 快速发布

```bash
# 1. 确保已生成发布文件
cd ..
./sparkle_release.sh  # 生成 OneClip-1.2.9.zip
./create_dmg.sh       # 生成 OneClip-1.2.9.dmg

# 2. 上传到 Gitee Releases
# https://gitee.com/Wcowin/OneClip/releases

# 3. 一键发布到 Homebrew
cd homebrew
./brew_release.sh
```

## 📦 版本说明

**当前版本**: 1.2.9  
**架构**: 通用版本 (Universal Binary)  
**支持**: Intel + Apple Silicon

## 📁 文件说明

| 文件 | 用途 |
|------|------|
| `Casks/oneclip.rb` | Homebrew Cask 配置 |
| `brew_release.sh` | 一键发布脚本 |
| `update_tap.sh` | 推送到 Tap 仓库 |
| `test_cask.sh` | Cask 测试脚本 |
| `oneclip.rb` | Cask 配置（根目录） |
| `archive/` | 历史文档和脚本 |

## 🔗 相关链接

- **Homebrew Tap**: https://github.com/Wcowin/homebrew-oneclip
- **Gitee Releases**: https://gitee.com/Wcowin/OneClip/releases
- **用户安装命令**: `brew install --cask Wcowin/oneclip/oneclip`

## 关于 OneClip

OneClip 是一款专为 macOS 打造的专业剪贴板管理工具。

- 官网：https://oneclip.cloud
- 仓库：https://gitee.com/Wcowin/OneClip

## 支持的平台

- macOS 12.0 (Monterey) 及以上
- Apple Silicon (arm64)
