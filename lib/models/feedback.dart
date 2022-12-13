class UserFeedback {
  final String id;
  final String writerId;
  final String locationID;
  final String content;
  final bool isDone;

  UserFeedback({
    required this.id,
    required this.writerId,
    required this.locationID,
    required this.content,
    required this.isDone,
  });
}
