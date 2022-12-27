import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/feedback_provider.dart';

import '../../providers/all_users_provider.dart';

import '../../providers/locations_provider.dart';

import '../../models/location.dart';

import '../../screens/show_feedback_screen.dart';

class Feedback extends StatefulWidget {
  const Feedback({super.key});

  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  bool checkIfStillExists(List<Location> allLocations, String locationId) {
    return allLocations.any((element) => element.id == locationId);
  }

  @override
  Widget build(BuildContext context) {
    final allLocations =
        Provider.of<LocationsProvider>(context, listen: false).locations;
    final feedbacks =
        Provider.of<FeedbackProvider>(context, listen: true).allFeedbacks;
    feedbacks.removeWhere((element) {
      return !checkIfStillExists(allLocations, element.locationID);
    });
    final allUsers = Provider.of<AllUsers>(context, listen: false).allUsers;
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
              leading: f.isDone
                  ? const Icon(
                      Icons.done,
                      size: 28,
                    )
                  : const Icon(
                      Icons.crop_square,
                      size: 28,
                    ),
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
