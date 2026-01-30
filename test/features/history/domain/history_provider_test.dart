import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/features/history/data/history_repository.dart';
import 'package:timer/features/history/domain/history_provider.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        historyRepositoryProvider.overrideWithValue(HistoryRepository(prefs)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('HistoryProvider', () {
    test('Initial state is empty', () async {
      final history = await container.read(historyProvider.future);
      expect(history, isEmpty);
    });

    test('Add item adds to list and persists', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.add('R U R\' U\'', 1234);

      final history = await container.read(historyProvider.future);
      expect(history.length, 1);
      expect(history.first.scramble, 'R U R\' U\'');
      expect(history.first.durationMilliseconds, 1234);

      // Check persistence
      final stored = prefs.getStringList('history_items');
      expect(stored, isNotNull);
      expect(stored!.length, 1);
    });

    test('Add item inserts at top', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.add('First', 1000);
      await notifier.add('Second', 2000);

      final history = await container.read(historyProvider.future);
      expect(history.length, 2);
      expect(history.first.scramble, 'Second');
      expect(history.last.scramble, 'First');
    });

    test('Clear removes all items', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.add('Test', 1000);
      expect(await container.read(historyProvider.future), isNotEmpty);

      await notifier.clear();

      final history = await container.read(historyProvider.future);
      expect(history, isEmpty);
      expect(prefs.getStringList('history_items'), isNull);
    });
  });
}
