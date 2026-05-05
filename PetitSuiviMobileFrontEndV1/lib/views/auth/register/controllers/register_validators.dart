class RegisterValidators {
  static String? validateParentStep({
    required String firstName,
    required String lastName,
    required String birthDate,
    required String cin,
    required String phone,
    required String email,
    required String address,
    required String password,
    required String confirmPassword,
  }) {
    if (firstName.isEmpty) return 'Le prénom est requis.';
    if (lastName.isEmpty) return 'Le nom est requis.';
    if (birthDate.isEmpty) return 'La date de naissance est requise.';
    if (cin.isEmpty) return 'Le CIN est requis.';
    if (cin.length != 8 || int.tryParse(cin) == null) {
      return 'Le CIN doit comporter exactement 8 chiffres.';
    }
    if (phone.isEmpty) return 'Le téléphone est requis.';
    if (phone.length < 8 || int.tryParse(phone) == null) {
      return 'Le téléphone doit comporter au moins 8 chiffres.';
    }
    if (email.isEmpty) return 'L\'email est requis.';

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) return 'L\'email n\'est pas valide.';

    if (address.isEmpty) return 'L\'adresse est requise.';
    if (password.isEmpty) return 'Le mot de passe est requis.';
    if (password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre majuscule.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre minuscule.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    }
    if (!password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Le mot de passe doit contenir au moins un symbole.';
    }

    if (password != confirmPassword) {
      return 'Les mots de passe ne correspondent pas.';
    }

    return null;
  }

  static String? validateChildrenStep(List<Map<String, dynamic>> children) {
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final firstName = child['firstName']?.toString().trim() ?? '';
      final lastName = child['lastName']?.toString().trim() ?? '';
      final birthDateStr = child['birthDate']?.toString().trim() ?? '';

      if (firstName.isEmpty) return 'Le prénom de l\'enfant ${i + 1} est requis.';
      if (lastName.isEmpty) return 'Le nom de l\'enfant ${i + 1} est requis.';
      if (birthDateStr.isEmpty) return 'La date de naissance de l\'enfant ${i + 1} est requise.';

      final parsedDate = DateTime.tryParse(birthDateStr);
      if (parsedDate != null) {
        final now = DateTime.now();
        int ageMonths = (now.year - parsedDate.year) * 12 + now.month - parsedDate.month;
        if (now.day < parsedDate.day) ageMonths--;
        if (ageMonths < 24 || ageMonths > 64) {
          return 'L\'âge de l\'enfant ${i + 1} doit être compris entre 2 ans et 5 ans et 4 mois.';
        }
      }

      final medForm = child['medicalRecordForm'];
      if (medForm == null || medForm is! Map || medForm.isEmpty) {
        return 'La fiche médicale de l\'enfant ${i + 1} est requise.';
      }
    }
    return null;
  }
}
