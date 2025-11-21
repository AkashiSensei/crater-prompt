#!/bin/bash

# 脚本用于检查最新一个提交的改动，用于生成 PR 描述

# 禁用 git 分页器，确保所有输出直接到标准输出
export GIT_PAGER=cat

# 显示帮助信息
show_help() {
    echo "用法: $0 <仓库路径>"
    echo ""
    echo "参数:"
    echo "  仓库路径    要检查的 Git 仓库路径（必需）"
    echo ""
    echo "选项:"
    echo "  -h, --help  显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 /path/to/repo"
    echo "  $0 ../main/crater"
    echo "  $0 ."
}

# 处理命令行参数
if [ $# -eq 0 ]; then
    echo "错误: 请提供仓库路径"
    echo ""
    show_help
    exit 1
fi

# 检查是否是帮助选项
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

REPO_ROOT="$1"

# 验证目录是否存在
if [ ! -d "$REPO_ROOT" ]; then
    echo "错误: 仓库目录不存在: $REPO_ROOT"
    exit 1
fi

# 验证是否是 Git 仓库
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "错误: 指定的目录不是 Git 仓库: $REPO_ROOT"
    exit 1
fi

cd "$REPO_ROOT" || exit 1

echo "=========================================="
echo "最新提交信息"
echo "=========================================="
git --no-pager log -1 --pretty=format:"提交哈希: %H%n作者: %an <%ae>%n日期: %ad%n%n%s%n%n%b" --date=format:"%Y-%m-%d %H:%M:%S"
echo ""
echo ""

echo "=========================================="
echo "改动的文件列表"
echo "=========================================="
git --no-pager diff --name-status HEAD~1 HEAD
echo ""
echo ""

echo "=========================================="
echo "改动统计"
echo "=========================================="
git --no-pager diff --stat HEAD~1 HEAD
echo ""
echo ""

echo "=========================================="
echo "新增的文件"
echo "=========================================="
git --no-pager diff --name-status --diff-filter=A HEAD~1 HEAD | awk '{print $2}'
echo ""
echo ""

echo "=========================================="
echo "修改的文件"
echo "=========================================="
git --no-pager diff --name-status --diff-filter=M HEAD~1 HEAD | awk '{print $2}'
echo ""
echo ""

echo "=========================================="
echo "删除的文件"
echo "=========================================="
git --no-pager diff --name-status --diff-filter=D HEAD~1 HEAD | awk '{print $2}'
echo ""
echo ""

echo "=========================================="
echo "关键文件改动预览（前 50 行）"
echo "=========================================="
echo ""
for file in $(git --no-pager diff --name-only HEAD~1 HEAD | grep -E '\.(yml|yaml|go|ts|tsx|js|jsx|md)$' | head -5); do
    echo "--- 文件: $file ---"
    git --no-pager diff HEAD~1 HEAD -- "$file" | head -50
    echo ""
done

