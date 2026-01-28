import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'history_provider.g.dart';

@riverpod
class History extends _$History {
  @override
  FutureOr<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('history') ?? [];
  }

  Future<void> add(int milliseconds) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = state.value ?? [];
    final newList = [milliseconds.toString(), ...currentList];
    await prefs.setStringList('history', newList);
    state = AsyncValue.data(newList);
  }

  Future<void> delete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = [...?state.value];
    if (index < 0 || index >= currentList.length) return;

    currentList.removeAt(index);
    await prefs.setStringList('history', currentList);
    state = AsyncValue.data(currentList);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    state = const AsyncValue.data([]);
  }
}
