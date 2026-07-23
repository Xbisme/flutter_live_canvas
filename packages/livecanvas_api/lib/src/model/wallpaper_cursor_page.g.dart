// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper_cursor_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WallpaperCursorPage _$WallpaperCursorPageFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WallpaperCursorPage',
      json,
      ($checkedConvert) {
        final val = WallpaperCursorPage(
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>?)
                ?.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
          hasMore: $checkedConvert('has_more', (v) => v as bool?),
        );
        return val;
      },
      fieldKeyMap: const {'nextCursor': 'next_cursor', 'hasMore': 'has_more'},
    );

Map<String, dynamic> _$WallpaperCursorPageToJson(
  WallpaperCursorPage instance,
) => <String, dynamic>{
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
  'next_cursor': ?instance.nextCursor,
  'has_more': ?instance.hasMore,
};
