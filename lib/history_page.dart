import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String threeDigits(int n) => n.toString().padLeft(3, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final millis = threeDigits(
      duration.inMilliseconds.remainder(1000),
    ).substring(0, 2);
    return "$minutes:$seconds.$millis";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('履歴の全削除'),
                  content: const Text('本当に全ての履歴を削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('削除'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(historyProvider.notifier).clear();
              }
            },
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) => history.isEmpty
            ? const Center(child: Text('まだ履歴がありません'))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final timeMs = int.tryParse(history[index]) ?? 0;
                  return Dismissible(
                    key: Key(history[index] + index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref.read(historyProvider.notifier).delete(index);
                    },
                    child: ListTile(
                      leading: Text(
                        '#${history.length - index}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      title: Text(
                        _formatDuration(timeMs),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
      ),
    );
  }
}
