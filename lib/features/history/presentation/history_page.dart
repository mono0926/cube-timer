import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../i18n/strings.g.dart';
import '../../history/domain/history_item.dart';
import '../../history/domain/history_provider.dart';
import '../../timer/domain/timer_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  String _formatTime(int milliseconds) {
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final centis = (milliseconds % 1000).toString().padLeft(3, '0');
    if (milliseconds < 60000) {
      return '$seconds.$centis';
    }
    return '$minutes:$seconds.$centis';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.history.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t.history.clearConfirm.title),
                  content: Text(t.history.deleteConfirm.content),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(t.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        t.clear,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(historyProvider.notifier).clear();
              }
            },
          ),
        ],
      ),
      body: history.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  Center(
                    child: Text(
                      t.history.noSolves,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: theme.colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.delete,
                    color: theme.colorScheme.onError,
                  ),
                ),
                onDismissed: (_) {
                  ref.read(historyProvider.notifier).delete(item);
                },
                child: ListTile(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.timer_outlined),
                                title: Text(t.history.menu.showResult),
                                subtitle: Text(t.history.menu.showResultDesc),
                                onTap: () {
                                  Navigator.pop(context);
                                  ref
                                      .read(timerControllerProvider.notifier)
                                      .showHistoryResult(item);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.comment_outlined),
                                title: Text(t.history.menu.editComment),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showEditCommentDialog(context, ref, item);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(t.history.deleteConfirm.title),
                        content: Text(
                          'Time: ${_formatTime(item.durationMilliseconds)}\n'
                          '${item.scramble}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(t.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              t.delete,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(historyProvider.notifier).delete(item);
                    }
                  },
                  leading: Text(
                    '${items.length - index}.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  title: Text(
                    _formatTime(item.durationMilliseconds),
                    style: theme.textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.comment != null && item.comment!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            item.comment!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        item.scramble,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      Text(
                        _formatDate(item.timestamp),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showEditCommentDialog(
    BuildContext context,
    WidgetRef ref,
    HistoryItem item,
  ) async {
    final controller = TextEditingController(text: item.comment);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.history.dialog.editComment.title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: t.history.dialog.editComment.hint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.save),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(historyProvider.notifier)
          .updateComment(item, controller.text);
    }
  }
}
