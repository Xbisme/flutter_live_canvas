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

    // Danh sách bộ sưu tập curated (không phân trang — chỉ meta, không nhúng items)
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
