class Course {
  final int id;
  final String name;
  final String? description;
  final int subjectId;
  final int academicPeriodId;
  final Teacher? teacher;

  Course({
    required this.id,
    required this.name,
    this.description,
    required this.subjectId,
    required this.academicPeriodId,
    this.teacher,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      subjectId: json['subject_id'] as int,
      academicPeriodId: json['academic_period_id'] as int,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
    );
  }
}

class Teacher {
  final int id;
  final String name;
  final String email;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class Subject {
  final int id;
  final String name;
  final String? code;

  Subject({
    required this.id,
    required this.name,
    this.code,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }
}
