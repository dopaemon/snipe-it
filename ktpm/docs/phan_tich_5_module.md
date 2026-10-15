# Phân tích 5 Module Mục tiêu và Không gian Tổ hợp

**Người phụ trách:** Nguyễn Ngọc Hân (`@Ericismee` - MSSV: 2312607)  
**Học phần:** Kiểm thử phần mềm - Đề tài R03-K06

---

## 1. Danh sách 5 Module mục tiêu kiểm thử Pairwise

| # | Module | Đường dẫn mã nguồn chính | Lý do lựa chọn cho Pairwise |
|---|---|---|---|
| 1 | **Assets** | `app/Http/Controllers/Assets/AssetsController.php` | Nghiệp vụ trung tâm, form tạo mới có trên 8 trường tham số độc lập tác động qua lại. |
| 2 | **AssetModel** | `app/Http/Controllers/AssetModelsController.php` | Định nghĩa mối liên kết giữa Category, Manufacturer và Custom Fieldset. |
| 3 | **Checkoutable Policy** | `app/Policies/CheckoutablePermissionsPolicy.php` | Kiểm soát phân quyền đa hình (User, Location, Asset) dùng chung cho 5 loại tài sản. |
| 4 | **Users & FMCS** | `app/Models/User.php`, `app/Policies/UserPolicy.php` | Không gian tổ hợp lớn nhất: Role x Company x Specific Permissions x FMCS. |
| 5 | **Custom Fields** | `app/Livewire/CustomFieldEditor.php`, `app/Models/CustomField.php` | Các trường động có nhiều kiểu dữ liệu (text, list, date, checkbox) kèm luật validation. |

---

## 2. Tính toán Không gian Tổ hợp (Combinatorial Explosion)

### 2.1. Không gian vét cạn từ dữ liệu thực tế (Form tạo Asset)
Khi chưa phân hoạch tương đương, số lượng giá trị trong CSDL demo là:
- Company: 111
- Category: 20
- Model: 18
- Status: 7
- Location: 21
- Supplier: 26

Tích Descartes vét cạn:
$$111 \times 20 \times 18 \times 7 \times 21 \times 26 \approx 1.527.000.000 \text{ ca kiểm thử}$$
Việc thực thi vét cạn là bất khả thi trong thực tế.

### 2.2. Sau khi Phân hoạch Tương đương (Equivalence Partitioning)
Nhóm quy về các lớp giá trị đại diện:
- **Mô hình M1 (8 tham số):**
  - Company: 3 giá trị
  - Model: 3 giá trị
  - Status: 4 giá trị
  - Checkout: 4 giá trị
  - Location: 2 giá trị
  - Supplier: 2 giá trị
  - Cost: 3 giá trị
  - Tag: 2 giá trị
  - **Tổ hợp hợp lệ sau ràng buộc:** 1.512 tổ hợp.
  - **Sinh Pairwise (2-way):** 20 ca kiểm thử (giảm 98,7% số ca).

- **Mô hình M2 (5 tham số):**
  - VaiTro: 3 giá trị
  - FMCS: 2 giá trị
  - CongTy: 2 giá trị
  - LoaiDT: 5 giá trị
  - Dich: 3 giá trị
  - **Tổ hợp hợp lệ sau ràng buộc:** 120 tổ hợp.
  - **Sinh Pairwise (2-way):** 16 ca kiểm thử (giảm 86,7% số ca).
