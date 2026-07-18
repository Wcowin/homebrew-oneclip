#!/bin/bash

# 快速更新 homebrew-oneclip 仓库的脚本
# 直接在本地仓库提交推送，无需克隆到临时目录

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASK_FILE="$SCRIPT_DIR/Casks/oneclip.rb"
CASK_RELATIVE_PATH="Casks/oneclip.rb"
EXPECTED_GITHUB_HTTPS="https://github.com/Wcowin/homebrew-oneclip.git"
EXPECTED_GITHUB_SSH="git@github.com:Wcowin/homebrew-oneclip.git"
EXPECTED_GITEE_URL="https://gitee.com/Wcowin/homebrew-oneclip.git"
CHECK_ONLY=false

if [[ "${1:-}" == "--check" ]]; then
    CHECK_ONLY=true
elif [[ -n "${1:-}" ]]; then
    echo "用法: $0 [--check]"
    exit 1
fi

echo "🔄 更新 homebrew-oneclip 仓库"

# 检查是否在 git 仓库中（兼容普通仓库与正式 submodule）
if ! git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ 当前目录不是 git 仓库"
    exit 1
fi

# 检查 Cask 文件是否存在
if [[ ! -f "$CASK_FILE" ]]; then
    echo "❌ 未找到 Cask 文件: $CASK_FILE"
    exit 1
fi

cd "$SCRIPT_DIR"

# 验证分支和远程，避免推送到错误仓库
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "❌ 当前分支不是 main: $CURRENT_BRANCH"
    exit 1
fi

ORIGIN_URL=$(git config --get remote.origin.url || true)
GITEE_URL=$(git config --get remote.gitee.url || true)

if [[ "$ORIGIN_URL" != "$EXPECTED_GITHUB_HTTPS" && "$ORIGIN_URL" != "$EXPECTED_GITHUB_SSH" ]]; then
    echo "❌ origin 必须指向 GitHub 主仓库"
    echo "   当前: ${ORIGIN_URL:-未配置}"
    echo "   期望: $EXPECTED_GITHUB_HTTPS"
    exit 1
fi

if [[ "$GITEE_URL" != "$EXPECTED_GITEE_URL" ]]; then
    echo "❌ gitee 必须指向 Gitee 镜像仓库"
    echo "   当前: ${GITEE_URL:-未配置}"
    echo "   期望: $EXPECTED_GITEE_URL"
    exit 1
fi

# 获取版本号
VERSION=$(grep 'version' Casks/oneclip.rb | head -1 | sed 's/.*"\(.*\)".*/\1/')

echo "🔍 检查 GitHub 与 Gitee 远端状态..."
git fetch origin main
git fetch gitee main

LOCAL_HEAD=$(git rev-parse HEAD)
GITHUB_HEAD=$(git rev-parse refs/remotes/origin/main)
GITEE_HEAD=$(git rev-parse refs/remotes/gitee/main)

if [[ "$GITHUB_HEAD" != "$GITEE_HEAD" ]]; then
    echo "❌ GitHub 与 Gitee 的 main 分支不一致，请先人工处理"
    echo "   GitHub: $GITHUB_HEAD"
    echo "   Gitee:  $GITEE_HEAD"
    exit 1
fi

if [[ "$LOCAL_HEAD" != "$GITHUB_HEAD" ]]; then
    echo "❌ 本地 main 与远端 main 不一致，请先人工同步"
    echo "   本地:   $LOCAL_HEAD"
    echo "   远端:   $GITHUB_HEAD"
    exit 1
fi

if [[ "$CHECK_ONLY" == "true" ]]; then
    echo "✅ 预检通过：分支、远程和双端提交均正确，未提交或推送任何内容"
    exit 0
fi

# 拒绝夹带已暂存的其他文件
UNRELATED_STAGED=$(git diff --cached --name-only | grep -v "^${CASK_RELATIVE_PATH}$" || true)
if [[ -n "$UNRELATED_STAGED" ]]; then
    echo "❌ 检测到与 Cask 无关的已暂存文件，请先处理："
    echo "$UNRELATED_STAGED"
    exit 1
fi

# 仅检查 Cask，避免把其他维护文件意外带入发布提交
if git diff --quiet -- "$CASK_RELATIVE_PATH" && git diff --cached --quiet -- "$CASK_RELATIVE_PATH"; then
    echo "ℹ️  Cask 没有检测到更改"
    exit 0
fi

echo "📝 提交 Cask 更改..."

# 只暂存 Cask 文件
git add -- "$CASK_RELATIVE_PATH"

# 提交更改
git commit -m "Update to v$VERSION

- 更新版本号到 $VERSION
- 更新 SHA256 校验和
- 自动化发布脚本生成"

echo "🚀 推送到 GitHub 主仓库..."
git push origin main

echo "🚀 同步推送到 Gitee 镜像..."
if ! git push gitee main; then
    echo "❌ GitHub 已推送，但 Gitee 同步失败"
    echo "   网络恢复后请运行: git push gitee main"
    exit 1
fi

PUSHED_HEAD=$(git rev-parse HEAD)
REMOTE_GITHUB_HEAD=$(git ls-remote origin refs/heads/main | awk '{print $1}')
REMOTE_GITEE_HEAD=$(git ls-remote gitee refs/heads/main | awk '{print $1}')

if [[ "$PUSHED_HEAD" != "$REMOTE_GITHUB_HEAD" || "$PUSHED_HEAD" != "$REMOTE_GITEE_HEAD" ]]; then
    echo "❌ 推送后远端提交校验失败"
    echo "   本地:   $PUSHED_HEAD"
    echo "   GitHub: $REMOTE_GITHUB_HEAD"
    echo "   Gitee:  $REMOTE_GITEE_HEAD"
    exit 1
fi

echo "✅ GitHub 与 Gitee 已同步到同一提交"

echo ""
echo "🧪 现在可以测试安装:"
echo "   brew untap wcowin/oneclip"
echo "   brew tap wcowin/oneclip https://github.com/Wcowin/homebrew-oneclip.git"
echo "   brew install --cask oneclip"
