#!/bin/bash

# 快速更新 homebrew-oneclip 仓库的脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASK_FILE="$SCRIPT_DIR/Casks/oneclip.rb"

echo "🔄 更新 homebrew-oneclip 仓库"

# 检查 Cask 文件是否存在
if [[ ! -f "$CASK_FILE" ]]; then
    echo "❌ 未找到 Cask 文件: $CASK_FILE"
    exit 1
fi

# 创建临时目录
TEMP_DIR="$(mktemp -d)"
echo "📂 创建临时目录: $TEMP_DIR"

cd "$TEMP_DIR"

# 克隆仓库
echo "📥 克隆 homebrew-oneclip 仓库..."
git clone https://github.com/Wcowin/homebrew-oneclip.git .

# 复制更新的 Cask 文件
echo "📋 更新 Cask 文件..."
cp "$CASK_FILE" Casks/

# 检查是否有更改
if git diff --quiet; then
    echo "ℹ️  没有检测到更改"
else
    echo "📝 提交更改..."
    
    # 获取版本号
    VERSION=$(grep 'version' Casks/oneclip.rb | head -1 | sed 's/.*"\(.*\)".*/\1/')
    
    git add Casks/oneclip.rb
    git commit -m "Update to v$VERSION

- 更新版本号到 $VERSION
- 更新 SHA256 校验和
- 自动化发布脚本生成"
    
    echo "🚀 推送到 GitHub..."
    
    # 尝试推送，如果失败则先拉取再推送
    if ! git push origin master 2>/dev/null; then
        echo "⚠️  推送失败，尝试拉取远程更改..."
        
        # 拉取并合并
        git pull origin master --no-rebase
        
        # 如果有冲突，使用我们的版本
        if git diff --name-only --diff-filter=U | grep -q "Casks/oneclip.rb"; then
            echo "🔧 解决冲突：使用本地版本..."
            git checkout --ours Casks/oneclip.rb
            git add Casks/oneclip.rb
            git commit -m "Merge: Update to v$VERSION (resolve conflicts)"
        fi
        
        # 重新推送
        git push origin master
    fi
    
    echo "✅ 更新完成！"
fi

# 清理临时目录
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

echo ""
echo "🧪 现在可以测试安装:"
echo "   brew untap wcowin/oneclip"
echo "   brew tap wcowin/oneclip"
echo "   brew install --cask oneclip"
