class CreateMessageDto {
  final String? sessionId;
  final String? content;
  final String? type;
  final bool? isUser;
  final String? createdAt;

  CreateMessageDto({this.sessionId, this.content, this.type, this.isUser, this.createdAt});

  factory CreateMessageDto.fromJson(Map<String, dynamic> json) {
    return CreateMessageDto(
      sessionId: json['sessionId'],
      content: json['content'],
      type: json['type'],
      isUser: json['isUser'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'content': content,
      'type': type,
      'isUser': isUser,
      'createdAt': createdAt,
    };
  }
}