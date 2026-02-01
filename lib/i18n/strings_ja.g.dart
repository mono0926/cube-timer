///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsJa extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsJa _root = this; // ignore: unused_field

	@override 
	TranslationsJa $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsJa(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'キューブタイマー';
	@override String get cancel => 'キャンセル';
	@override String get delete => '削除';
	@override String get clear => '削除';
	@override String get save => '保存';
	@override String get ok => 'OK';
	@override late final _TranslationsStatusJa status = _TranslationsStatusJa._(_root);
	@override late final _TranslationsMessagesJa messages = _TranslationsMessagesJa._(_root);
	@override late final _TranslationsHistoryJa history = _TranslationsHistoryJa._(_root);
	@override late final _TranslationsTriviaJa trivia = _TranslationsTriviaJa._(_root);
	@override late final _TranslationsTimerJa timer = _TranslationsTimerJa._(_root);
}

// Path: status
class _TranslationsStatusJa extends TranslationsStatusEn {
	_TranslationsStatusJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get idle => 'ホールドしてスタート';
	@override String get holding => 'そのまま...';
	@override String get ready => 'よーい';
	@override String get running => 'スタート';
	@override String get started => 'スタート';
	@override String get stopped => '結果';
}

// Path: messages
class _TranslationsMessagesJa extends TranslationsMessagesEn {
	_TranslationsMessagesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get resetInstruction => 'リセットボタンを押してリセットしてください';
	@override String get shareFailed => 'シェアに失敗しました';
}

// Path: history
class _TranslationsHistoryJa extends TranslationsHistoryEn {
	_TranslationsHistoryJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '履歴';
	@override String get noSolves => 'まだ履歴がありません';
	@override late final _TranslationsHistoryDeleteConfirmJa deleteConfirm = _TranslationsHistoryDeleteConfirmJa._(_root);
	@override late final _TranslationsHistoryClearConfirmJa clearConfirm = _TranslationsHistoryClearConfirmJa._(_root);
	@override late final _TranslationsHistoryMenuJa menu = _TranslationsHistoryMenuJa._(_root);
	@override late final _TranslationsHistoryDialogJa dialog = _TranslationsHistoryDialogJa._(_root);
}

// Path: trivia
class _TranslationsTriviaJa extends TranslationsTriviaEn {
	_TranslationsTriviaJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get didYouKnow => '豆知識';
}

// Path: timer
class _TranslationsTimerJa extends TranslationsTimerEn {
	_TranslationsTimerJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get reset => 'リセット';
}

// Path: history.deleteConfirm
class _TranslationsHistoryDeleteConfirmJa extends TranslationsHistoryDeleteConfirmEn {
	_TranslationsHistoryDeleteConfirmJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '履歴を削除しますか？';
	@override String get content => 'この操作は取り消せません。';
}

// Path: history.clearConfirm
class _TranslationsHistoryClearConfirmJa extends TranslationsHistoryClearConfirmEn {
	_TranslationsHistoryClearConfirmJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '履歴を削除しますか？';
}

// Path: history.menu
class _TranslationsHistoryMenuJa extends TranslationsHistoryMenuEn {
	_TranslationsHistoryMenuJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get showResult => '結果を表示';
	@override String get showResultDesc => 'タイマー画面に戻りこの記録を表示します';
	@override String get editComment => 'コメントを編集';
}

// Path: history.dialog
class _TranslationsHistoryDialogJa extends TranslationsHistoryDialogEn {
	_TranslationsHistoryDialogJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsHistoryDialogEditCommentJa editComment = _TranslationsHistoryDialogEditCommentJa._(_root);
}

// Path: history.dialog.editComment
class _TranslationsHistoryDialogEditCommentJa extends TranslationsHistoryDialogEditCommentEn {
	_TranslationsHistoryDialogEditCommentJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'コメントを編集';
	@override String get hint => 'コメントを入力';
}
