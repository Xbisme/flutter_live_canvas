import 'package:test/test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// tests for PublicApi
void main() {
  final instance = LivecanvasApi().getPublicApi();

  group(PublicApi, () {
    // Danh sách category (không phân trang — số lượng nhỏ, admin curate)
    //
    //Future<List<Category>> categoriesGet() async
    test('test categoriesGet', () async {
      // TODO
    });

    // Danh sách bộ sưu tập curated (không phân trang — chỉ meta, không nhúng items). v0.7.0 KHÔNG đổi payload này: `show_on_home`/`home_position` là input phía admin, không xuất hiện ở đây.
    //
    //Future<List<Collection>> collectionsGet() async
    test('test collectionsGet', () async {
      // TODO
    });

    // Chi tiết 1 bộ sưu tập + danh sách wallpaper thành viên (đúng thứ tự, không phân trang)
    //
    //Future<CollectionDetail> collectionsIdGet(int id) async
    test('test collectionsIdGet', () async {
      // TODO
    });

    // (v0.7.0) Màn Browse dạng section curated. KHÔNG phân trang, bounded cứng: tối đa 10 section × tối đa 10 wallpaper/section. Trần áp LÚC ĐỌC — admin bật dư thì phần dư bị bỏ qua im lặng (không lỗi, không chặn admin lúc ghi). Section sắp theo `home_position` tăng dần, trùng vị trí thì tie-break theo id nên thứ tự ổn định giữa các request. Chỉ chứa wallpaper published; section không còn wallpaper nào hiển thị được thì bị bỏ hẳn khỏi mảng VÀ không chiếm slot (section kế tiếp lấp vào). Chưa bật collection nào → `sections: []` + 200 (KHÔNG phải 404). \"Xem tất cả\" của 1 section = gọi `GET /collections/{collection_id}` đã có. Không nhận và không đọc `transaction_id` — premium chỉ hiển thị badge, gate vẫn ở `download-url`.
    //
    //Future<HomeResponse> homeGet() async
    test('test homeGet', () async {
      // TODO
    });

    // Danh sách tag curated (không phân trang — dùng cho filter chips + admin chọn)
    //
    // Trả toàn bộ tag curated. Phần tử ĐẦU TIÊN luôn là tag ảo \"Tất cả\" (id=0, slug=\"all\", wallpaper_count = tổng wallpaper published) do API sinh — không lưu DB. Client render nó làm chip mặc định; chọn nó = gọi GET /wallpapers không truyền `tags`.
    //
    //Future<List<Tag>> tagsGet() async
    test('test tagsGet', () async {
      // TODO
    });

    // Lấy lại data mới nhất cho nhiều wallpaper theo ID (dùng cho màn Favorites)
    //
    //Future<List<Wallpaper>> wallpapersBatchPost(WallpaperBatchRequest wallpaperBatchRequest) async
    test('test wallpapersBatchPost', () async {
      // TODO
    });

    // Danh sách wallpaper — cursor pagination, filter category/tags/orientation/search
    //
    //Future<WallpaperCursorPage> wallpapersGet({ String cursor, int limit, String category, String tags, String orientation, String search, bool isPremium }) async
    test('test wallpapersGet', () async {
      // TODO
    });

    // Presigned URL thật — hết hạn ≤5 phút, chỉ 1 object. Domain là S3/R2 endpoint, KHÁC domain CDN của thumbnail/preview. Free → 200 luôn. Premium (v0.5.0): cần `transaction_id` resolve tới entitlement đang active/in_grace_period → 200; thiếu/hết hạn/không entitled → 402. Wallpaper processing/failed/đã xóa → 404 (đánh giá trước gate entitlement).
    //
    //Future<DownloadUrlResponse> wallpapersIdDownloadUrlGet(int id, { String transactionId }) async
    test('test wallpapersIdDownloadUrlGet', () async {
      // TODO
    });

    //Future<Wallpaper> wallpapersIdGet(int id) async
    test('test wallpapersIdGet', () async {
      // TODO
    });
  });
}
