#!/bin/bash

# OneClip Homebrew 一键发布脚本
# 功能：自动化完成 Homebrew Cask 的更新和发布

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}🍺 OneClip Homebrew 一键发布${NC}"
echo "===================================="
echo ""

# 步骤 1: 读取版本号
echo -e "${YELLOW}📋 步骤 1/5: 读取版本信息${NC}"

if [[ ! -f "$PROJECT_DIR/version.txt" ]]; then
    echo -e "${RED}❌ 未找到版本文件: $PROJECT_DIR/version.txt${NC}"
    exit 1
fi

VERSION=$(cat "$PROJECT_DIR/version.txt" | tr -d '\n\r')
echo -e "${GREEN}✅ 当前版本: $VERSION${NC}"
echo ""

# 步骤 2: 查找 DMG 文件
echo -e "${YELLOW}📋 步骤 2/5: 查找 DMG 文件${NC}"

# 🔥 智能查找 DMG 文件（支持多架构）
RELEASE_DIR="$PROJECT_DIR/dist/releases/$VERSION"

# 优先查找通用版本（推荐）
DMG_FILE="$RELEASE_DIR/OneClip-$VERSION.dmg"
if [[ ! -f "$DMG_FILE" ]]; then
    DMG_FILE="$RELEASE_DIR/OneClip-$VERSION-universal.dmg"
fi

# 查找 Apple Silicon 版本（兼容旧版本）
if [[ ! -f "$DMG_FILE" ]]; then
    DMG_FILE="$RELEASE_DIR/OneClip-$VERSION-apple-silicon.dmg"
fi

# 最后尝试根目录
if [[ ! -f "$DMG_FILE" ]]; then
    DMG_FILE="$PROJECT_DIR/OneClip-$VERSION.dmg"
fi

if [[ ! -f "$DMG_FILE" ]]; then
    echo -e "${RED}❌ 未找到 DMG 文件${NC}"
    echo ""
    echo "期望路径（按优先级）："
    echo "  1. $RELEASE_DIR/OneClip-$VERSION.dmg (通用版本)"
    echo "  2. $RELEASE_DIR/OneClip-$VERSION-universal.dmg"
    echo "  3. $RELEASE_DIR/OneClip-$VERSION-apple-silicon.dmg"
    echo "  4. $PROJECT_DIR/OneClip-$VERSION.dmg"
    echo ""
    echo "请先运行: ./sparkle_release.sh && ./create_dmg.sh"
    exit 1
fi

echo -e "${GREEN}✅ 找到 DMG 文件: $DMG_FILE${NC}"
DMG_SIZE=$(du -h "$DMG_FILE" | cut -f1)
echo "   大小: $DMG_SIZE"
echo ""

# 步骤 3: 计算 SHA256
echo -e "${YELLOW}📋 步骤 3/5: 计算 SHA256 校验和${NC}"

SHA256=$(shasum -a 256 "$DMG_FILE" | cut -d' ' -f1)
echo -e "${GREEN}✅ SHA256: $SHA256${NC}"
echo ""

# 步骤 4: 更新 Cask 文件
echo -e "${YELLOW}📋 步骤 4/5: 更新 Cask 文件${NC}"

CASK_FILE="$SCRIPT_DIR/Casks/oneclip.rb"

# 创建 Casks 目录（如果不存在）
mkdir -p "$SCRIPT_DIR/Casks"

# 🔥 统一使用通用版本（支持所有架构）
DMG_URL="https://github.com/Wcowin/OneClip/releases/download/#{version}/OneClip-#{version}.dmg"
LIVECHECK_REGEX="/OneClip[._-]v?(\d+(?:\.\d+)+)\.dmg/i"
ARCH_DEPENDS=""

# 生成 Cask 文件
cat > "$CASK_FILE" << EOF
cask "oneclip" do
  version "$VERSION"
  sha256 "$SHA256"

  url "$DMG_URL"
  name "OneClip"
  desc "Professional clipboard manager for macOS"
  homepage "https://oneclip.cloud/"

  livecheck do
    url "https://github.com/Wcowin/OneClip/releases"
    regex($LIVECHECK_REGEX)
  end

  depends_on macos: ">= :monterey"
$ARCH_DEPENDS

  app "OneClip.app"

  zap trash: [
    "~/Library/Application Support/OneClip",
    "~/Library/Caches/com.wcowin.OneClip",
    "~/Library/HTTPStorages/com.wcowin.OneClip",
    "~/Library/Preferences/com.wcowin.OneClip.plist",
    "~/Library/Saved Application State/com.wcowin.OneClip.savedState",
    "~/Library/WebKit/com.wcowin.OneClip",
  ]
end
EOF

echo -e "${GREEN}✅ Cask 文件已更新: $CASK_FILE${NC}"
echo ""

# 步骤 5: 推送到 Gitee
echo -e "${YELLOW}📋 步骤 5/5: 推送到 Gitee${NC}"

# 检查是否需要推送
read -p "是否推送到 Gitee homebrew-oneclip 仓库？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 开始推送..."
    
    if [[ -f "$SCRIPT_DIR/update_tap.sh" ]]; then
        "$SCRIPT_DIR/update_tap.sh"
    else
        echo -e "${RED}❌ 未找到 update_tap.sh 脚本${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 推送完成${NC}"
else
    echo "⏭️  跳过推送"
fi

echo ""
echo "===================================="
echo -e "${GREEN}🎉 Homebrew 发布准备完成！${NC}"
echo "===================================="
echo ""
echo -e "${BLUE}📦 发布信息：${NC}"
echo "   版本: $VERSION"
echo "   SHA256: $SHA256"
echo "   DMG: $DMG_FILE"
echo "   Cask: $CASK_FILE"
echo ""
echo -e "${BLUE}📋 接下来的步骤：${NC}"
echo ""
echo "1️⃣ 上传 DMG 到 GitHub Releases"
echo "   URL: https://github.com/Wcowin/OneClip/releases"
echo "   标签: v$VERSION"
echo "   文件: $(basename "$DMG_FILE")"
echo ""
echo "2️⃣ 测试安装"
echo "   brew untap Wcowin/oneclip 2>/dev/null || true"
echo "   brew tap Wcowin/oneclip"
echo "   brew install --cask oneclip"
echo ""
echo -e "${BLUE}👥 用户安装命令：${NC}"
echo "   brew install --cask Wcowin/oneclip/oneclip"
echo ""
