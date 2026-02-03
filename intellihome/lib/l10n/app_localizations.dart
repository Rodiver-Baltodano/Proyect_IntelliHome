import 'package:flutter/material.dart';
import 'app_localizations_es.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Resuelve la instancia correcta de AppLocalizations sin necesidad de
  /// BuildContext.  Útil en servicios, repositories y callbacks donde el
  /// contexto no está disponible.
  static AppLocalizations fromLocale(Locale locale) {
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

  // Método para obtener el delegado
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Idiomas soportados
  static const List<Locale> supportedLocales = [
    Locale('es', ''), // Español
    Locale('en', ''), // Inglés
    Locale('pt', ''), // Português
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
  String get idNumber;
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
  String get profilePhotoRequired;
  
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
  String get scrollToEndToAccept;
  
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

  String get nameRequired;
  String get nameInvalidFormat;
  
  // Username
  String get usernameRequired;
  String get usernameInvalidFormat;
  String get usernameAlreadyExists;
  
  // Email
  String get emailRequired;
  String get emailInvalidFormat;
  String get emailAlreadyExists;
  
  // Teléfono
  String get phoneRequired;
  String get phoneInvalidFormat;
  String get phoneAlreadyExists;
  
  // Cédula
  String get idRequired;
  String get idInvalidFormatCR;
  String get idInvalidFormatGeneric;
  String get idAlreadyExists;
  
  // Contraseña
  String get passwordRequired;
  String get passwordInvalidFormat;
  
  // Nacionalidad
  String get nationalityRequired;
  
  // IBAN
  String get ibanInvalidFormat;
  
  // Fecha de nacimiento
  String get birthDateRequired;
  String get mustBeOver18;
  
  // Tarjeta
  String get cardNumberInvalid;
  String get cardExpiryInvalid;
  String get cardExpired;
  String get cvvInvalid;
  
  // Términos
  String get mustAcceptTermsValidation;
  
  // ============================================
  // MENSAJES DE AUTENTICACIÓN (LOGIN)
  // ============================================
  
  String get invalidFormatMessage;
  String get invalidIdentifierAndPassword;
  String get userNotExistMessage;
  String get verifyDataOrRegister;
  String get userBlockedMessage;
  String get userBlockedUseRecovery;
  String get incorrectPassword;
  String get attemptsRemaining;
  String get loginSuccessMessage;
  
  // ============================================
  // MENSAJES DE RECUPERACIÓN DE CONTRASEÑA
  // ============================================
  
  String get enterPhoneEmailOrUser;
  String get invalidIdentifierFormat;
  String get userNotFoundRecovery;
  String get recoveryCodeSentToEmail;
  String get recoveryCodeGenerated;
  String get checkEnvConfiguration;
  String get invalidDataVerifyIdentifierAndCode;
  String get invalidOrExpiredCode;
  String get tooManyAttempts;
  String get accountBlockedContactSupport;
  String get requestNewCode;
  String get codeVerifiedCanUpdatePassword;
  String get invalidIdentifier;
  String get mustEnterCode;
  String get passwordMustBeAlphanumeric8;
  String get invalidOrExpiredCodeRetry;
  String get passwordUpdatedCanLogin;
  
  // ============================================
  // MENSAJES DE REGISTRO
  // ============================================
  
  String get registrationError;
  String get savingError;
  
  // ============================================
  // MENSAJES GENERALES DEL SISTEMA
  // ============================================
  
  String get operationSuccessful;
  String get operationFailed;
  String get pleaseWait;
  String get processing;

  // ============================================
  // DOMÓTICA - Control
  // ============================================
  String get domoticControl;
  String get connectedToRaspberry;
  String get reconnect;
  
  // Domótica - Habitaciones
  String get garage;
  String get livingRoom;
  String get kitchen;
  String get bathroom1;
  String get bathroom2;
  String get bedroom1;
  String get bedroom2;
  String get bedroom3;
  
  // Domótica - Estados de luz
  String get turnedOn;
  String get turnedOff;
  
  // Domótica - Sensores
  String get flame;
  String get seismic;           // ← renombrado de 'vibration'
  String get detected;
  String get normal;
  
  // Domótica - Estados de conexión
  String get connected;
  String get disconnected;
  
  // Domótica - Puertas
  String get door;
  String get garageLabel;

  // Domótica - Alertas de sensores (SnackBar)
  String get flameDetectedAlert;          // 🔥 ¡LLAMA DETECTADA!
  String get seismicDetectedAlert;        // 📳 ¡SISMO DETECTADO!

  // Domótica - Pantalla completa de alerta
  String get fireDetectedTitle;           // ¡FUEGO DETECTADO!
  String get seismicDetectedTitle;        // ¡SISMO DETECTADO!

  // Domótica - Sin conexión
  String get noConnection;                // No hay conexión con el dispositivo

  // Domótica - Puerta
  String get doorOpen;                    // 🚪 Puerta Abierta
  String get doorClosed;                  // 🚪 Puerta Cerrada
  String get errorControlDoor;            // Error al controlar la puerta

  // Domótica - Garaje (servo)
  String get garageOpen;                  // 🚗 Garaje Abierto
  String get garageClosed;                // 🚗 Garaje Cerrado
  String get errorControlGarage;          // Error al controlar el garaje

  // Domótica - Notificaciones WhatsApp enviadas
  String get fireAlertSentWhatsApp;       // 📱 Alerta de incendio enviada por WhatsApp
  String get seismicAlertSentWhatsApp;    // 📱 Alerta de sismo enviada por WhatsApp

  // ============================================
  // CAMBIO DE IDIOMA
  // ============================================
  String get changeLanguage;              // Cambiar idioma
  String get spanish;                     // Español
  String get english;                     // Inglés
  String get portuguese;                  // Português

  // ============================================
  // HUELLA (Biométrico)
  // ============================================
  String get enterUsername;
  String get biometricNotSupported;
  String get biometricReason;
  String get userNotFound;
  String get userBlocked;
  String get biometricAuthError;

  // ============================================
  // MENSAJES DE WHATSAPP
  // ============================================
  String get whatsappReservationTitle;
  String get whatsappReservationGreeting;
  String get whatsappReservationConfirmed;
  String get whatsappReservationDetails;
  String get whatsappReservationNumber;
  String get whatsappReservationProperty;
  String get whatsappReservationCheckIn;
  String get whatsappReservationCheckOut;
  String get whatsappReservationEnjoy;
  String get whatsappTeamSignature;
  
  String get whatsappFireAlertTitle;
  String get whatsappFireAlertGreeting;
  String get whatsappFireAlertDetected;
  String get whatsappFireAlertInstructions;
  String get whatsappFireAlertStayAway;
  String get whatsappFireAlertCallEmergency;
  
  String get whatsappEarthquakeAlertTitle;
  String get whatsappEarthquakeAlertGreeting;
  String get whatsappEarthquakeAlertDetected;
  String get whatsappEarthquakeAlertStayCalm;
  String get whatsappEarthquakeAlertSafePlace;
  String get whatsappEarthquakeAlertEvacuate;

    // ============================================
  // MAP_PICKER_SCREEN
  // ============================================
  String get selectLocation;
  String get enableGpsMessage;
  String get locationPermissionDenied;
  String get couldNotGetLocation;
  String get accept;

  // ============================================
  // MIS_CASAS_SCREEN
  // ============================================
  String get myHomes;
  String get errorLoadingHomes;
  String get noHomesYet;
  String get viewDetails;

  // ============================================
  // AMENIDADES
  // ============================================
  String get amenities;
  
  // Amenidades y descripciones
  String get amenityEquippedKitchen;
  String get amenityEquippedKitchenDesc;
  String get amenityAirConditioning;
  String get amenityAirConditioningDesc;
  String get amenityHeating;
  String get amenityHeatingDesc;
  String get amenityFreeWifi;
  String get amenityFreeWifiDesc;
  String get amenityCableSatellite;
  String get amenityCableSatelliteDesc;
  String get amenityWasherDryer;
  String get amenityWasherDryerDesc;
  String get amenityPool;
  String get amenityPoolDesc;
  String get amenityGardenPatio;
  String get amenityGardenPatioDesc;
  String get amenityBbqGrill;
  String get amenityBbqGrillDesc;
  String get amenityTerrace;
  String get amenityTerraceDesc;
  String get amenityHomeGym;
  String get amenityHomeGymDesc;
  String get amenityGarageParking;
  String get amenityGarageParkingDesc;
  String get amenitySecuritySystem;
  String get amenitySecuritySystemDesc;
  String get amenityEnsuiteBathroom;
  String get amenityEnsuiteBathroomDesc;
  String get amenityOutdoorFurniture;
  String get amenityOutdoorFurnitureDesc;
  String get amenityMicrowave;
  String get amenityMicrowaveDesc;
  String get amenityDishwasher;
  String get amenityDishwasherDesc;
  String get amenityCoffeeMaker;
  String get amenityCoffeeMakerDesc;
  String get amenityLinenTowels;
  String get amenityLinenTowelsDesc;
  String get amenityCommonAreas;
  String get amenityCommonAreasDesc;
  String get amenitySofaBed;
  String get amenitySofaBedDesc;
  String get amenityCleaningService;
  String get amenityCleaningServiceDesc;
  String get amenityPublicTransport;
  String get amenityPublicTransportDesc;
  String get amenityPetsAllowed;
  String get amenityPetsAllowedDesc;
  String get amenityShopsRestaurants;
  String get amenityShopsRestaurantsDesc;
  String get amenityRadiantFloor;
  String get amenityRadiantFloorDesc;
  String get amenityDeskWorkArea;
  String get amenityDeskWorkAreaDesc;
  String get amenityEntertainment;
  String get amenityEntertainmentDesc;
  String get amenityFireplace;
  String get amenityFireplaceDesc;
  String get amenityHighSpeedInternet;
  String get amenityHighSpeedInternetDesc;

  // ============================================
  // FECHAS_NO_DISPONIBLES_SCREEN
  // ============================================
  String get availability;
  String get selectUnavailableDates;
  
  // Días de la semana (abreviados)
  String get sundayShort;
  String get mondayShort;
  String get tuesdayShort;
  String get wednesdayShort;
  String get thursdayShort;
  String get fridayShort;
  String get saturdayShort;
  
  // Meses del año
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;

  // ============================================
  // HISTORIAL_RESERVAS_SCREEN
  // ============================================
  String get reservationHistory;
  String get errorLoadingReservations;
  String get noReservationsYet;
  String get unknownHouse;
  String get pending;
  String get active;
  String get finished;
  String get noLocation;
  String get domotics;

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