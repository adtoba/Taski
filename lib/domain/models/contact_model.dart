class ContactModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String createdAt;
  final String updatedAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactModel.fromJson(Map<dynamic, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}