// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeResponse _$HomeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HomeResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['sections']);
      final val = HomeResponse(
        sections: $checkedConvert(
          'sections',
          (v) => (v as List<dynamic>)
              .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HomeResponseToJson(HomeResponse instance) =>
    <String, dynamic>{
      'sections': instance.sections.map((e) => e.toJson()).toList(),
    };
