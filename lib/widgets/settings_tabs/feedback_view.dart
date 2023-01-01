import 'package:ecomap/models/feedback.dart';
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

  List<UserFeedback> generateFeedbacks(FeedbackProvider feedbackProvider,
      List<UserFeedback> feedbacks, List<Location> allLocations) {
    List<UserFeedback> toReturn = [];
    //List<UserFeedback> toRemove = [];
    for (var f in feedbacks) {
      if (!checkIfStillExists(allLocations, f.locationID)) {
        feedbackProvider.removeFeedbacksOnDeletedPlace(f);
      } else {
        toReturn.add(f);
      }
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    final allLocations =
        Provider.of<LocationsProvider>(context, listen: false).locations;
    var feedbacks =
        Provider.of<FeedbackProvider>(context, listen: false).allFeedbacks;
    feedbacks = generateFeedbacks(
        Provider.of<FeedbackProvider>(context, listen: false),
        feedbacks,
        allLocations);
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
