class Session {
  final String? id;
  final String? title;
  final DateTime? createdAt;

  Session({this.id, this.title, this.createdAt});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      title: json['title'],
      createdAt: json['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdAt': createdAt,
    };
  }
}