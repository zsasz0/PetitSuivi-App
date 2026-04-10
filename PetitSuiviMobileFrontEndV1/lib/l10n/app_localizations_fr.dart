// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PETIT SUIVI';

  @override
  String get welcomeMessage => 'Bienvenue dans notre application';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour gérer les activités de vos enfants.';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmez le mot de passe';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get phone => 'Numéro de téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get cin => 'CIN';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get logout => 'Déconnexion';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get parentDashboard => 'Tableau de bord parent';

  @override
  String get teacherDashboard => 'Tableau de bord enseignant';

  @override
  String get myChildren => 'Mes enfants';

  @override
  String get manageClasses => 'Gérer les classes';

  @override
  String get manageChildren => 'Gérer les enfants';

  @override
  String get suggestActivities => 'Suggérer des activités';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get childProfile => 'Profil de l\'enfant';

  @override
  String get className => 'Classe';

  @override
  String get children => 'enfants';

  @override
  String get age => 'Âge';

  @override
  String get description => 'Description';

  @override
  String get medicalRecord => 'Dossier médical';

  @override
  String get noRecord => 'Pas de dossier';

  @override
  String get update => 'Mettre à jour';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get profileUpdated => 'Profil mis à jour !';

  @override
  String get childProfileUpdated => 'Profil de l\'enfant mis à jour !';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String noteForChild(String childName) {
    return 'Ajouter une note pour $childName';
  }

  @override
  String get enterBehaviorNote =>
      'Entrez la note de comportement pour aujourd\'hui...';

  @override
  String noteSaved(String childName) {
    return 'Note enregistrée pour $childName';
  }

  @override
  String get activityName => 'Nom de l\'activité';

  @override
  String get activityDescription => 'Description de l\'activité';

  @override
  String get day => 'Jour';

  @override
  String get time => 'Heure';

  @override
  String get confirmedByAdmin => 'Confirmé par l\'administrateur';

  @override
  String get pending => 'En attente';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get payments => 'Paiements';

  @override
  String get activities => 'Activités';

  @override
  String get calendar => 'Calendrier';

  @override
  String get messages => 'Messages';

  @override
  String get required => 'Requis';

  @override
  String get logoutConfirmTitle => 'Confirmation de déconnexion';

  @override
  String get logoutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get selectChild => 'Choisir un enfant';

  @override
  String get whoToManage => 'Qui voulez-vous gérer ?';

  @override
  String get yearsOld => 'ans';

  @override
  String get newsAndActivities => 'Nouvelles et activités';

  @override
  String get home => 'Accueil';

  @override
  String get support => 'Support';

  @override
  String get contactAdministration => 'Contacter l\'administration';

  @override
  String get howCanWeHelp => 'Comment pouvons-nous vous aider ?';

  @override
  String get callUs => 'Appelez-nous';

  @override
  String get emailUs => 'Envoyez-nous un email';

  @override
  String get callingAdministration => 'Appel de l\'administration...';

  @override
  String get openingEmailApp => 'Ouverture de l\'application de messagerie...';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get typeMessageHint => 'Tapez votre message ici...';

  @override
  String get sendMessageButton => 'Envoyer le message';

  @override
  String get conversationHistory => 'Historique de la conversation';

  @override
  String get you => 'Vous';

  @override
  String get administration => 'Administration';

  @override
  String get selectChildToViewPayments =>
      'Sélectionnez un enfant pour voir les paiements';

  @override
  String get paid => 'Payé';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get logInButton => 'CONNEXION';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get registerNow => 'Inscrivez-vous maintenant';

  @override
  String loginSuccessful(String roleName) {
    return 'Connexion réussie ! Bienvenue $roleName';
  }

  @override
  String get invalidRole => 'Rôle invalide';

  @override
  String get invalidCredentials => 'Email ou mot de passe invalide';

  @override
  String get parentRegistration => 'Inscription parent';

  @override
  String get parentInformation => 'Informations parentales';

  @override
  String get childrenInformation => 'Informations des enfants';

  @override
  String get addAtLeastOneChild => 'Veuillez ajouter au moins un enfant.';

  @override
  String get registrationSuccessful => 'Inscription réussie !';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get finishAndRegister => 'Terminer et s\'inscrire';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs parentaux';

  @override
  String get howManyChildren => 'Combien d\'enfants avez-vous ?';

  @override
  String childCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Enfants',
      one: '1 Enfant',
    );
    return '$_temp0';
  }

  @override
  String get addCustomData => 'Ajouter des données personnalisées';

  @override
  String get customDataLabel => 'Étiquette (ex: Allergies)';

  @override
  String get customDataValue => 'Valeur (ex: Arachides)';

  @override
  String get add => 'Ajouter';

  @override
  String childNumber(int number) {
    return 'Enfant n°$number';
  }

  @override
  String get childFirstName => 'Prénom de l\'enfant';

  @override
  String get childLastName => 'Nom de l\'enfant';

  @override
  String get childDescriptionHint =>
      'Décrivez votre enfant (hobbies, caractère...)';

  @override
  String get noMedicalRecord => 'Aucun dossier médical téléchargé';

  @override
  String get upload => 'Télécharger';

  @override
  String get additionalData => 'Données supplémentaires';

  @override
  String get addMoreData => 'Ajouter plus de données';

  @override
  String get aboutUs => 'À propos de nous';

  @override
  String get appDescription =>
      'PETIT SUIVI est une plateforme de gestion complète pour les jardins d\'enfants, facilitant la communication entre les parents, les éducateurs et les administrateurs. Nous assurons un suivi efficace des enfants, y compris l\'inscription, l\'assiduité, les paiements, les activités et les repas.';

  @override
  String get registerOnline => 'S\'inscrire en ligne';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get whatParentsSay => 'Ce que disent les parents';

  @override
  String get testimonialSarah =>
      'PETIT SUIVI a rendu le suivi des progrès de mon enfant tellement facile ! Les mises à jour en temps réel sont fantastiques.';

  @override
  String get testimonialJohn =>
      'J\'adore la fonction de planification des repas. Cela me donne la tranquillité d\'esprit de savoir ce que mon fils mange.';

  @override
  String get testimonialEmily =>
      'La communication avec les éducateurs est fluide. Hautement recommandé !';

  @override
  String get competencies => 'Compétences';

  @override
  String get motorSkills => 'Motricité';

  @override
  String get languageSkill => 'Langage';

  @override
  String get autonomy => 'Autonomie';

  @override
  String get socialInteraction => 'Interaction sociale';

  @override
  String get levelInProgress => 'En cours';

  @override
  String get levelAcquired => 'Acquise';

  @override
  String get levelNeedsWork => 'À renforcer';

  @override
  String get strengthsAndWeaknesses => 'Points forts & axes de progrès';

  @override
  String get lastEvaluation => 'Dernière évaluation';

  @override
  String get noCompetencyData => 'Aucune évaluation disponible pour le moment.';

  @override
  String get oldSchool => 'Ancienne École';

  @override
  String get oldSchoolHint => 'Nom de l\'établissement précédent';

  @override
  String get paymentProgress => 'Progression des paiements';

  @override
  String get totalFees => 'Total';

  @override
  String get paidAmountLabel => 'Payé';

  @override
  String get monthlyMode => 'MENSUEL';

  @override
  String get yearlyMode => 'ANNUEL';

  @override
  String get monthlyDetails => 'Détails des mensualités';

  @override
  String get yearlyDetails => 'Détails du paiement annuel';

  @override
  String paidPercent(int percent) => '$percent% payé';

  @override
  String get settled => 'Soldé';

  @override
  String paidOn(String date) => 'Payé le $date';

  @override
  String get toPay => 'À payer';

  @override
  String get yearlyPaymentConfirmed => 'Paiement Annuel Confirmé';

  @override
  String get paymentPending => 'Paiement en Attente';

  @override
  String get downloadReceipt => 'Télécharger le reçu';

  @override
  String get paymentDate => 'Date de paiement';

  @override
  String get paymentModeLabel => 'Mode';
}
