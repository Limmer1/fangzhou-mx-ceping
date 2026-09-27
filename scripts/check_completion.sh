#!/bin/bash
# 方舟模型众测 检查点验证脚本
# 用法：bash scripts/check_completion.sh
# 说明：验证各步骤是否完成，确认后删除临时文件 .check_status（不是删脚本本身）

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATUS_FILE="$SCRIPT_DIR/.check_status"

EXPECTED_CHECKS=(
  "TASK_DESIGNED"
  "DOWNLOAD_DONE"
  "UNZIP_DONE"
  "ENV_READY"
  "TEST_DONE"
  "SCORING_DONE"
  "REPORT_DONE"
  "SUMMARY_DONE"
)

if [ ! -f "$STATUS_FILE" ]; then
  echo "❌ 检查失败：.check_status 文件不存在，没有任何步骤完成标记"
  exit 1
fi

MISSING=()
for check in "${EXPECTED_CHECKS[@]}"; do
  if ! grep -q "^$check$" "$STATUS_FILE"; then
    MISSING+=("$check")
  fi
done

echo "=== 方舟模型众测 检查点验证 ==="
echo ""

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ 所有检查点通过（${#EXPECTED_CHECKS[@]}/${#EXPECTED_CHECKS[@]}）"
else
  PASSED=$((${#EXPECTED_CHECKS[@]} - ${#MISSING[@]}))
  echo "⚠️ 检查点未全部通过（$PASSED/${#EXPECTED_CHECKS[@]}）"
  echo ""
  echo "缺失项："
  for m in "${MISSING[@]}"; do
    case "$m" in
      TASK_DESIGNED) echo "  ❌ 步骤1：任务设计未完成" ;;
      DOWNLOAD_DONE) echo "  ❌ 步骤2：产物未下载" ;;
      UNZIP_DONE) echo "  ❌ 步骤3：解压未完成" ;;
      ENV_READY) echo "  ❌ 步骤4：验证环境未准备" ;;
      TEST_DONE) echo "  ❌ 步骤5：测试未完成" ;;
      SCORING_DONE) echo "  ❌ 步骤6：评分未完成" ;;
      REPORT_DONE) echo "  ❌ 步骤7：报告未生成" ;;
      SUMMARY_DONE) echo "  ❌ 步骤8：汇总未完成" ;;
      *) echo "  ❌ $m" ;;
    esac
  done
fi

echo ""

# 评分完整性检查提醒
if grep -q "^SCORING_DONE$" "$STATUS_FILE" 2>/dev/null; then
  echo "--- 评分完整性检查 ---"
  echo "请确认："
  echo "  - [ ] 产物质量和执行过程均按平台 1–10 分标准评分"
  echo "  - [ ] 圈选评论使用与任务类型匹配的真实证据位置"
  echo "  - [ ] 模型顺序与编号文件夹一致"
  echo "  - [ ] 评价用大白话写，对着截图文件名"
  echo ""
fi

# 确认后才删除临时文件（删的是 .check_status，不是本脚本）
echo "---"
echo "即将删除临时文件：$STATUS_FILE"
echo "（注意：只删 .check_status 临时标记文件，不删其他任何文件）"
read -p "确认删除？(y/n): " confirm
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
  rm -f "$STATUS_FILE"
  echo "✅ 临时文件 .check_status 已删除"
else
  echo "⏭️ 跳过删除，.check_status 保留"
fi
