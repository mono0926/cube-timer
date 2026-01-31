import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/history_item.dart';

part 'history_repository.g.dart';

@riverpod
HistoryRepository historyRepository(Ref ref) {
  throw UnimplementedError('Initialize with override in main');
}

class HistoryRepository {
  HistoryRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'history_items';

  List<HistoryItem> fetchItems() {
    final jsonList = _prefs.getStringList(_key) ?? [];
    return jsonList
        .map((e) => HistoryItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItem(HistoryItem item) async {
    final items = fetchItems()..insert(0, item); // Add to top
    final jsonList = items.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_key, jsonList);
  }

  Future<void> deleteItem(HistoryItem item) async {
    final items = fetchItems()..removeWhere((e) => e.id == item.id);
    final jsonList = items.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_key, jsonList);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
