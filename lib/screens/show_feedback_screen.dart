// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/feedback_provider.dart';
import '../providers/all_users_provider.dart';
import '../providers/locations_provider.dart';
import '../providers/auth_provider.dart';

import '../widgets/place_info_widget.dart';
import '../widgets/edit_place.dart';

class ShowFeedbackScreen extends StatefulWidget {
  final String feedbackId;
  const ShowFeedbackScreen({super.key, required this.feedbackId});

  @override
  State<ShowFeedbackScreen> createState() => _ShowFeedbackScreenState();
}

class _ShowFeedbackScreenState extends State<ShowFeedbackScreen> {
  bool showDetails = false;
  @override
  Widget build(BuildContext context) {
    final feedback = Provider.of<FeedbackProvider>(context, listen: true)
        .allFeedbacks
        .firstWhere(
          (element) => element.id == widget.feedbackId,
        );
    final name = Provider.of<AllUsers>(context, listen: false)
        .allUsers
        .firstWhere(
          (element) => element.uid == feedback.writerId,
        )
        .username;
    final date =
        '${feedback.uploadTime.day}/${feedback.uploadTime.month}/${feedback.uploadTime.year}';
    final location = Provider.of<LocationsProvider>(context, listen: false)
        .findLocationById(feedback.locationID);
    final im = location.getImFromBase64();
    final userProviderInstance =
        Provider.of<AuthProvider>(context, listen: false);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('טיפול בפנייה'),
          actions: [
            IconButton(
              onPressed: () async {
                final response =
                    await Provider.of<FeedbackProvider>(context, listen: false)
                        .changeStatus(feedback.id, !feedback.isDone);
                if (response == 'done') {
                  if (feedback.isDone) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('הפנייה טופלה'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('הפנייה לא טופלה'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response),
                    ),
                  );
                }
              },
              icon: feedback.isDone
                  ? const Icon(Icons.check_box)
                  : const Icon(Icons.check_box_outline_blank),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 3,
              ),
              Row(
                children: [
                  const Text(
                    'תוכן הפנייה:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    feedback.content,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'שם הפונה:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'תאריך הפנייה:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        showDetails
                            ? const Icon(
                                Icons.expand_less,
                                size: 30,
                              )
                            : const Icon(
                                Icons.expand_more,
                                size: 30,
                              ),
                        showDetails
                            ? const Text(
                                'הסתר את פרטי המקום',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            : const Text(
                                'הצג את פרטי המקום',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        showDetails = !showDetails;
                      });
                    },
                  ),
                ),
              ),
              if (showDetails)
                PlaceInfoWidget(
                  location: location,
                  userProviderInstance: userProviderInstance,
                  im: im,
                ),
            ],
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green, width: 2),
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: ((context) => EditPlace(oldLocation: location)),
              );
            },
            child: const Text(
              'ערוך את המיקום',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
