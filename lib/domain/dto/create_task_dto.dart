class CreateTaskDto {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime dueDate;

  CreateTaskDto({required this.id, required this.title, required this.description, required this.priority, required this.status, required this.dueDate});

  factory CreateTaskDto.fromJson(Map<String, dynamic> json) {
    return CreateTaskDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      dueDate: json['dueDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': dueDate,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }
}