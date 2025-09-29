#!/bin/bash

# Stable Diffusion WebUI Forge 自动安装脚本
# 基于实际遇到的问题总结的完整解决方案

set -e  # 遇到错误时退出

echo "开始安装 Stable Diffusion WebUI Forge..."

# 1. 克隆原始仓库
echo "步骤 1: 克隆 AUTOMATIC1111 仓库..."
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# 2. 配置 git 用户信息（避免后续合并时的身份错误）
echo "步骤 2: 配置 git 用户信息..."
git config user.email "user@example.com"
git config user.name "User"

# 3. 添加 forge 远程仓库
echo "步骤 3: 添加 forge 远程仓库..."
git remote add forge https://github.com/lllyasviel/stable-diffusion-webui-forge

# 4. 创建并切换到 forge 分支
echo "步骤 4: 创建 forge 分支..."
git branch lllyasviel/main

# 5. 切换到 forge 分支
echo "步骤 5: 切换到 forge 分支..."
git checkout lllyasviel/main

# 6. 获取 forge 仓库内容
echo "步骤 6: 获取 forge 仓库内容..."
git fetch forge

# 7. 设置分支跟踪
echo "步骤 7: 设置分支跟踪..."
git branch -u forge/main

# 8. 配置合并策略（避免分歧分支错误）
echo "步骤 8: 配置合并策略..."
git config pull.rebase false

# 9. 直接重置到 forge 版本（跳过复杂的合并冲突）
echo "步骤 9: 重置到 forge 版本..."
git reset --hard forge/main

# 10. 验证安装
echo "步骤 10: 验证安装..."
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
echo "当前分支: $(git branch --show-current)"
echo "跟踪分支: $(git rev-parse --abbrev-ref @{upstream})"
