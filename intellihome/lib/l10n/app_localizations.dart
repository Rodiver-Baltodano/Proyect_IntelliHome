import 'package:flutter/material.dart';
import 'app_localizations_es.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Método para obtener el delegado
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Idiomas soportados
  static const List<Locale> supportedLocales = [
    Locale('es', ''), // Español
    Locale('en', ''), // Inglés
    Locale('pt', ''), // Portugués
  ];

  // Textos generales
  String get appTitle;
  String get help;
  String get language;
  
  // Login Screen
  String get loginTitle;
  String get username;
  String get password;
  String get loginButton;
  String get registerButton;
  String get forgotPassword;
  String get loginSuccess;
  
  // Register Screen
  String get registerTitle;
  String get name;
  String get email;
  String get confirmPassword;
  String get phoneNumber;
  String get nationality;
  String get ibanNumber;
  String get birthDate;
  String get addCreditCard;
  String get cardNumber;
  String get expirationDate;
  String get cvv;
  String get cardOptionalNote;
  String get registerAccount;
  String get termsMessage;
  String get termsAndConditions;
  String get mustAcceptTerms;
  String get backToLogin;
  String get passwordsDontMatch;
  String get mustAcceptTermsError;
  String get registrationSuccess;
  
  // Recovery Screen
  String get recoveryTitle;
  String get recoveryDescription;
  String get recoveryCodeDescription;
  String get usernameOrEmail;
  String get requestCode;
  String get recoveryCode;
  String get verifyCode;
  String get newPassword;
  String get confirmNewPassword;
  String get changePassword;
  String get codeSent;
  String get codeVerified;
  String get passwordUpdated;
  String get requestingCode;
  
  // Recovery Screen - Nuevos
  String get enterUserOrEmail;
  String get codeSentToPhone;
  String get codeRequired;
  String get codeVerifiedEnterPassword;
  String get passwordsMismatch;
  String get passwordMinLength;
  String get userNotIdentified;
  String get passwordUpdatedBackToLogin;
  String get enterCodeSentToEmail;
  String get enterUserForRecoveryCode;
  String get recoverAccount;
  
  // Help Screen
  String get aboutApp;
  String get aboutDescription;
  String get version;
  String get developerTeam;
  String get developer;
  String get contactSupport;
  String get emailLabel;
  String get phoneLabel;
  String get websiteLabel;
  String get mainFeatures;
  String get feature1;
  String get feature2;
  String get feature3;
  String get feature4;
  String get feature5;
  String get feature6;
  String get feature7;
  String get feature8;
  String get feature9;
  String get close;
  
  // Terms Screen
  String get termsTitle;
  String get termsContent;
  String get acceptTermsCheckbox;
  String get acceptAndContinue;
  String get cancel;
  
  // Home Screen
  String get welcome;
  String get adventurous;
  String get minimalist;
  String get contemporary;
  String get customize;
  String get logout;
  
  // Personalization Screen
  String get registeredSuccessfully;
  String get customizeColors;
  String get primaryColor;
  String get backgroundColor;
  String get theme;
  String get light;
  String get medium;
  String get dark;
  String get style;
  String get minimalistStyle;
  String get adventurousStyle;
  String get contemporaryStyle;
  String get done;
  String get personalizationSaved;
  String get errorSaving;
  
  // Errores comunes
  String get error;
  String get success;
  String get loading;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'pt':
        return AppLocalizationsPt();
      case 'es':
      default:
        return AppLocalizationsEs();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}