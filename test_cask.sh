#!/bin/bash

# OneClip Homebrew Cask 测试脚本
# 用于验证 Cask formula 的正确性

set -e

CASK_FILE="$(cd "$(dirname "$0")" && pwd)/oneclip.rb"

echo "🧪 测试 OneClip Homebrew Cask"
echo "📁 Cask 文件: $CASK_FILE"

# 检查文件是否存在
if [[ ! -f "$CASK_FILE" ]]; then
    echo "❌ Cask 文件不存在: $CASK_FILE"
    exit 1
fi

# 基本语法检查
echo "🔍 检查 Ruby 语法..."
if ruby -c "$CASK_FILE" >/dev/null 2>&1; then
    echo "✅ Ruby 语法正确"
else
    echo "❌ Ruby 语法错误"
    ruby -c "$CASK_FILE"
    exit 1
fi

# 检查必需字段
echo "🔍 检查必需字段..."

required_fields=("version" "sha256" "url" "name" "desc" "homepage" "app")
missing_fields=()

for field in "${required_fields[@]}"; do
    if ! grep -q "^[[:space:]]*$field" "$CASK_FILE"; then
        missing_fields+=("$field")
    fi
done

if [[ ${#missing_fields[@]} -gt 0 ]]; then
    echo "❌ 缺少必需字段: ${missing_fields[*]}"
    exit 1
else
    echo "✅ 所有必需字段都存在"
fi

# 检查 URL 格式
echo "🔍 检查 URL 格式..."
url_line=$(grep "^[[:space:]]*url" "$CASK_FILE")
if [[ "$url_line" =~ gitee\.com.*releases.*download ]]; then
    echo "✅ URL 格式正确 (Gitee Releases)"
elif [[ "$url_line" =~ github\.com.*releases.*download ]]; then
    echo "✅ URL 格式正确 (GitHub Releases)"
else
    echo "⚠️  URL 格式可能不标准"
    echo "   $url_line"
fi

# 检查版本一致性
echo "🔍 检查版本一致性..."
version_in_cask=$(grep "^[[:space:]]*version" "$CASK_FILE" | sed 's/.*"\(.*\)".*/\1/')
echo "   Cask 中的版本: $version_in_cask"

if [[ -f "version.txt" ]]; then
    version_in_file=$(cat version.txt | tr -d '\n')
    echo "   version.txt 中的版本: $version_in_file"
    
    if [[ "$version_in_cask" == "$version_in_file" ]]; then
        echo "✅ 版本一致"
    else
        echo "⚠️  版本不一致，请检查"
    fi
fi

# 检查 SHA256 格式
echo "🔍 检查 SHA256 格式..."
sha256_line=$(grep "^[[:space:]]*sha256" "$CASK_FILE")
if [[ "$sha256_line" =~ [0-9a-f]{64} ]]; then
    echo "✅ SHA256 格式正确"
else
    echo "❌ SHA256 格式不正确"
    echo "   $sha256_line"
fi

# 如果安装了 Homebrew，进行更详细的测试
if command -v brew >/dev/null 2>&1; then
    echo "🔍 使用 Homebrew 进行详细验证..."
    
    # 创建临时目录进行测试
    temp_dir=$(mktemp -d)
    cp "$CASK_FILE" "$temp_dir/"
    
    cd "$temp_dir"
    
    # 尝试解析 Cask
    if brew --repository >/dev/null 2>&1; then
        echo "✅ Homebrew 可用"
        
        # 注意：这里不进行实际安装，只是语法检查
        echo "💡 要进行完整测试，请运行:"
        echo "   brew install --cask $temp_dir/oneclip.rb --verbose"
    fi
    
    # 清理临时目录
    rm -rf "$temp_dir"
else
    echo "⚠️  未安装 Homebrew，跳过详细验证"
    echo "💡 安装 Homebrew 后可进行更完整的测试"
fi

echo ""
echo "🎉 Cask 基本验证完成！"
echo ""
echo "📋 下一步建议："
echo "1. 确保 DMG 文件已上传到 Gitee Releases"
echo "2. 确认 homebrew-oneclip 仓库已创建"
echo "3. 使用 ./brew_release.sh 自动更新和推送"
echo "4. 进行实际安装测试"
echo ""
echo "🧪 测试命令："
echo "   brew untap wcowin/oneclip 2>/dev/null || true"
echo "   brew tap wcowin/oneclip"
echo "   brew install --cask oneclip"
