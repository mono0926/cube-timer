import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_item.freezed.dart';

@freezed
abstract class TriviaItem with _$TriviaItem {
  const factory TriviaItem({
    required String content,
    required String category, // e.g., History, Hardware, Record, Technique
    String? source, // Optional source or extra context
  }) = _TriviaItem;
}
