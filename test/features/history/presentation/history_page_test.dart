import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/features/history/domain/history_item.dart';
import 'package:timer/features/history/domain/history_provider.dart';
import 'package:timer/features/history/presentation/history_page.dart';
import 'package:timer/features/timer/domain/timer_provider.dart';
import 'package:timer/features/timer/domain/timer_state.dart';
import 'package:timer/i18n/strings.g.dart';

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

  @override
  Future<void> updateComment(HistoryItem item, String? comment) async {
    final index = items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      items[index] = items[index].copyWith(comment: comment);
      state = AsyncValue.data(items);
    }
  }
}

void main() {
  group('HistoryPage', () {
    setUp(() {
      LocaleSettings.setLocaleSync(AppLocale.ja);
    });

    testWidgets('Edit comment', (tester) async {
      final fakeHistory = FakeHistory()
        ..items = [
          HistoryItem(
            id: 1,
            scramble: 'S',
            durationMilliseconds: 1000,
            timestamp: DateTime.now(),
          ),
        ];

      final fakeTimerController = FakeTimerController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyProvider.overrideWith(() => fakeHistory),
            timerControllerProvider.overrideWith(() => fakeTimerController),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap item
      await tester.tap(find.text('S'));
      await tester.pumpAndSettle();

      // Action Sheet should appear
      expect(find.text('結果を表示'), findsOneWidget);
      final editComment = find.text('コメントを編集');
      expect(editComment, findsOneWidget);

      // Select 'Edit Comment'
      await tester.tap(editComment);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('コメントを編集'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter comment
      await tester.enterText(find.byType(TextField), 'My best solve');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // Verify comment is updated
      expect(fakeHistory.items.first.comment, 'My best solve');
      expect(find.text('My best solve'), findsOneWidget);
    });

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

      expect(find.text('まだ履歴がありません'), findsOneWidget);
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
            comment: 'Nice',
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
      expect(find.text('05.000'), findsOneWidget);
      expect(find.text('R U R\''), findsOneWidget);

      // 10000ms -> 10.00
      expect(find.text('10.000'), findsOneWidget);
      // Comment should be displayed
      expect(find.text('Nice'), findsOneWidget);
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
      expect(find.text('履歴を削除しますか？'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      final deleteConfirm = find.text('削除');
      expect(deleteConfirm, findsOneWidget);

      // Confirm delete
      await tester.tap(deleteConfirm);
      await tester.pumpAndSettle();

      // Should handle clear (FakeHistory clears state)
      expect(find.text('まだ履歴がありません'), findsOneWidget);
    });

    testWidgets('Tap to show result', (tester) async {
      final fakeHistory = FakeHistory()
        ..items = [
          HistoryItem(
            id: 1,
            scramble: 'S',
            durationMilliseconds: 1000,
            timestamp: DateTime.now(),
          ),
        ];

      final fakeTimerController = FakeTimerController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyProvider.overrideWith(() => fakeHistory),
            timerControllerProvider.overrideWith(() => fakeTimerController),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Find the item
      final listItem = find.text('S');
      expect(listItem, findsOneWidget);

      await tester.tap(listItem);
      await tester.pumpAndSettle();

      // Action Sheet should appear
      expect(find.text('結果を表示'), findsOneWidget);
      final showResult = find.text('結果を表示');

      // Select 'Show Result'
      await tester.tap(showResult);
      await tester.pumpAndSettle();

      // Verify showHistoryResult was called
      expect(fakeTimerController.showedItem, fakeHistory.items.first);
    });
  });
}

class FakeTimerController extends AutoDisposeNotifier<TimerState>
    implements TimerController {
  HistoryItem? showedItem;

  @override
  TimerState build() {
    return const TimerState();
  }

  @override
  void showHistoryResult(HistoryItem item) {
    showedItem = item;
  }

  @override
  void handlePointerDown(int pointerId) {}

  @override
  void handlePointerUp(int pointerId) {}

  @override
  void reset() {}

  // TickerService is not used in this fake, but getter exists in real one.
  // Since we override methods utilizing it, we are safe.
}
