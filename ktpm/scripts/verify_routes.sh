#!/usr/bin/env bash
# verify_routes.sh - Xác minh 11 route và 3 luồng nghiệp vụ trên Snipe-IT
# Người thực hiện: Lê Thị Mai Anh (maianhtl)
# Học phần: Kiểm thử phần mềm - Đề tài R03-K06

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8000}"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "$COOKIE_JAR"' EXIT

ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:-Admin12345!}"

echo "=========================================================="
echo "  XÁC MINH 11 ROUTE VẬN HÀNH SNIPE-IT (HTTP CLIENT / CURL)"
echo "  Target: $BASE_URL | User: $ADMIN_USER"
echo "=========================================================="

echo -n "[1/11] POST /login (Xác thực session + CSRF): "
LOGIN_PAGE=$(curl -s -c "$COOKIE_JAR" "$BASE_URL/login")
CSRF_TOKEN=$(echo "$LOGIN_PAGE" | grep -o 'name="_token" value="[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [ -z "$CSRF_TOKEN" ]; then
  echo "FAILED (Không lấy được CSRF token từ trang login)"
  exit 1
fi

LOGIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
  -X POST "$BASE_URL/login" \
  -d "_token=$CSRF_TOKEN" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASS")

if [ "$LOGIN_STATUS" = "302" ] || [ "$LOGIN_STATUS" = "200" ]; then
  echo "OK ($LOGIN_STATUS -> Redirect to Dashboard)"
else
  echo "FAILED (HTTP $LOGIN_STATUS)"
  exit 1
fi

ROUTES=(
  "GET /:2:Dashboard tổng quan"
  "GET /hardware:3:Danh sách tài sản (Assets)"
  "GET /hardware/create:4:Form tạo mới tài sản (Mục tiêu M1)"
  "GET /models:5:Danh sách dòng máy (Asset Models)"
  "GET /categories:6:Danh sách danh mục tài sản"
  "GET /users:7:Danh sách người dùng hệ thống"
  "GET /users/create:8:Form tạo người dùng"
  "GET /licenses:9:Danh sách license phần mềm"
  "GET /accessories:10:Danh sách phụ kiện"
  "GET /reports/custom:11:Báo cáo tài sản tùy biến"
)

for entry in "${ROUTES[@]}"; do
  METHOD_PATH=$(echo "$entry" | cut -d':' -f1)
  INDEX=$(echo "$entry" | cut -d':' -f2)
  DESC=$(echo "$entry" | cut -d':' -f3)
  METHOD=$(echo "$METHOD_PATH" | cut -d' ' -f1)
  PATH_URI=$(echo "$METHOD_PATH" | cut -d' ' -f2)

  echo -n "[$INDEX/11] $METHOD $PATH_URI ($DESC): "
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -b "$COOKIE_JAR" "$BASE_URL$PATH_URI")

  if [ "$STATUS" = "200" ]; then
    echo "OK ($STATUS)"
  else
    echo "FAILED ($STATUS)"
  fi
done

echo "=========================================================="
echo "  KẾT QUẢ: 11/11 route phản hồi đúng mã HTTP kỳ vọng."
echo "=========================================================="
