import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'SmartKids'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans notre application'**
  String get welcomeMessage;

  /// No description provided for @welcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour !'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer les activités de vos enfants.'**
  String get loginSubtitle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez le mot de passe'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @cin.
  ///
  /// In fr, this message translates to:
  /// **'CIN'**
  String get cin;

  /// No description provided for @dateOfBirth.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get dateOfBirth;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @parentDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord parent'**
  String get parentDashboard;

  /// No description provided for @teacherDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord enseignant'**
  String get teacherDashboard;

  /// No description provided for @myChildren.
  ///
  /// In fr, this message translates to:
  /// **'Mes enfants'**
  String get myChildren;

  /// No description provided for @manageClasses.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les classes'**
  String get manageClasses;

  /// No description provided for @manageChildren.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les enfants'**
  String get manageChildren;

  /// No description provided for @suggestActivities.
  ///
  /// In fr, this message translates to:
  /// **'Suggérer des activités'**
  String get suggestActivities;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get myProfile;

  /// No description provided for @childProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil de l\'enfant'**
  String get childProfile;

  /// No description provided for @className.
  ///
  /// In fr, this message translates to:
  /// **'Classe'**
  String get className;

  /// No description provided for @children.
  ///
  /// In fr, this message translates to:
  /// **'enfants'**
  String get children;

  /// No description provided for @age.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get age;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @medicalRecord.
  ///
  /// In fr, this message translates to:
  /// **'Dossier médical'**
  String get medicalRecord;

  /// No description provided for @noRecord.
  ///
  /// In fr, this message translates to:
  /// **'Pas de dossier'**
  String get noRecord;

  /// No description provided for @update.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get update;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour !'**
  String get profileUpdated;

  /// No description provided for @childProfileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil de l\'enfant mis à jour !'**
  String get childProfileUpdated;

  /// No description provided for @addNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get addNote;

  /// No description provided for @noteForChild.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note pour {childName}'**
  String noteForChild(String childName);

  /// No description provided for @enterBehaviorNote.
  ///
  /// In fr, this message translates to:
  /// **'Entrez la note de comportement pour aujourd\'hui...'**
  String get enterBehaviorNote;

  /// No description provided for @noteSaved.
  ///
  /// In fr, this message translates to:
  /// **'Note enregistrée pour {childName}'**
  String noteSaved(String childName);

  /// No description provided for @activityName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'activité'**
  String get activityName;

  /// No description provided for @activityDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description de l\'activité'**
  String get activityDescription;

  /// No description provided for @day.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get day;

  /// No description provided for @time.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get time;

  /// No description provided for @confirmedByAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé par l\'administrateur'**
  String get confirmedByAdmin;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirmed;

  /// No description provided for @payments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get payments;

  /// No description provided for @activities.
  ///
  /// In fr, this message translates to:
  /// **'Activités'**
  String get activities;

  /// No description provided for @calendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calendar;

  /// No description provided for @messages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get required;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation de déconnexion'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @monday.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get sunday;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get english;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get arabic;

  /// No description provided for @changeLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Changer de langue'**
  String get changeLanguage;

  /// No description provided for @selectChild.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un enfant'**
  String get selectChild;

  /// No description provided for @whoToManage.
  ///
  /// In fr, this message translates to:
  /// **'Qui voulez-vous gérer ?'**
  String get whoToManage;

  /// No description provided for @yearsOld.
  ///
  /// In fr, this message translates to:
  /// **'ans'**
  String get yearsOld;

  /// No description provided for @newsAndActivities.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles et activités'**
  String get newsAndActivities;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @support.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactAdministration.
  ///
  /// In fr, this message translates to:
  /// **'Contacter l\'administration'**
  String get contactAdministration;

  /// No description provided for @howCanWeHelp.
  ///
  /// In fr, this message translates to:
  /// **'Comment pouvons-nous vous aider ?'**
  String get howCanWeHelp;

  /// No description provided for @callUs.
  ///
  /// In fr, this message translates to:
  /// **'Appelez-nous'**
  String get callUs;

  /// No description provided for @emailUs.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-nous un email'**
  String get emailUs;

  /// No description provided for @callingAdministration.
  ///
  /// In fr, this message translates to:
  /// **'Appel de l\'administration...'**
  String get callingAdministration;

  /// No description provided for @openingEmailApp.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de l\'application de messagerie...'**
  String get openingEmailApp;

  /// No description provided for @sendMessage.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get sendMessage;

  /// No description provided for @typeMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Tapez votre message ici...'**
  String get typeMessageHint;

  /// No description provided for @sendMessageButton.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le message'**
  String get sendMessageButton;

  /// No description provided for @conversationHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique de la conversation'**
  String get conversationHistory;

  /// No description provided for @you.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get you;

  /// No description provided for @administration.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @selectChildToViewPayments.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un enfant pour voir les paiements'**
  String get selectChildToViewPayments;

  /// No description provided for @paid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paid;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @logInButton.
  ///
  /// In fr, this message translates to:
  /// **'CONNEXION'**
  String get logInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte ?'**
  String get dontHaveAccount;

  /// No description provided for @registerNow.
  ///
  /// In fr, this message translates to:
  /// **'Inscrivez-vous maintenant'**
  String get registerNow;

  /// No description provided for @loginSuccessful.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie ! Bienvenue {roleName}'**
  String loginSuccessful(String roleName);

  /// No description provided for @invalidRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle invalide'**
  String get invalidRole;

  /// No description provided for @invalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe invalide'**
  String get invalidCredentials;

  /// No description provided for @parentRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Inscription parent'**
  String get parentRegistration;

  /// No description provided for @parentInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations parentales'**
  String get parentInformation;

  /// No description provided for @childrenInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations des enfants'**
  String get childrenInformation;

  /// No description provided for @addAtLeastOneChild.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez ajouter au moins un enfant.'**
  String get addAtLeastOneChild;

  /// No description provided for @registrationSuccessful.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie !'**
  String get registrationSuccessful;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @finishAndRegister.
  ///
  /// In fr, this message translates to:
  /// **'Terminer et s\'inscrire'**
  String get finishAndRegister;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @fillAllFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir tous les champs parentaux'**
  String get fillAllFields;

  /// No description provided for @howManyChildren.
  ///
  /// In fr, this message translates to:
  /// **'Combien d\'enfants avez-vous ?'**
  String get howManyChildren;

  /// No description provided for @childCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 Enfant} other{{count} Enfants}}'**
  String childCount(int count);

  /// No description provided for @addCustomData.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des données personnalisées'**
  String get addCustomData;

  /// No description provided for @customDataLabel.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette (ex: Allergies)'**
  String get customDataLabel;

  /// No description provided for @customDataValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur (ex: Arachides)'**
  String get customDataValue;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @childNumber.
  ///
  /// In fr, this message translates to:
  /// **'Enfant n°{number}'**
  String childNumber(int number);

  /// No description provided for @childFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom de l\'enfant'**
  String get childFirstName;

  /// No description provided for @childLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'enfant'**
  String get childLastName;

  /// No description provided for @childDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre enfant (hobbies, caractère...)'**
  String get childDescriptionHint;

  /// No description provided for @noMedicalRecord.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier médical téléchargé'**
  String get noMedicalRecord;

  /// No description provided for @upload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get upload;

  /// No description provided for @additionalData.
  ///
  /// In fr, this message translates to:
  /// **'Données supplémentaires'**
  String get additionalData;

  /// No description provided for @addMoreData.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter plus de données'**
  String get addMoreData;

  /// No description provided for @aboutUs.
  ///
  /// In fr, this message translates to:
  /// **'À propos de nous'**
  String get aboutUs;

  /// No description provided for @appDescription.
  ///
  /// In fr, this message translates to:
  /// **'SmartKids est une plateforme de gestion complète pour les jardins d\'enfants, facilitant la communication entre les parents, les éducateurs et les administrateurs. Nous assurons un suivi efficace des enfants, y compris l\'inscription, l\'assiduité, les paiements, les activités et les repas.'**
  String get appDescription;

  /// No description provided for @registerOnline.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire en ligne'**
  String get registerOnline;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get alreadyHaveAccount;

  /// No description provided for @whatParentsSay.
  ///
  /// In fr, this message translates to:
  /// **'Ce que disent les parents'**
  String get whatParentsSay;

  /// No description provided for @testimonialSarah.
  ///
  /// In fr, this message translates to:
  /// **'SmartKids a rendu le suivi des progrès de mon enfant tellement facile ! Les mises à jour en temps réel sont fantastiques.'**
  String get testimonialSarah;

  /// No description provided for @testimonialJohn.
  ///
  /// In fr, this message translates to:
  /// **'J\'adore la fonction de planification des repas. Cela me donne la tranquillité d\'esprit de savoir ce que mon fils mange.'**
  String get testimonialJohn;

  /// No description provided for @testimonialEmily.
  ///
  /// In fr, this message translates to:
  /// **'La communication avec les éducateurs est fluide. Hautement recommandé !'**
  String get testimonialEmily;

  /// No description provided for @competencies.
  ///
  /// In fr, this message translates to:
  /// **'Compétences'**
  String get competencies;

  /// No description provided for @motorSkills.
  ///
  /// In fr, this message translates to:
  /// **'Motricité'**
  String get motorSkills;

  /// No description provided for @languageSkill.
  ///
  /// In fr, this message translates to:
  /// **'Langage'**
  String get languageSkill;

  /// No description provided for @autonomy.
  ///
  /// In fr, this message translates to:
  /// **'Autonomie'**
  String get autonomy;

  /// No description provided for @socialInteraction.
  ///
  /// In fr, this message translates to:
  /// **'Interaction sociale'**
  String get socialInteraction;

  /// No description provided for @levelInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get levelInProgress;

  /// No description provided for @levelAcquired.
  ///
  /// In fr, this message translates to:
  /// **'Acquise'**
  String get levelAcquired;

  /// No description provided for @levelNeedsWork.
  ///
  /// In fr, this message translates to:
  /// **'À renforcer'**
  String get levelNeedsWork;

  /// No description provided for @strengthsAndWeaknesses.
  ///
  /// In fr, this message translates to:
  /// **'Points forts & axes de progrès'**
  String get strengthsAndWeaknesses;

  /// No description provided for @lastEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'Dernière évaluation'**
  String get lastEvaluation;

  /// In fr, this message translates to:
  /// **'Aucune évaluation disponible pour le moment.'**
  String get noCompetencyData;

  /// No description provided for @oldSchool.
  ///
  /// In fr, this message translates to:
  /// **'Ancienne École'**
  String get oldSchool;

  /// No description provided for @oldSchoolHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'établissement précédent'**
  String get oldSchoolHint;

  /// No description provided for @paymentProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression des paiements'**
  String get paymentProgress;

  /// No description provided for @totalFees.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get totalFees;

  /// No description provided for @paidAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paidAmountLabel;

  /// No description provided for @monthlyMode.
  ///
  /// In fr, this message translates to:
  /// **'MENSUEL'**
  String get monthlyMode;

  /// No description provided for @yearlyMode.
  ///
  /// In fr, this message translates to:
  /// **'ANNUEL'**
  String get yearlyMode;

  /// No description provided for @monthlyDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails des mensualités'**
  String get monthlyDetails;

  /// No description provided for @yearlyDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du contrat'**
  String get yearlyDetails;

  /// No description provided for @paidPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% payé'**
  String paidPercent(int percent);

  /// No description provided for @settled.
  ///
  /// In fr, this message translates to:
  /// **'Soldé'**
  String get settled;

  /// No description provided for @paidOn.
  ///
  /// In fr, this message translates to:
  /// **'Payé le {date}'**
  String paidOn(String date);

  /// No description provided for @toPay.
  ///
  /// In fr, this message translates to:
  /// **'À payer'**
  String get toPay;

  /// No description provided for @yearlyPaymentConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Paiement Annuel Confirmé'**
  String get yearlyPaymentConfirmed;

  /// No description provided for @paymentPending.
  ///
  /// In fr, this message translates to:
  /// **'Paiement en Attente'**
  String get paymentPending;

  /// No description provided for @downloadReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le reçu'**
  String get downloadReceipt;

  /// No description provided for @paymentDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de paiement'**
  String get paymentDate;

  /// No description provided for @paymentModeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get paymentModeLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
