#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STRINGS_DIR="$ROOT_DIR/ios/Vitora/Resources"

if [[ ! -d "$STRINGS_DIR" ]]; then
  echo "Missing resources directory: $STRINGS_DIR" >&2
  exit 1
fi

restricted_patterns=(
  "治愈"
  "保证效果"
  "诊断为"
  "治疗方案"
  "必须授权"
  "必须完成"
  "连续天数"
  "完成率"
  "红点"
  "全知"
  "绝对正确"
  "限时购买"
  "促销"
)

status=0
for pattern in "${restricted_patterns[@]}"; do
  if /usr/bin/grep -RIn --include='*.strings' "$pattern" "$STRINGS_DIR"; then
    status=1
  fi
done

if [[ "$status" -ne 0 ]]; then
  echo "Restricted expression scan failed." >&2
  exit "$status"
fi

echo "Restricted expression scan passed for localized strings."
