import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/feedback.dart';

class FeedbackProvider extends ChangeNotifier {
  List<UserFeedback> _feedbacks = [];
}
