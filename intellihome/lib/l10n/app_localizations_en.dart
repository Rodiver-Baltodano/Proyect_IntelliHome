// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IntelliHome';

  @override
  String get selectTheme => 'Select your theme';

  @override
  String get selectStyle => 'Choose your style';

  @override
  String get lightTheme => 'Light';

  @override
  String get mediumTheme => 'Medium';

  @override
  String get darkTheme => 'Dark';

  @override
  String get confirm => 'Confirm';
}
