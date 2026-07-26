# Contract — Local Storage Schema (MO-004)

Backend `shared_preferences` (`SharedPreferencesAsync`). Chỉ dữ liệu **không nhạy cảm** (Principle IX). `transaction_id` KHÔNG ở đây (secure storage, MO-006).

## Keys

### `favorites.ids.v1` — `List<String>`
- Mỗi phần tử = `wallpaperId.toString()`.
- **Thứ tự = thứ tự thêm** (append khi favorite). Hiển thị mới-trước = `reversed`.
- Ví dụ: `["101", "205", "310"]`.
- Ghi: last-write-wins từ set in-memory của `FavoritesRepository` (giữ thứ tự cũ + append id mới).

### `download_history.entries.v1` — `List<String>`
- Mỗi phần tử = JSON `{"id": <int>, "at": "<ISO8601>"}`.
- **Thứ tự = mới-tải-trước** (insert front khi `record`).
- Unique theo `id`: `record(id)` xóa entry cũ cùng id rồi chèn đầu.
- Ví dụ phần tử: `{"id":101,"at":"2026-07-26T09:15:00.000Z"}`.

## Quy tắc
- Hậu tố version `.v1`: nếu đổi format sau này → key mới `.v2` + migration; hiện chưa cần (YAGNI).
- Đọc lỗi/parse hỏng 1 phần tử → bỏ qua phần tử đó (không sập app), không xóa cả key.
- `prune(ids)`: lọc bỏ id khỏi list rồi ghi lại.
- Không lưu bất kỳ field wallpaper nào ngoài id + timestamp.

## DI
`@module LocalDataModule { @lazySingleton Future<SharedPreferencesAsync> ... }` hoặc cung cấp instance đồng bộ `SharedPreferencesAsync()` (API mới không cần `getInstance` await). Store nhận instance qua constructor injection.
