#!/usr/bin/env bash
# Dựng Snipe-IT cho đề tài R03-K06 trên máy mới.
# Chạy từ thư mục gốc của repo, sau khi đã `git checkout ktpm-baseline`.
set -euo pipefail

DC="docker compose -f dev.docker-compose.yml"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin12345!}"

echo "==> Build và khởi động 4 container"
$DC up -d --build

echo "==> Chờ MariaDB sẵn sàng"
until $DC exec -T mariadb healthcheck.sh --connect --innodb_initialized >/dev/null 2>&1; do
  sleep 3
done

echo "==> Chờ startup script chạy xong migration"
until $DC exec -T snipeit php artisan migrate:status >/dev/null 2>&1; do
  sleep 5
done

echo "==> Sinh dữ liệu demo (CSDL mới, chưa có user admin)"
$DC exec -T snipeit php artisan db:seed --force

echo "==> Đặt mật khẩu cho tài khoản admin (UserSeeder đặt mặc định là 'password')"
$DC exec -T -e ADMIN_PASSWORD="$ADMIN_PASSWORD" snipeit php artisan tinker --execute='
  $u = App\Models\User::where("username", "admin")->first();
  $u->password = Illuminate\Support\Facades\Hash::make(getenv("ADMIN_PASSWORD"));
  $u->save();'

$DC ps
echo
echo "Snipe-IT : http://localhost:8000  (admin / ${ADMIN_PASSWORD})"
echo "MailHog  : http://localhost:8025"
