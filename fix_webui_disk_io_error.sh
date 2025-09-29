#!/bin/bash

# Stable Diffusion WebUI Disk I/O Error Fix Script
# 解决 stable-diffusion-webui 的 sqlite3.OperationalError: disk I/O error 问题
# 
# 使用方法: 
# 1. 将此脚本放在 stable-diffusion-webui 目录中
# 2. 运行: bash fix_webui_disk_io_error.sh
# 或者从任何位置运行: bash fix_webui_disk_io_error.sh /path/to/stable-diffusion-webui

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取 webui 目录路径
if [ $# -eq 1 ]; then
    WEBUI_DIR="$1"
else
    WEBUI_DIR="$(pwd)"
fi

print_info "正在修复 Stable Diffusion WebUI 的 Disk I/O 错误..."
print_info "WebUI 目录: $WEBUI_DIR"

# 检查是否在正确的目录
if [ ! -f "$WEBUI_DIR/launch.py" ]; then
    print_error "错误: 在 $WEBUI_DIR 中找不到 launch.py 文件"
    print_error "请确保你在 stable-diffusion-webui 目录中运行此脚本，或提供正确的路径"
    print_error "使用方法: bash $0 [webui_directory_path]"
    exit 1
fi

cd "$WEBUI_DIR"

# 步骤 1: 检查磁盘空间
print_info "步骤 1/4: 检查磁盘空间..."
df -h . | head -2
echo

# 检查可用空间是否足够 (至少 1GB)
available_space=$(df . | tail -1 | awk '{print $4}')
if [ "$available_space" -lt 1048576 ]; then  # 1GB in KB
    print_warning "警告: 可用磁盘空间可能不足 (< 1GB)"
fi

# 步骤 2: 定位缓存目录
print_info "步骤 2/4: 定位缓存目录..."
CACHE_DIR="$WEBUI_DIR/cache"

if [ ! -d "$CACHE_DIR" ]; then
    print_warning "缓存目录不存在: $CACHE_DIR"
    print_info "这可能意味着问题已经解决或者是首次运行"
    exit 0
fi

print_info "找到缓存目录: $CACHE_DIR"

# 步骤 3: 检查并显示损坏的缓存文件
print_info "步骤 3/4: 检查缓存文件状态..."

corrupted_files=0
for subdir in "$CACHE_DIR"/*; do
    if [ -d "$subdir" ]; then
        subdir_name=$(basename "$subdir")
        print_info "检查子目录: $subdir_name"
        
        # 列出该子目录中的数据库文件
        db_files=$(find "$subdir" -name "cache.db*" 2>/dev/null || true)
        if [ -n "$db_files" ]; then
            echo "$db_files" | while read -r file; do
                filename=$(basename "$file")
                filesize=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
                print_info "  发现文件: $filename (大小: $filesize bytes)"
            done
            corrupted_files=$((corrupted_files + 1))
        fi
    fi
done

if [ $corrupted_files -eq 0 ]; then
    print_success "没有发现缓存数据库文件，问题可能已经解决"
    exit 0
fi

# 步骤 4: 清理损坏的缓存文件
print_info "步骤 4/4: 清理损坏的缓存文件..."

# 备份选项（可选）
read -p "是否要备份现有缓存文件？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    backup_dir="$WEBUI_DIR/cache_backup_$(date +%Y%m%d_%H%M%S)"
    print_info "创建备份到: $backup_dir"
    cp -r "$CACHE_DIR" "$backup_dir"
    print_success "备份完成"
fi

# 删除所有缓存数据库文件
print_info "删除损坏的缓存数据库文件..."
find "$CACHE_DIR" -name "cache.db*" -type f -delete

# 验证清理结果
remaining_files=$(find "$CACHE_DIR" -name "cache.db*" 2>/dev/null | wc -l)
if [ "$remaining_files" -eq 0 ]; then
    print_success "所有缓存数据库文件已成功删除"
else
    print_error "警告: 仍有 $remaining_files 个缓存文件未删除"
fi

# 显示清理后的目录结构
print_info "清理后的缓存目录结构:"
ls -la "$CACHE_DIR"/*/ 2>/dev/null || print_info "缓存子目录为空"

print_success "修复完成！"
print_info "现在可以重新启动 Stable Diffusion WebUI"
print_info "应用将自动重新创建必要的缓存文件"

echo
print_info "如果问题仍然存在，请检查:"
print_info "1. 磁盘权限是否正确"
print_info "2. 磁盘是否有硬件问题"
print_info "3. 是否有其他进程在使用缓存文件"
