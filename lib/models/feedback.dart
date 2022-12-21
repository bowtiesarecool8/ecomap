class UserFeedback {
  final String id;
  final String writerId;
  final DateTime uploadTime;
  final String locationID;
  final String content;
  bool isDone;

  UserFeedback({
    required this.id,
    required this.writerId,
    required this.uploadTime,
    required this.locationID,
    required this.content,
    required this.isDone,
  });
}
