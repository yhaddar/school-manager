class ClassModel {
  final int id;
  final String name;
  final int levelId;
  final int groupId;
  final int? roomId;
  final List<Student> students;

  ClassModel({
    required this.id,
    required this.name,
    required this.levelId,
    required this.groupId,
    this.roomId,
    this.students = const [],
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    var students = <Student>[];
    if (json['students'] != null) {
      students = (json['students'] as List)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    return ClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      levelId: json['level_id'] as int,
      groupId: json['group_id'] as int,
      roomId: json['room_id'] as int?,
      students: students,
    );
  }
}

class Student {
  final int id;
  final String name;
  final String? email;
  final String? studentId;

  Student({
    required this.id,
    required this.name,
    this.email,
    this.studentId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      studentId: json['student_id'] as String?,
    );
  }
}
