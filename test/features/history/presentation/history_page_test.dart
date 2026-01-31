import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/features/history/domain/history_item.dart';
import 'package:timer/features/history/domain/history_provider.dart';
import 'package:timer/features/history/presentation/history_page.dart';

class FakeHistory extends AutoDisposeAsyncNotifier<List<HistoryItem>>
    implements History {
  List<HistoryItem> items = [];

  @override
  Future<List<HistoryItem>> build() async {
    return items;
  }

  // Only update state if already initialized (though for this test,
  // pre-pump setup is key)
  // state setter throws if not initialized.
  // Since build() returns items, updating items is enough for initial load.

  @override
  Future<void> add(String scramble, int duration) async {}

  @override
  Future<void> clear() async {
    items = [];
    state = const AsyncValue.data([]);
  }

  @override
  Future<void> delete(HistoryItem item) async {
    items = items.where((element) => element.id != item.id).toList();
    state = AsyncValue.data(items);
  }
}

void main() {
  group('HistoryPage', () {
    testWidgets('Empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyProvider.overrideWith(FakeHistory.new),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No solves yet'), findsOneWidget);
    });

    testWidgets('List Items display', (tester) async {
      final fakeHistory = FakeHistory()
        ..items = [
          HistoryItem(
            id: 1,
            scramble: 'R U R\'',
            durationMilliseconds: 5000,
            timestamp: DateTime(2023),
          ),
          HistoryItem(
            id: 2,
            scramble: 'F F',
            durationMilliseconds: 10000,
            timestamp: DateTime(2023, 1, 2),
          ),
        ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyProvider.overrideWith(() => fakeHistory),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Check content
      // 5000ms -> 05.00
      expect(find.text('05.00'), findsOneWidget);
      expect(find.text('R U R\''), findsOneWidget);

      // 10000ms -> 10.00
      expect(find.text('10.00'), findsOneWidget);
    });

    testWidgets('Clear button', (tester) async {
      final fakeHistory = FakeHistory()
        ..items = [
          HistoryItem(
            id: 1,
            scramble: 'S',
            durationMilliseconds: 1000,
            timestamp: DateTime.now(),
          ),
        ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyProvider.overrideWith(() => fakeHistory),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Find clear button (trash icon in app bar)
      final clearButton = find.byIcon(Icons.delete_outline);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Clear History?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      final deleteConfirm = find.text('Clear');
      expect(deleteConfirm, findsOneWidget);

      // Confirm delete
      await tester.tap(deleteConfirm);
      await tester.pumpAndSettle();

      // Should handle clear (FakeHistory clears state)
      expect(find.text('No solves yet'), findsOneWidget);
    });
  });
}
