#!/bin/bash

#
# OneClip Homebrew 安装/诊断/维护脚本
# 
# 用法: 
#   curl -fsSL https://raw.githubusercontent.com/Wcowin/homebrew-oneclip/master/install.sh | bash
#   或者: ./install.sh
#
# 功能:
#   - 一键安装/升级
#   - 问题诊断与自动修复
#   - 缓存清理
#   - 网络测试
#   - 数据备份/恢复
#   - 完整卸载
#

set -e

# ═══════════════════════════════════════════════════════════════
# 配置
# ═══════════════════════════════════════════════════════════════

TAP_NAME="wcowin/oneclip"
CASK_NAME="oneclip"
APP_NAME="OneClip"
GITHUB_API="https://api.github.com/repos/Wcowin"
GITHUB_RAW="https://github.com/Wcowin"
SUPPORT_EMAIL="vip@oneclip.cloud"
WEBSITE="https://oneclip.cloud"

# 数据目录
APP_SUPPORT_DIR="$HOME/Library/Application Support/OneClip"
PREFERENCES_FILE="$HOME/Library/Preferences/com.wcowin.OneClip.plist"
CACHE_DIR="$HOME/Library/Caches/com.wcowin.OneClip"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 状态变量
REMOTE_VERSION=""
LOCAL_VERSION=""
TAP_INSTALLED=false
CASK_INSTALLED=false
ISSUES=()

# 是否是交互式模式
INTERACTIVE=false
if [[ -t 0 ]] && [[ -t 1 ]]; then
    INTERACTIVE=true
fi

# ═══════════════════════════════════════════════════════════════
# 打印函数
# ═══════════════════════════════════════════════════════════════

print_header() {
    # 只在交互式终端中清屏
    if [[ -t 1 ]]; then
        clear
    fi
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}${BLUE}OneClip${NC} - 专业剪贴板管理工具                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ${DIM}安装助手 v1.0${NC}                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━ $1 ━━━${NC}"
    echo ""
}

print_step() {
    echo -e "  ${BLUE}▶${NC} $1"
}

print_substep() {
    echo -e "    ${DIM}•${NC} $1"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${CYAN}ℹ${NC} $1"
}

print_divider() {
    echo -e "${DIM}────────────────────────────────────────────────────────────────────${NC}"
}

# 等待用户按键
press_any_key() {
    echo ""
    read -n 1 -s -r -p "按任意键继续..."
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 核心检测函数
# ═══════════════════════════════════════════════════════════════

# 检测 Homebrew
check_homebrew() {
    print_step "检测 Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        print_error "未检测到 Homebrew"
        ISSUES+=("homebrew_not_installed")
        return 1
    fi
    
    BREW_VERSION=$(brew --version | head -1 | awk '{print $2}')
    print_success "Homebrew $BREW_VERSION"
    return 0
}

# 获取远程版本
get_remote_version() {
    print_step "获取最新版本..."
    
    # 从 GitHub 获取版本信息
    REMOTE_VERSION=$(curl -sL --connect-timeout 5 "$GITHUB_API/homebrew-oneclip/contents/Casks/oneclip.rb" 2>/dev/null | \
        python3 -c "import json,sys,base64; d=json.load(sys.stdin); c=base64.b64decode(d['content']).decode(); print([l.split('\"')[1] for l in c.split('\n') if 'version' in l][0])" 2>/dev/null || echo "")
    
    if [[ -z "$REMOTE_VERSION" ]]; then
        print_warning "无法获取（网络问题）"
        ISSUES+=("network_issue")
        return 1
    fi
    
    print_success "最新版本: v$REMOTE_VERSION"
    return 0
}

# 检测 Tap 状态
check_tap() {
    print_step "检测 Tap..."
    
    if brew tap 2>/dev/null | grep -q "$TAP_NAME"; then
        TAP_INSTALLED=true
        
        # 检查更新时间
        TAP_PATH="$(brew --prefix)/Library/Taps/wcowin/homebrew-oneclip"
        if [[ -d "$TAP_PATH" ]]; then
            LAST_UPDATE=$(stat -f "%m" "$TAP_PATH" 2>/dev/null || echo "0")
            CURRENT_TIME=$(date +%s)
            DAYS_OLD=$(( (CURRENT_TIME - LAST_UPDATE) / 86400 ))
            
            if [[ "$DAYS_OLD" -gt 7 ]]; then
                print_warning "已添加 (${DAYS_OLD}天未更新)"
                ISSUES+=("tap_outdated")
            else
                print_success "已添加 (${DAYS_OLD}天前更新)"
            fi
        else
            print_success "已添加"
        fi
    else
        TAP_INSTALLED=false
        print_info "未添加"
    fi
}

# 检测安装状态
check_installation() {
    print_step "检测安装状态..."
    
    if brew list --cask 2>/dev/null | grep -q "^$CASK_NAME$"; then
        CASK_INSTALLED=true
        LOCAL_VERSION=$(brew list --cask --versions $CASK_NAME 2>/dev/null | awk '{print $2}')
        
        if [[ -n "$REMOTE_VERSION" ]] && [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
            print_warning "已安装 v$LOCAL_VERSION (有新版本 v$REMOTE_VERSION)"
            ISSUES+=("version_outdated")
        else
            print_success "已安装 v$LOCAL_VERSION"
        fi
    else
        CASK_INSTALLED=false
        print_info "未安装"
    fi
}

# 检测缓存状态
check_cache() {
    print_step "检测缓存..."
    
    BREW_CACHE=$(brew --cache 2>/dev/null)
    CACHE_SIZE=0
    CACHE_FILES=0
    
    if [[ -d "$BREW_CACHE" ]]; then
        # 检查 OneClip 相关缓存
        if [[ -d "$BREW_CACHE/Cask" ]]; then
            CACHE_FILES=$(find "$BREW_CACHE/Cask" -name "oneclip*" 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$CACHE_FILES" -gt "0" ]]; then
                CACHE_SIZE=$(du -sh "$BREW_CACHE/Cask"/oneclip* 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
            fi
        fi
        
        # 检查下载缓存
        DOWNLOAD_CACHE=$(find "$BREW_CACHE/downloads" -name "*oneclip*" -o -name "*OneClip*" 2>/dev/null | wc -l | tr -d ' ')
        CACHE_FILES=$((CACHE_FILES + DOWNLOAD_CACHE))
    fi
    
    if [[ "$CACHE_FILES" -gt "0" ]]; then
        print_warning "发现 $CACHE_FILES 个缓存文件"
        ISSUES+=("cache_exists")
    else
        print_success "缓存正常"
    fi
}

# 检测应用数据
check_app_data() {
    print_step "检测应用数据..."
    
    DATA_SIZE="0"
    if [[ -d "$APP_SUPPORT_DIR" ]]; then
        DATA_SIZE=$(du -sh "$APP_SUPPORT_DIR" 2>/dev/null | awk '{print $1}')
        print_success "数据目录: $DATA_SIZE"
    else
        print_info "无数据目录"
    fi
}

# 网络测试
test_network() {
    print_step "测试网络连接..."
    
    # 测试 GitHub
    if curl -sL --connect-timeout 5 "https://github.com" > /dev/null 2>&1; then
        print_success "GitHub 连接正常"
    else
        print_error "GitHub 连接失败"
        ISSUES+=("github_unreachable")
    fi
    
    # 测试下载地址
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL="$GITHUB_RAW/OneClip/releases/download/$REMOTE_VERSION/OneClip-$REMOTE_VERSION.dmg"
        HTTP_CODE=$(curl -sL --connect-timeout 5 -o /dev/null -w "%{http_code}" "$DOWNLOAD_URL" 2>/dev/null || echo "000")
        
        if [[ "$HTTP_CODE" == "302" ]] || [[ "$HTTP_CODE" == "200" ]]; then
            print_success "下载地址有效"
        else
            print_error "下载地址无效 (HTTP $HTTP_CODE)"
            ISSUES+=("download_url_invalid")
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# 操作函数
# ═══════════════════════════════════════════════════════════════

# 安装 Homebrew
install_homebrew() {
    print_section "安装 Homebrew"
    
    echo -e "  请选择安装方式:"
    echo ""
    echo "    1) 官方源 (国外推荐)"
    echo "    2) 国内镜像 (国内推荐)"
    echo "    0) 取消"
    echo ""
    read -p "  请选择 [0-2]: " choice
    
    case "$choice" in
        1)
            print_step "使用官方源安装..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            ;;
        2)
            print_step "使用国内镜像安装..."
            /bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
            ;;
        *)
            print_info "已取消"
            return 1
            ;;
    esac
    
    print_success "Homebrew 安装完成"
}

# 添加/更新 Tap
setup_tap() {
    print_step "设置 Tap..."
    
    if [[ "$TAP_INSTALLED" == "true" ]]; then
        print_substep "移除旧 Tap..."
        brew untap "$TAP_NAME" 2>/dev/null || true
    fi
    
    print_substep "添加 Tap..."
    if brew tap "$TAP_NAME" 2>&1; then
        print_success "Tap 设置完成"
        TAP_INSTALLED=true
    else
        print_error "Tap 添加失败"
        return 1
    fi
}

# 清理缓存
clean_cache() {
    print_section "清理缓存"
    
    BREW_CACHE=$(brew --cache 2>/dev/null)
    
    # 1. 清理 Homebrew 缓存
    print_step "清理 Homebrew 通用缓存..."
    brew cleanup --prune=all 2>/dev/null || true
    print_success "完成"
    
    # 2. 清理 OneClip 相关缓存
    print_step "清理 OneClip 下载缓存..."
    if [[ -d "$BREW_CACHE/Cask" ]]; then
        rm -rf "$BREW_CACHE/Cask"/oneclip* 2>/dev/null || true
    fi
    if [[ -d "$BREW_CACHE/downloads" ]]; then
        find "$BREW_CACHE/downloads" -name "*oneclip*" -delete 2>/dev/null || true
        find "$BREW_CACHE/downloads" -name "*OneClip*" -delete 2>/dev/null || true
    fi
    print_success "完成"
    
    # 3. 清理 Tap 缓存
    print_step "刷新 Tap 缓存..."
    if [[ "$TAP_INSTALLED" == "true" ]]; then
        brew untap "$TAP_NAME" 2>/dev/null || true
        brew tap "$TAP_NAME" 2>/dev/null || true
    fi
    print_success "完成"
    
    # 4. 清理 API 缓存
    print_step "清理 API 缓存..."
    rm -rf "$HOME/Library/Caches/Homebrew/api" 2>/dev/null || true
    print_success "完成"
    
    echo ""
    print_success "所有缓存已清理"
}

# 清理应用缓存（不删除数据）
clean_app_cache() {
    print_section "清理应用缓存"
    
    print_step "清理应用运行缓存..."
    if [[ -d "$CACHE_DIR" ]]; then
        rm -rf "$CACHE_DIR" 2>/dev/null || true
        print_success "已清理: $CACHE_DIR"
    else
        print_info "无缓存目录"
    fi
    
    print_step "清理 WebKit 缓存..."
    WEBKIT_DIR="$HOME/Library/WebKit/com.wcowin.OneClip"
    if [[ -d "$WEBKIT_DIR" ]]; then
        rm -rf "$WEBKIT_DIR" 2>/dev/null || true
        print_success "已清理"
    else
        print_info "无 WebKit 缓存"
    fi
    
    print_step "清理 HTTP 存储..."
    HTTP_DIR="$HOME/Library/HTTPStorages/com.wcowin.OneClip"
    if [[ -d "$HTTP_DIR" ]]; then
        rm -rf "$HTTP_DIR" 2>/dev/null || true
        print_success "已清理"
    else
        print_info "无 HTTP 存储"
    fi
    
    echo ""
    print_success "应用缓存已清理（数据已保留）"
}

# 安装 OneClip
install_oneclip() {
    print_section "安装 OneClip"
    
    # 确保 Tap 已添加
    if [[ "$TAP_INSTALLED" != "true" ]]; then
        setup_tap || return 1
    fi
    
    print_step "下载并安装..."
    echo ""
    
    if brew install --cask "$CASK_NAME"; then
        echo ""
        print_success "安装成功!"
        CASK_INSTALLED=true
        LOCAL_VERSION=$(brew list --cask --versions $CASK_NAME 2>/dev/null | awk '{print $2}')
    else
        echo ""
        print_error "安装失败"
        print_info "请尝试: 清理缓存后重试"
        return 1
    fi
}

# 升级 OneClip
upgrade_oneclip() {
    print_section "升级 OneClip"
    
    # 先更新 Tap
    setup_tap || return 1
    
    print_step "升级到最新版本..."
    echo ""
    
    if brew upgrade --cask "$CASK_NAME" 2>/dev/null; then
        echo ""
        print_success "升级成功!"
    else
        # 如果 upgrade 失败，尝试 reinstall
        print_warning "升级失败，尝试重新安装..."
        if brew reinstall --cask "$CASK_NAME"; then
            echo ""
            print_success "重新安装成功!"
        else
            echo ""
            print_error "升级失败"
            return 1
        fi
    fi
    
    LOCAL_VERSION=$(brew list --cask --versions $CASK_NAME 2>/dev/null | awk '{print $2}')
    print_info "当前版本: v$LOCAL_VERSION"
}

# 重新安装
reinstall_oneclip() {
    print_section "重新安装 OneClip"
    
    print_warning "这将完全清理并重新安装 OneClip"
    print_info "应用数据将被保留"
    echo ""
    read -p "  确定继续? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "已取消"
        return 0
    fi
    
    echo ""
    
    # 1. 卸载现有版本
    if [[ "$CASK_INSTALLED" == "true" ]]; then
        print_step "卸载现有版本..."
        brew uninstall --cask "$CASK_NAME" --force 2>/dev/null || true
        print_success "已卸载"
        CASK_INSTALLED=false
    fi
    
    # 2. 清理所有缓存
    clean_cache
    
    # 3. 重新安装
    install_oneclip
}

# 卸载 OneClip
uninstall_oneclip() {
    print_section "卸载 OneClip"
    
    echo -e "  请选择卸载方式:"
    echo ""
    echo "    1) 仅卸载应用 (保留数据)"
    echo "    2) 完全卸载 (删除所有数据)"
    echo "    0) 取消"
    echo ""
    read -p "  请选择 [0-2]: " choice
    
    case "$choice" in
        1)
            print_step "卸载应用..."
            if brew uninstall --cask "$CASK_NAME" 2>/dev/null; then
                print_success "应用已卸载"
                print_info "数据保留在: $APP_SUPPORT_DIR"
            else
                print_warning "应用可能未通过 Homebrew 安装"
            fi
            ;;
        2)
            print_warning "这将删除所有 OneClip 数据!"
            read -p "  确定继续? [y/N]: " confirm
            
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                print_step "完全卸载..."
                
                # 卸载应用
                brew uninstall --cask "$CASK_NAME" --zap 2>/dev/null || true
                
                # 手动清理残留
                print_substep "清理数据目录..."
                rm -rf "$APP_SUPPORT_DIR" 2>/dev/null || true
                rm -rf "$CACHE_DIR" 2>/dev/null || true
                rm -f "$PREFERENCES_FILE" 2>/dev/null || true
                rm -rf "$HOME/Library/Saved Application State/com.wcowin.OneClip.savedState" 2>/dev/null || true
                rm -rf "$HOME/Library/WebKit/com.wcowin.OneClip" 2>/dev/null || true
                rm -rf "$HOME/Library/HTTPStorages/com.wcowin.OneClip" 2>/dev/null || true
                
                print_success "已完全卸载"
            else
                print_info "已取消"
            fi
            ;;
        *)
            print_info "已取消"
            ;;
    esac
    
    # 询问是否移除 Tap
    if [[ "$TAP_INSTALLED" == "true" ]]; then
        echo ""
        read -p "  是否移除 Tap? [y/N]: " remove_tap
        if [[ "$remove_tap" =~ ^[Yy]$ ]]; then
            brew untap "$TAP_NAME" 2>/dev/null || true
            print_success "Tap 已移除"
            TAP_INSTALLED=false
        fi
    fi
}

# 备份数据
backup_data() {
    print_section "备份数据"
    
    if [[ ! -d "$APP_SUPPORT_DIR" ]]; then
        print_warning "未找到 OneClip 数据目录"
        return 1
    fi
    
    BACKUP_DIR="$HOME/Desktop/OneClip_Backup_$(date +%Y%m%d_%H%M%S)"
    
    print_step "备份到: $BACKUP_DIR"
    
    mkdir -p "$BACKUP_DIR"
    
    # 备份数据目录
    if cp -R "$APP_SUPPORT_DIR" "$BACKUP_DIR/Application Support" 2>/dev/null; then
        print_success "数据目录已备份"
    fi
    
    # 备份偏好设置
    if [[ -f "$PREFERENCES_FILE" ]]; then
        cp "$PREFERENCES_FILE" "$BACKUP_DIR/" 2>/dev/null
        print_success "偏好设置已备份"
    fi
    
    # 计算备份大小
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
    
    echo ""
    print_success "备份完成! 大小: $BACKUP_SIZE"
    print_info "位置: $BACKUP_DIR"
}

# 恢复数据
restore_data() {
    print_section "恢复数据"
    
    # 查找备份
    BACKUPS=($(ls -d "$HOME/Desktop/OneClip_Backup_"* 2>/dev/null || true))
    
    if [[ ${#BACKUPS[@]} -eq 0 ]]; then
        print_warning "未找到备份文件"
        print_info "请确保备份在桌面上，名称格式: OneClip_Backup_*"
        return 1
    fi
    
    echo -e "  找到以下备份:"
    echo ""
    for i in "${!BACKUPS[@]}"; do
        BACKUP_NAME=$(basename "${BACKUPS[$i]}")
        BACKUP_SIZE=$(du -sh "${BACKUPS[$i]}" 2>/dev/null | awk '{print $1}')
        echo "    $((i+1))) $BACKUP_NAME ($BACKUP_SIZE)"
    done
    echo "    0) 取消"
    echo ""
    read -p "  请选择要恢复的备份 [0-${#BACKUPS[@]}]: " choice
    
    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        print_info "已取消"
        return 0
    fi
    
    INDEX=$((choice - 1))
    if [[ $INDEX -lt 0 ]] || [[ $INDEX -ge ${#BACKUPS[@]} ]]; then
        print_error "无效选择"
        return 1
    fi
    
    SELECTED_BACKUP="${BACKUPS[$INDEX]}"
    
    print_warning "这将覆盖当前的 OneClip 数据!"
    read -p "  确定继续? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "已取消"
        return 0
    fi
    
    print_step "恢复数据..."
    
    # 恢复数据目录
    if [[ -d "$SELECTED_BACKUP/Application Support" ]]; then
        rm -rf "$APP_SUPPORT_DIR" 2>/dev/null || true
        cp -R "$SELECTED_BACKUP/Application Support" "$APP_SUPPORT_DIR"
        print_success "数据目录已恢复"
    fi
    
    # 恢复偏好设置
    PLIST_FILE=$(find "$SELECTED_BACKUP" -name "*.plist" 2>/dev/null | head -1)
    if [[ -n "$PLIST_FILE" ]]; then
        cp "$PLIST_FILE" "$PREFERENCES_FILE" 2>/dev/null
        print_success "偏好设置已恢复"
    fi
    
    echo ""
    print_success "数据恢复完成!"
    print_info "请重新启动 OneClip"
}

# 全面诊断
full_diagnosis() {
    print_section "全面诊断"
    
    ISSUES=()
    
    check_homebrew || true
    echo ""
    get_remote_version || true
    echo ""
    check_tap
    echo ""
    check_installation
    echo ""
    check_cache
    echo ""
    check_app_data
    echo ""
    test_network
    
    # 显示诊断结果
    print_section "诊断结果"
    
    if [[ ${#ISSUES[@]} -eq 0 ]]; then
        print_success "未发现问题，一切正常!"
    else
        print_warning "发现 ${#ISSUES[@]} 个问题:"
        echo ""
        
        for issue in "${ISSUES[@]}"; do
            case "$issue" in
                "homebrew_not_installed")
                    print_error "Homebrew 未安装"
                    print_info "  解决: 选择菜单中的「安装 Homebrew」"
                    ;;
                "network_issue")
                    print_error "网络连接问题"
                    print_info "  解决: 检查网络连接或使用代理"
                    ;;
                "tap_outdated")
                    print_error "Tap 配置过期"
                    print_info "  解决: 选择「清理缓存」刷新配置"
                    ;;
                "version_outdated")
                    print_error "版本过旧"
                    print_info "  解决: 选择「升级 OneClip」"
                    ;;
                "cache_exists")
                    print_error "存在旧版本缓存"
                    print_info "  解决: 选择「清理缓存」"
                    ;;
                "github_unreachable")
                    print_error "无法连接 GitHub"
                    print_info "  解决: 检查网络或稍后重试"
                    ;;
                "download_url_invalid")
                    print_error "下载地址无效"
                    print_info "  解决: 清理缓存后重试"
                    ;;
            esac
            echo ""
        done
        
        echo ""
        if [[ "$INTERACTIVE" == "true" ]]; then
            read -p "  是否自动修复所有问题? [Y/n]: " fix_choice
            fix_choice=${fix_choice:-Y}
            
            if [[ "$fix_choice" =~ ^[Yy]$ ]]; then
                auto_fix
            fi
        else
            print_info "非交互式模式，跳过自动修复"
            print_info "请运行: ./install.sh 进入交互式模式"
        fi
    fi
}

# 自动修复
auto_fix() {
    print_section "自动修复"
    
    for issue in "${ISSUES[@]}"; do
        case "$issue" in
            "homebrew_not_installed")
                install_homebrew
                ;;
            "tap_outdated"|"cache_exists"|"download_url_invalid")
                clean_cache
                ;;
            "version_outdated")
                upgrade_oneclip
                ;;
        esac
    done
    
    echo ""
    print_success "修复完成!"
}

# ═══════════════════════════════════════════════════════════════
# 主菜单
# ═══════════════════════════════════════════════════════════════

show_main_menu() {
    print_header
    
    # 快速状态
    echo -e "  ${DIM}当前状态:${NC}"
    if [[ "$CASK_INSTALLED" == "true" ]]; then
        if [[ -n "$REMOTE_VERSION" ]] && [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
            echo -e "    OneClip: ${YELLOW}v$LOCAL_VERSION${NC} ${DIM}(最新: v$REMOTE_VERSION)${NC}"
        else
            echo -e "    OneClip: ${GREEN}v$LOCAL_VERSION${NC}"
        fi
    else
        echo -e "    OneClip: ${DIM}未安装${NC}"
    fi
    echo ""
    
    print_divider
    echo ""
    echo -e "  ${BOLD}请选择操作:${NC}"
    echo ""
    echo -e "  ${GREEN}安装/升级${NC}"
    echo "    1) 🚀 快速安装 (一键安装最新版)"
    echo "    2) ⬆️  升级到最新版本"
    echo "    3) 🔄 重新安装 (清理后安装)"
    echo ""
    echo -e "  ${YELLOW}维护${NC}"
    echo "    4) 🔧 全面诊断 (检测并修复问题)"
    echo "    5) 🧹 清理 Homebrew 缓存"
    echo "    6) 🗑️  清理应用缓存"
    echo "    7) 🌐 测试网络连接"
    echo ""
    echo -e "  ${CYAN}数据${NC}"
    echo "    8) 💾 备份数据"
    echo "    9) 📂 恢复数据"
    echo ""
    echo -e "  ${RED}卸载${NC}"
    echo "   10) ❌ 卸载 OneClip"
    echo ""
    echo -e "  ${DIM}其他${NC}"
    echo "   11) ℹ️  显示详细状态"
    echo "   12) 🍺 安装 Homebrew"
    echo "    0) 退出"
    echo ""
    print_divider
    echo ""
    read -p "  请输入选项 [0-12]: " choice
}

# 快速安装
quick_install() {
    print_header
    print_section "快速安装"
    
    ISSUES=()
    
    check_homebrew || { install_homebrew || return 1; }
    echo ""
    get_remote_version || true
    echo ""
    check_tap
    echo ""
    check_installation
    echo ""
    check_cache
    
    # 如果有缓存问题，先清理
    if [[ " ${ISSUES[*]} " =~ " cache_exists " ]] || [[ " ${ISSUES[*]} " =~ " tap_outdated " ]]; then
        echo ""
        clean_cache
    fi
    
    echo ""
    
    if [[ "$CASK_INSTALLED" == "true" ]]; then
        if [[ -n "$REMOTE_VERSION" ]] && [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
            upgrade_oneclip
        else
            print_success "已是最新版本 v$LOCAL_VERSION"
        fi
    else
        install_oneclip
    fi
    
    echo ""
    print_divider
    echo ""
    echo -e "  ${GREEN}${BOLD}安装成功!${NC}"
    echo ""
    echo -e "  在 ${CYAN}应用程序${NC} 文件夹中找到 ${BOLD}OneClip${NC} 并启动"
    echo ""
    echo -e "  官网: ${CYAN}$WEBSITE${NC}"
    echo -e "  反馈: ${CYAN}$SUPPORT_EMAIL${NC}"
    echo ""
    print_divider
}

# 显示详细状态
show_detailed_status() {
    print_header
    print_section "详细状态"
    
    ISSUES=()
    
    check_homebrew || true
    echo ""
    get_remote_version || true
    echo ""
    check_tap
    echo ""
    check_installation
    echo ""
    check_cache
    echo ""
    check_app_data
    echo ""
    test_network
    
    echo ""
    print_divider
    
    # 系统信息
    echo ""
    print_step "系统信息"
    print_substep "macOS: $(sw_vers -productVersion)"
    print_substep "架构: $(uname -m)"
    print_substep "Homebrew: $(brew --prefix)"
    
    press_any_key
}

# ═══════════════════════════════════════════════════════════════
# 主程序
# ═══════════════════════════════════════════════════════════════

main() {
    # 命令行参数处理
    case "${1:-}" in
        install|--install|-i)
            print_header
            quick_install
            exit 0
            ;;
        upgrade|--upgrade|-u)
            print_header
            check_homebrew || exit 1
            get_remote_version
            check_tap
            check_installation
            upgrade_oneclip
            exit 0
            ;;
        diagnose|--diagnose|-d)
            print_header
            full_diagnosis
            exit 0
            ;;
        clean|--clean|-c)
            print_header
            check_homebrew || exit 1
            check_tap
            clean_cache
            exit 0
            ;;
        reinstall|--reinstall|-r)
            print_header
            check_homebrew || exit 1
            get_remote_version
            check_tap
            check_installation
            reinstall_oneclip
            exit 0
            ;;
        uninstall|--uninstall)
            print_header
            check_homebrew || exit 1
            check_tap
            check_installation
            uninstall_oneclip
            exit 0
            ;;
        status|--status|-s)
            print_header
            print_section "状态检测"
            check_homebrew || true
            echo ""
            get_remote_version || true
            echo ""
            check_tap
            echo ""
            check_installation
            echo ""
            check_cache
            echo ""
            check_app_data
            echo ""
            exit 0
            ;;
        backup|--backup|-b)
            print_header
            backup_data
            exit 0
            ;;
        restore|--restore)
            print_header
            restore_data
            exit 0
            ;;
        help|--help|-h)
            echo ""
            echo "OneClip Homebrew 安装助手"
            echo ""
            echo "用法: $0 [命令]"
            echo ""
            echo "命令:"
            echo "  install, -i      快速安装"
            echo "  upgrade, -u      升级到最新版"
            echo "  diagnose, -d     全面诊断"
            echo "  clean, -c        清理缓存"
            echo "  reinstall, -r    重新安装"
            echo "  uninstall        卸载"
            echo "  status, -s       显示状态"
            echo "  backup, -b       备份数据"
            echo "  restore          恢复数据"
            echo "  help, -h         显示帮助"
            echo ""
            echo "无参数时进入交互式菜单"
            echo ""
            exit 0
            ;;
    esac
    
    # 初始化检测
    check_homebrew 2>/dev/null || true
    get_remote_version 2>/dev/null || true
    check_tap 2>/dev/null || true
    check_installation 2>/dev/null || true
    
    # 交互式菜单循环
    while true; do
        show_main_menu
        
        case "$choice" in
            1)  quick_install; press_any_key ;;
            2)  print_header; upgrade_oneclip; press_any_key ;;
            3)  print_header; reinstall_oneclip; press_any_key ;;
            4)  print_header; full_diagnosis; press_any_key ;;
            5)  print_header; check_homebrew && check_tap && clean_cache; press_any_key ;;
            6)  print_header; clean_app_cache; press_any_key ;;
            7)  print_header; print_section "网络测试"; test_network; press_any_key ;;
            8)  print_header; backup_data; press_any_key ;;
            9)  print_header; restore_data; press_any_key ;;
            10) print_header; uninstall_oneclip; press_any_key ;;
            11) show_detailed_status ;;
            12) print_header; install_homebrew; press_any_key ;;
            0)
                echo ""
                print_info "感谢使用 OneClip!"
                echo ""
                exit 0
                ;;
            *)
                print_error "无效选项"
                sleep 1
                ;;
        esac
        
        # 刷新状态
        check_tap 2>/dev/null || true
        check_installation 2>/dev/null || true
    done
}

# 运行主程序
main "$@"
