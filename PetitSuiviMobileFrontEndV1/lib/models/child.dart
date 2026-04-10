/// Represents a child entity within the SmartKids platform.
///
/// This model encapsulates all the data associated with a registered child,
/// including personal details, medical records, and schooling information.
class Child {
  final String firstName;
  final String lastName;
  final String birthDate;
  final String description;
  final String? medicalRecord;
  final String? oldSchool;
  final Map<String, dynamic> extraData;
  final String? imageUrl;

  /// Creates a new [Child] instance with required details.
  Child({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.description,
    this.medicalRecord,
    this.oldSchool,
    required this.extraData,
    this.imageUrl,
  });

  /// Returns the combined first and last name of the child.
  String get fullName => '$firstName $lastName';

  /// Converts the child instance into a Map for storage or API transmission.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'description': description,
      'medicalRecord': medicalRecord,
      'oldSchool': oldSchool,
      'extraData': extraData,
    };
  }
}
