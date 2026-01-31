import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'trivia_item.dart';

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  return TriviaRepository();
});

class TriviaRepository {
  final Random _random = Random();

  final List<TriviaItem> _data = const [
    // --- History ---
    TriviaItem(
      category: 'History',
      content: 'ルービックキューブは1974年にエルノー・ルービックによって発明されました。',
    ),
    TriviaItem(
      category: 'History',
      content: '当初の名前は「マジック・キューブ (Magic Cube)」でした。',
    ),
    TriviaItem(
      category: 'History',
      content: '最初の世界大会は1982年にハンガリーのブダペストで開催されました。優勝タイムは22.95秒でした。',
    ),

    // --- Hardware (Recent) ---
    TriviaItem(
      category: 'Hardware',
      content: 'GAN 14 MagLevは、磁力による浮遊感と自動整列機能を極限まで高めたモデルです。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: 'MoYu WeiLong WRM V9は、その圧倒的な磁力と柔軟性で多くのスピードキューバーに愛用されています。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: 'スマートキューブを使えば、Bluetoothでスマホと接続し、リアルタイムで回転を分析できます。',
    ),

    // --- Records (Subject to change, but good for trivia) ---
    TriviaItem(
      category: 'Record',
      content: '3x3の単発世界記録は、Max Parkによる3.13秒です(2023年)。',
    ),
    TriviaItem(
      category: 'Record',
      content: '目隠し競技(3x3 BLD)の世界記録は12秒台に突入しています。',
    ),
    TriviaItem(
      category: 'Record',
      content: '足で揃える競技(With Feet)は、かつて公式種目でしたが現在は廃止されています。',
    ),

    // --- Knowledge ---
    TriviaItem(
      category: 'Knowledge',
      content: 'ルービックキューブの配色は、一般的に「白の反対が黄色」「赤の反対がオレンジ」「青の反対が緑」です。',
    ),
    TriviaItem(
      category: 'Knowledge',
      content: '「God\'s Number (神の数字)」とは、どんな配置からでも最短20手以内で揃えられるという証明のことです。',
    ),
    TriviaItem(
      category: 'Knowledge',
      content: 'CFOPメソッド（Fridrichメソッド）は、現在最も普及している解法の一つです。',
    ),
  ];

  TriviaItem fetchRandomTrivia() {
    return _data[_random.nextInt(_data.length)];
  }
}
