///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Cube Timer'
	String get appName => 'Cube Timer';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'OK'
	String get ok => 'OK';

	late final TranslationsStatusEn status = TranslationsStatusEn.internal(_root);
	late final TranslationsMessagesEn messages = TranslationsMessagesEn.internal(_root);
	late final TranslationsHistoryEn history = TranslationsHistoryEn.internal(_root);
	late final TranslationsTriviaEn trivia = TranslationsTriviaEn.internal(_root);
	late final TranslationsTimerEn timer = TranslationsTimerEn.internal(_root);
}

// Path: status
class TranslationsStatusEn {
	TranslationsStatusEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hold to start'
	String get idle => 'Hold to start';

	/// en: 'Holding...'
	String get holding => 'Holding...';

	/// en: 'Ready'
	String get ready => 'Ready';

	/// en: 'Go!'
	String get running => 'Go!';

	/// en: 'Go!'
	String get started => 'Go!';

	/// en: 'Result'
	String get stopped => 'Result';
}

// Path: messages
class TranslationsMessagesEn {
	TranslationsMessagesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Press reset button to reset'
	String get resetInstruction => 'Press reset button to reset';

	/// en: 'Share failed'
	String get shareFailed => 'Share failed';
}

// Path: history
class TranslationsHistoryEn {
	TranslationsHistoryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'History'
	String get title => 'History';

	/// en: 'No solves yet'
	String get noSolves => 'No solves yet';

	late final TranslationsHistoryDeleteConfirmEn deleteConfirm = TranslationsHistoryDeleteConfirmEn.internal(_root);
	late final TranslationsHistoryClearConfirmEn clearConfirm = TranslationsHistoryClearConfirmEn.internal(_root);
	late final TranslationsHistoryMenuEn menu = TranslationsHistoryMenuEn.internal(_root);
	late final TranslationsHistoryDialogEn dialog = TranslationsHistoryDialogEn.internal(_root);
}

// Path: trivia
class TranslationsTriviaEn {
	TranslationsTriviaEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Did you know?'
	String get didYouKnow => 'Did you know?';
}

// Path: timer
class TranslationsTimerEn {
	TranslationsTimerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reset'
	String get reset => 'Reset';
}

// Path: history.deleteConfirm
class TranslationsHistoryDeleteConfirmEn {
	TranslationsHistoryDeleteConfirmEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete this solve?'
	String get title => 'Delete this solve?';

	/// en: 'This action cannot be undone.'
	String get content => 'This action cannot be undone.';
}

// Path: history.clearConfirm
class TranslationsHistoryClearConfirmEn {
	TranslationsHistoryClearConfirmEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Clear History?'
	String get title => 'Clear History?';
}

// Path: history.menu
class TranslationsHistoryMenuEn {
	TranslationsHistoryMenuEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show Result'
	String get showResult => 'Show Result';

	/// en: 'Return to timer and show this solve'
	String get showResultDesc => 'Return to timer and show this solve';

	/// en: 'Edit Comment'
	String get editComment => 'Edit Comment';
}

// Path: history.dialog
class TranslationsHistoryDialogEn {
	TranslationsHistoryDialogEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsHistoryDialogEditCommentEn editComment = TranslationsHistoryDialogEditCommentEn.internal(_root);
}

// Path: history.dialog.editComment
class TranslationsHistoryDialogEditCommentEn {
	TranslationsHistoryDialogEditCommentEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Comment'
	String get title => 'Edit Comment';

	/// en: 'Enter comment'
	String get hint => 'Enter comment';
}
