# Cube Timer アプリケーション仕様書

## 概要

ルービックキューブ（スピードキュービング）およびスポーツスタッキング用のタイマーアプリ。
実機のスタッキングタイマー（Speed Stacks等）の挙動を模した操作性と、モダンでプレミアムなデザインを特徴とする。

## 技術スタック

- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: Feature-first, Riverpod Generator
- **State Management**: generic_riverpod (Riverpod)
- **Navigation**: GoRouter (Typed Routes)
- **Data Model**: Freezed
- **Persistence**: SharedPreferences

## 機能仕様

### 1. タイマー機能 (Timer Feature)

#### 1.1 **操作ロジック (Stack Timer)**

実機のタイマーと同様の「ホールドして開始」するステートマシンを採用。

| 状態 (State) | 画面表示テキスト     | 色 (Text/Pad)          | トリガー/動作                                                              | 音声        | 触覚 (Haptic) |
| ------------ | -------------------- | ---------------------- | -------------------------------------------------------------------------- | ----------- | ------------- |
| **Idle**     | "タッチしてスタート" | Default (白/黒) / Grey | 初期状態。画面タッチで `Holding` へ遷移。                                  | -           | Light Impact  |
| **Holding**  | "そのまま..."        | Red                    | 指を置いている間。0.3秒経過で `Ready` へ遷移。途中で離すと `Idle` へ戻る。 | -           | -             |
| **Ready**    | "よーい"             | Green                  | 計測準備完了。指を離した瞬間に `Running` へ遷移。                          | `ready.mp3` | Medium Impact |
| **Running**  | "スタート"           | Default (Glow)         | 計測中。画面タップで `Stopped` へ遷移。                                    | `start.mp3` | Heavy Impact  |
| **Stopped**  | "ストップ"           | Default                | 計測終了。リセットボタンで `Idle` へ戻る。                                 | `stop.mp3`  | Heavy Impact  |

#### 1.2 **入力制御 (Multi-touch)**

- **Listener Widget** を使用し、ポインターイベントを直接制御。
- **マルチタッチ対応**:
  - 画面上の任意の場所、複数の指でのタッチを「ホールド」として認識。
  - 複数の指がある場合、**すべての指が離れた瞬間**に計測を開始する。
  - 計測中 (`Running`) は、指が1本でも触れると即座に停止する。

#### 1.3 **UI/デザイン**

- **StackMat Design**: 背景に競技用マットを模した曲線の形状 (`StackMatPainter`) を描画。
- **Hand Pads**: 画面下部左右に手のひらアイコンを配置。状態 (`Holding`, `Ready`) に応じて色が変化し、ユーザーにフィードバックを与える。
- **Timer Display**:
  - 計測中は「分:秒.ミリ秒」形式で表示。
  - `Running` 中はテキストにGlow（発光）エフェクトとアニメーションを適用。
- **Scramble**: 画面上部にスクランブル（崩し手順）を表示。計測完了ごとに新しい手順を自動生成。

#### 1.4 **サウンド**

- 状態遷移時に効果音を再生。
- `audioplayers` パッケージを使用。

### 2. 履歴機能 (History Feature)

- **記録**: タイマー停止時に、タイム、スクランブル、日時を自動保存。
- **一覧表示**: 履歴画面 (`/history`) にて過去の記録をリスト表示。
- **削除**:
  - 個別削除機能（スワイプまたはメニュー）。
  - 全削除機能（確認ダイアログ付き）。
- **永続化**: アプリを再起動してもデータが保持される (`SharedPreferences`)。

### 3. アプリ全体設定

- **テーマ**:
  - Material 3 デザイン準拠。
  - システムのライト/ダークモード設定に自動追従。
  - Google Fonts (`Outfit`, `Chivo Mono`, `Audiowide`) を使用したプレミアムなタイポグラフィ。

## ディレクトリ構造 (Core Architecture)

```
lib/
├── core/
│   ├── router/       # GoRouter設定
│   ├── sound/        # SoundController
│   ├── theme/        # AppTheme (Light/Dark)
│   └── utils/        # Logger, ScrambleGenerator
├── features/
│   ├── history/      # History Feature (Data/Domain/Presentation)
│   └── timer/        # Timer Feature (Data/Domain/Presentation)
├── app.dart          # Root Widget
└── main.dart         # Entry Point
```
