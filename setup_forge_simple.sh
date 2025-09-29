#!/bin/bash

# Stable Diffusion WebUI Forge 简化安装脚本
# 直接克隆 forge 仓库，避免所有合并冲突

set -e  # 遇到错误时退出

echo "开始安装 Stable Diffusion WebUI Forge (简化版)..."

# 直接克隆 forge 仓库
echo "克隆 Stable Diffusion WebUI Forge 仓库..."
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git stable-diffusion-webui-forge

cd stable-diffusion-webui-forge

# 配置 git 用户信息
echo "配置 git 用户信息..."
git config user.email "user@example.com"
git config user.name "User"

# 验证安装
echo "验证安装..."
echo "当前版本信息："
git log --oneline -3

echo ""
echo "✅ Stable Diffusion WebUI Forge 安装完成！"
echo ""
echo "接下来你可以："
echo "1. 运行 ./webui.sh 启动 WebUI"
echo "2. 或者先安装依赖: pip install -r requirements_versions.txt"
echo ""
echo "当前目录: $(pwd)"
