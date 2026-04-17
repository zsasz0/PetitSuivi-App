/// Represents a generic parameter with a name and a value.
class Parameter {
  final int? id;
  final String name;
  final String value;

  /// Creates a new [Parameter] instance.
  Parameter({
    this.id,
    required this.name,
    required this.value,
  });

  /// Creates a [Parameter] from a JSON map.
  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      id: json['id'] as int?,
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  /// Converts the [Parameter] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }
}
