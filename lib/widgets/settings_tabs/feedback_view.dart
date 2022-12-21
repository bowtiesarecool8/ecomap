import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/feedback_provider.dart';

import '../../providers/all_users_provider.dart';

import '../../providers/locations_provider.dart';

import '../../screens/show_feedback_screen.dart';

class Feedback extends StatefulWidget {
  const Feedback({super.key});

  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  @override
  Widget build(BuildContext context) {
    final feedbacks =
        Provider.of<FeedbackProvider>(context, listen: true).allFeedbacks;
    final allUsers = Provider.of<AllUsers>(context, listen: false).allUsers;
    final locations =
        Provider.of<LocationsProvider>(context, listen: false).locations;
    return SizedBox(
      child: ListView.builder(
        itemCount: feedbacks.length,
        itemBuilder: ((context, index) {
          final f = feedbacks[index];
          final name = allUsers
              .firstWhere(
                (element) => element.uid == f.writerId,
              )
              .username;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListTile(
              title: Text(name),
              subtitle: Text(
                  '${f.uploadTime.day}/${f.uploadTime.month}/${f.uploadTime.year}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: ((context) =>
                        ShowFeedbackScreen(feedbackId: f.id)),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
