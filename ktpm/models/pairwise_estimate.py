"""Ước lượng sơ bộ bộ ca pairwise cho mô hình M1, M2 và kiểm tra độ phủ cặp.

Thuật toán: liệt kê mọi tổ hợp hợp lệ (sau ràng buộc), chọn tham lam từng tổ hợp
phủ được nhiều cặp giá trị chưa phủ nhất, dừng khi mọi cặp hợp lệ đã được phủ.
Bộ ca chính thức sẽ sinh bằng Microsoft PICT (m1.pict, m2.pict) và được kiểm tra
lại độ phủ bằng chính hàm `pair_coverage` ở đây.

Chạy: python3 ktpm/models/pairwise_estimate.py
"""

from itertools import combinations, product
from pathlib import Path

HERE = Path(__file__).parent

M1 = {
    "Company": ["Trong", "CongTyCuaActor", "CongTyKhac"],
    "AssetModel": ["CoFieldsetBatBuoc", "CoFieldsetTuyChon", "KhongFieldset"],
    "Status": ["Deployable", "Pending", "Undeployable", "Archived"],
    "Checkout": ["Khong", "User", "Location", "Asset"],
    "Location": ["Trong", "CoGiaTri"],
    "Supplier": ["Trong", "CoGiaTri"],
    "PurchaseCost": ["Trong", "HopLe", "Am"],
    "SoLuongTag": ["1", "Nhieu"],
}


def m1_valid(case: dict) -> bool:
    """Chỉ trạng thái Deployable mới được checkout ngay khi tạo."""
    return case["Status"] == "Deployable" or case["Checkout"] == "Khong"


M2 = {
    "VaiTro": ["Superuser", "AdminCoQuyenCheckout", "UserKhongQuyen"],
    "FMCS": ["Bat", "Tat"],
    "QuanHeCty": ["CungCongTy", "KhacCongTy"],
    "LoaiDoiTuong": ["Asset", "License", "Accessory", "Consumable", "Component"],
    "DichCapPhat": ["User", "Location", "Asset"],
}

ALLOWED_TARGETS = {
    "Asset": {"User", "Location", "Asset"},
    "License": {"User", "Asset"},
    "Accessory": {"User", "Location", "Asset"},
    "Consumable": {"User"},
    "Component": {"Asset"},
}


def m2_valid(case: dict) -> bool:
    """Đích cấp phát phải được loại đối tượng cho phép."""
    return case["DichCapPhat"] in ALLOWED_TARGETS[case["LoaiDoiTuong"]]


def pairs(row: tuple) -> set:
    return {(i, row[i], j, row[j]) for i, j in combinations(range(len(row)), 2)}


def valid_rows(model: dict, valid) -> list:
    names = list(model)
    return [r for r in product(*model.values()) if valid(dict(zip(names, r)))]


def greedy_pairwise(model: dict, valid) -> list:
    rows = valid_rows(model, valid)
    need = set().union(*(pairs(r) for r in rows))
    suite = []
    while need:
        best = max(rows, key=lambda r: len(pairs(r) & need))
        suite.append(best)
        need -= pairs(best)
    return suite


def pair_coverage(model: dict, valid, suite: list) -> tuple:
    """Trả về (số cặp hợp lệ, số cặp bộ ca phủ được)."""
    need = set().union(*(pairs(r) for r in valid_rows(model, valid)))
    got = set().union(*(pairs(r) for r in suite)) if suite else set()
    return len(need), len(need & got)


def write_tsv(path: Path, model: dict, suite: list) -> None:
    lines = ["\t".join(model)] + ["\t".join(r) for r in suite]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def report(name: str, model: dict, valid, out: str) -> None:
    raw = 1
    for values in model.values():
        raw *= len(values)
    rows = valid_rows(model, valid)
    suite = greedy_pairwise(model, valid)
    total, covered = pair_coverage(model, valid, suite)
    write_tsv(HERE / out, model, suite)
    print(f"{name}: thô {raw}, hợp lệ {len(rows)}, pairwise {len(suite)} ca, "
          f"phủ {covered}/{total} cặp, giảm {100 * (1 - len(suite) / len(rows)):.1f}% -> {out}")


if __name__ == "__main__":
    report("M1", M1, m1_valid, "m1_pairwise_draft.tsv")
    report("M2", M2, m2_valid, "m2_pairwise_draft.tsv")
