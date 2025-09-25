class CreateMessageDto {
  final String? sessionId;
  final String? content;
  final String? type;
  final bool? isUser;
  final String? createdAt;
  final String? path;
  final String? transcription;

  CreateMessageDto({this.sessionId, this.content, this.type, this.isUser, this.createdAt, this.path, this.transcription});

  factory CreateMessageDto.fromJson(Map<String, dynamic> json) {
    return CreateMessageDto(
      sessionId: json['sessionId'],
      content: json['content'],
      type: json['type'],
      isUser: json['isUser'],
      createdAt: json['createdAt'],
      path: json['path'],
      transcription: json['transcription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'content': content,
      'type': type,
      'isUser': isUser,
      'createdAt': createdAt,
      'path': path,
      'transcription': transcription,
    };
  }
}