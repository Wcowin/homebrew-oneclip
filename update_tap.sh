#!/bin/bash

# 快速更新 homebrew-oneclip 仓库的脚本
# 直接在本地仓库提交推送，无需克隆到临时目录

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASK_FILE="$SCRIPT_DIR/Casks/oneclip.rb"

echo "🔄 更新 homebrew-oneclip 仓库"

# 检查是否在 git 仓库中
if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
    echo "❌ 当前目录不是 git 仓库"
    exit 1
fi

# 检查 Cask 文件是否存在
if [[ ! -f "$CASK_FILE" ]]; then
    echo "❌ 未找到 Cask 文件: $CASK_FILE"
    exit 1
fi

cd "$SCRIPT_DIR"

# 获取版本号
VERSION=$(grep 'version' Casks/oneclip.rb | head -1 | sed 's/.*"\(.*\)".*/\1/')

# 检查是否有更改
if git diff --quiet && git diff --cached --quiet; then
    echo "ℹ️  没有检测到更改"
    exit 0
fi

echo "📝 提交更改..."

# 添加所有更改的文件
git add -A

# 提交更改
git commit -m "Update to v$VERSION

- 更新版本号到 $VERSION
- 更新 SHA256 校验和
- 自动化发布脚本生成"

echo "🚀 推送到 GitHub..."

# 尝试推送，如果失败则先拉取再推送
if ! git push origin main 2>/dev/null; then
    echo "⚠️  推送失败，尝试拉取远程更改..."
    
    # 拉取并合并（使用 --no-edit 避免打开编辑器）
    git pull origin main --no-rebase --no-edit || {
        echo "⚠️  拉取失败，尝试强制使用本地版本..."
        # 如果有冲突，使用我们的版本
        if git diff --name-only --diff-filter=U | grep -q "Casks/oneclip.rb"; then
            git checkout --ours Casks/oneclip.rb
            git add Casks/oneclip.rb
        fi
        # 完成合并
        git commit -m "Merge: Update to v$VERSION (resolve conflicts)" || true
    }
    
    # 重新推送
    git push origin main
fi

echo "✅ 更新完成！"

echo ""
echo "🧪 现在可以测试安装:"
echo "   brew untap wcowin/oneclip"
echo "   brew tap wcowin/oneclip"
echo "   brew install --cask oneclip"
