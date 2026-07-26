# Phase 1 Data Model — Favorites & Local Data (MO-004)

## Entities

### Favorite
Đại diện một wallpaper người dùng đã lưu. **Chỉ persist ID** (Principle IX).

| Thuộc tính | Kiểu | Ghi chú |
|---|---|---|
| `wallpaperId` | `int` | Khóa. Là id của `Wallpaper` từ contract. |
| *(thứ tự)* | ngầm | Suy từ vị trí trong danh sách lưu (mới thêm → cuối; hiển thị đảo mới-trước). |

- Không lưu title/thumbnail/premium — luôn lấy tươi qua batch.
- Nguồn sự thật runtime: `Set<int>` in-memory trong `FavoritesRepository`, đồng bộ với store.

### DownloadHistoryEntry
Đại diện một lần tải hoàn tất.

| Thuộc tính | Kiểu | Ghi chú |
|---|---|---|
| `wallpaperId` | `int` | Khóa (mỗi wallpaper tối đa 1 mục). |
| `downloadedAt` | `DateTime` | Thời điểm tải gần nhất (ISO8601 khi lưu). |

- Model Dart: `class DownloadHistoryEntry extends Equatable { final int wallpaperId; final DateTime downloadedAt; }`.
- Ghi lại cùng id → cập nhật `downloadedAt` và đưa lên đầu (không tạo trùng — FR-014).

### Wallpaper (tham chiếu, không persist)
Lấy tươi theo id qua `POST /wallpapers/batch`; schema từ `livecanvas_api` (contract v0.4.0). Dùng render lưới Favorites + Download History.

## Storage Schema (`shared_preferences`, xem [contracts/local-storage.md](contracts/local-storage.md))

| Key | Kiểu value | Nội dung |
|---|---|---|
| `favorites.ids.v1` | `List<String>` | id wallpaper (chuỗi), thứ tự = thứ tự thêm. |
| `download_history.entries.v1` | `List<String>` | mỗi phần tử JSON `{"id":<int>,"at":"<ISO8601>"}`, thứ tự = mới-tải-trước. |

- Hậu tố `.v1` cho phép migration về sau (Principle XIV: chưa cần migration logic bây giờ).
- Chỉ dữ liệu không nhạy cảm (Principle IX).

## State Shapes (Principle III — sealed 4-state, native sealed class + Equatable)

### FavoritesState
```
sealed FavoritesState
├── FavoritesInitial
├── FavoritesLoading                         // batch đang chạy (skeleton lưới)
├── FavoritesLoaded(List<Wallpaper> items)   // đã reconcile; items rỗng ⇒ empty state
└── FavoritesError(AppFailure failure)        // batch thất bại — FailureView retry (KHÔNG prune)
```
- `FavoritesLoaded` với `items` rỗng → UI hiển thị `EmptyState` (heart) chứ không phải state riêng (giữ 4-state).
- Cubit lắng nghe `FavoritesRepository.watchIds()`: khi tập id đổi (toggle/prune) → tính lại items hiển thị (bỏ tối thiểu I/O: nếu chỉ 1 id bị bỏ, có thể lọc khỏi `items` hiện có mà không cần batch lại).

### DownloadHistoryState
```
sealed DownloadHistoryState
├── DownloadHistoryInitial
├── DownloadHistoryLoading
├── DownloadHistoryLoaded(List<Wallpaper> items)   // theo thứ tự entry mới-trước; rỗng ⇒ empty
└── DownloadHistoryError(AppFailure failure)
```

## Flows

### Mở tab Favorites (US2 + US3)
```
FavoritesPage → FavoritesCubit.load()
  ids = FavoritesRepository.currentIds (thứ tự thêm, đảo mới-trước)
  if ids empty → FavoritesLoaded([])            // empty state
  chunks = ids.chunked(100)
  results = await Future.wait(chunks.map(batch))  // Result<List<Wallpaper>>
  if any Err → FavoritesError(failure)            // KHÔNG prune (FR-011)
  else:
    returned = flatten(results) giữ thứ tự ids
    missing = ids - returned.ids
    if missing not empty → FavoritesRepository.prune(missing)  // reconcile (FR-010)
    → FavoritesLoaded(returned)
```

### Toggle tim (US1, FR-004/FR-005)
```
onFav(id) → FavoritesRepository.toggle(id)
  set = {...current}; set.contains(id) ? set.remove(id) : set.add(id)
  emit stream(set)             // tức thời (<100ms) — mọi màn cập nhật
  haptic.selectionClick()       // Principle VII
  unawaited(store.write(set))   // I/O nền, last-write-wins
```
- Ở màn Favorites, bỏ tim một mục → stream đổi → cubit gỡ mục khỏi `items` ngay (không cần batch lại).

### Ghi lịch sử tải (US4, FR-012/FR-014) — MO-005 gọi
```
DownloadHistoryRepository.record(id)
  entries = read(); remove any entry with same id
  entries.insertFront({id, now})
  write(entries) → Result<void>
```

### Mở màn Download History (US4)
```
DownloadHistoryPage → DownloadHistoryCubit.load()
  entries = repo.read() (mới-trước)
  ids = entries.map(id)
  giống flow Favorites: chunk batch + reconcile (FR-015) → DownloadHistoryLoaded(items)
```

## Validation Rules
- `batch` id list: 1..100 mỗi request (server VALIDATION_ERROR nếu rỗng/`>100`) → client chunk & không gọi khi rỗng.
- Reconcile chỉ khi toàn bộ request thành công.
- Download history: unique theo `wallpaperId`; `downloadedAt` không tương lai.
