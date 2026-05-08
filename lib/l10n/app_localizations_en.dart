// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Story App';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get uploadStory => 'Upload Story';

  @override
  String get pickLocation => 'Pick Location';

  @override
  String get myLocation => 'My Location';

  @override
  String get logout => 'Logout';

  @override
  String get stories => 'Stories';

  @override
  String get addStory => 'Add Story';

  @override
  String get emptyStory => 'No stories yet';

  @override
  String get welcomeBack => 'Welcome Back 👋';

  @override
  String get createAccount => 'Create Account ✨';
}
