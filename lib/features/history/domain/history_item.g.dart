// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryItem _$HistoryItemFromJson(Map<String, dynamic> json) => _HistoryItem(
  id: (json['id'] as num).toInt(),
  scramble: json['scramble'] as String,
  durationMilliseconds: (json['durationMilliseconds'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$HistoryItemToJson(_HistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scramble': instance.scramble,
      'durationMilliseconds': instance.durationMilliseconds,
      'timestamp': instance.timestamp.toIso8601String(),
    };
