# Restoration Specification: Stack Timer Features

ユーザーの要望に基づき、リファクタリングで失われた以下の機能を復元・再実装します。

## 1. Stack Timer Logic (挙動の復元)

タップによる開始ではなく、実際のスタッキングタイマー（Speed Stacksなど）と同様の「ホールドして開始」の挙動に戻します。

### ステートマシン

| 状態        | ユーザー操作/トリガー           | 画面表示                                          | 音声        |
| ----------- | ------------------------------- | ------------------------------------------------- | ----------- |
| **Idle**    | 初期状態                        | 文字: "タッチしてスタート"<br>色: 白/黒           | -           |
| **Holding** | 画面をタッチ(ホールド)開始      | 文字: "そのまま..."<br>色: 赤                     | -           |
| **Ready**   | 一定時間(例: 0.3秒)ホールド継続 | 文字: "よーい"<br>色: 緑 (HandPadも緑)            | `ready.mp3` |
| **Running** | 指を離す                        | 文字: "スタート"<br>色: 白/黒<br>タイマー更新開始 | `start.mp3` |
| **Stopped** | タイマー動作中に画面タッチ      | 文字: "ストップ"<br>色: 白/黒<br>タイム表示停止   | `stop.mp3`  |

### マルチタッチ処理

- 画面上のどこを触っても「ホールド」とみなします。
- 複数の指で触れても、**「少なくとも1本の指が触れている」** 状態を「ホールド中」と判定します。
- すべての指が離れた瞬間に「スタート」となります（Ready状態の場合）。

## 2. Sound Effects (効果音の復元)

`audioplayers` パッケージを使用し、`SoundProvider` を再実装します。

- **Provider**: `soundProvider` (Riverpod)
- **音源**:
  - `assets/audio/ready.mp3`: Ready状態になったとき
  - `assets/audio/start.mp3`: タイマー開始時
  - `assets/audio/stop.mp3`: タイマー停止時

**注意**: マナーモードや音量設定に配慮しつつ、アプリとしてのAudioContextを設定します。

## 3. UI Design (デザインの復元)

以前のデザイン要素を `features/timer/presentation/timer_page.dart` に再統合します。

- **StackMat Shape**: 背景にマットの形状 (`StackMatPainter`) を描画。
- **Hand Pads**: 左右に手のひらアイコン (`_HandPad`) を配置。
  - 状態に応じて色変化 (Idle: グレー, Holding: 赤, Ready: 緑)。
- **Status Text**: 状態に応じたテキスト表示の復元。
- **Reset Button**: 停止時のみ表示。

## 実装計画

### Phase 1: Sound Provider Restoration

- `lib/core/sound/sound_provider.dart` を作成。
- `assets/audio/` の存在確認 (pubspec.yamlは設定済み)。

### Phase 2: Timer Logic Update

- `TimerState` に `status` (Idle, Holding, Ready, Running, Stopped) を追加。
- `TimerController` に `handlePointerDown`, `handlePointerUp` を追加。
- タイマー計測ロジックをホールドベースに変更。

### Phase 3: UI Integration

- `TimerPage` を `GestureDetector` (onTap) から `Listener` (onPointer\*) ベースに変更。
- `StackMatPainter`, `_HandPad` Widgetの復活。
- アニメーションと配色の調整。
