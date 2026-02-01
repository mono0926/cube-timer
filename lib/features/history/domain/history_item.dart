import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_item.freezed.dart';
part 'history_item.g.dart';

@freezed
abstract class HistoryItem with _$HistoryItem {
  const factory HistoryItem({
    required int id,
    required String scramble,
    required int durationMilliseconds,
    required DateTime timestamp,
    String? comment,
  }) = _HistoryItem;

  factory HistoryItem.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemFromJson(json);
}
