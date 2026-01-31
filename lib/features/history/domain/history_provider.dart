import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/history_repository.dart';
import 'history_item.dart';

part 'history_provider.g.dart';

@riverpod
class History extends _$History {
  @override
  Future<List<HistoryItem>> build() async {
    final repository = ref.watch(historyRepositoryProvider);
    return repository.fetchItems();
  }

  Future<void> add(String scramble, int duration) async {
    final repository = ref.read(historyRepositoryProvider);
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch,
      scramble: scramble,
      durationMilliseconds: duration,
      timestamp: DateTime.now(),
    );
    await repository.addItem(item);

    // Refresh local state
    state = AsyncValue.data(repository.fetchItems());
  }

  Future<void> delete(HistoryItem item) async {
    final repository = ref.read(historyRepositoryProvider);
    await repository.deleteItem(item);
    state = AsyncValue.data(repository.fetchItems());
  }

  Future<void> clear() async {
    final repository = ref.read(historyRepositoryProvider);
    await repository.clear();
    state = const AsyncValue.data([]);
  }
}
