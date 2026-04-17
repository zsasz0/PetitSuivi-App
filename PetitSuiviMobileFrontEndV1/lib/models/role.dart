class Role {
  final int? id;
  final int value; // 1: teacher, 2: admin, 3: parent

  Role({
    this.id,
    required this.value,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    int val = 0;
    if (json['value'] != null) {
      val = json['value'] as int;
    } else if (json['name'] != null) {
      final name = json['name'].toString().toLowerCase();
      if (name == 'teacher') {
        val = 1;
      } else if (name == 'admin') {
        val = 2;
      } else if (name == 'parent') {
        val = 3;
      }
    }
    return Role(
      id: json['id'] as int?,
      value: val,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
    };
  }
}
