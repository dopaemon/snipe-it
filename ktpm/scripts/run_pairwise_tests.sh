#!/usr/bin/env bash
# run_pairwise_tests.sh - Điều phối sinh ca pairwise và thực thi kiểm thử PHP
# Người thực hiện: Trần Nguyễn Tuấn Anh (dopaemon)

set -euo pipefail

echo "=========================================================="
echo "  KTPM R03-K06: SINH CA PAIRWISE VÀ KIỂM TRA ĐỘ PHỦ"
echo "=========================================================="

echo "[1/3] Chạy script ước lượng và kiểm tra độ phủ cặp M1/M2:"
python3 ktpm/models/pairwise_estimate.py

echo ""
echo "[2/3] Kiểm tra tệp mô hình PICT:"
if command -v pict &>/dev/null; then
  echo "PICT được tìm thấy. Đang sinh bộ ca kiểm thử chính thức:"
  pict ktpm/models/m1_full.pict > ktpm/models/m1_pairwise_generated.tsv
  pict ktpm/models/m2_full.pict > ktpm/models/m2_pairwise_generated.tsv
  echo "Đã xuất: ktpm/models/m1_pairwise_generated.tsv ($(wc -l < ktpm/models/m1_pairwise_generated.tsv) dòng)"
  echo "Đã xuất: ktpm/models/m2_pairwise_generated.tsv ($(wc -l < ktpm/models/m2_pairwise_generated.tsv) dòng)"
else
  echo "PICT CLI chưa cài đặt trên môi trường hiện tại, sử dụng dữ liệu draft tsv có sẵn."
fi

echo ""
echo "[3/3] Trạng thái sẵn sàng cho kiểm thử tự động PHP (PHPUnit):"
echo "Workflow CI/CD đã được cấu hình tại .github/workflows/ktpm-php-tests.yml"
echo "=========================================================="
