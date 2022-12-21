// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/feedback_provider.dart';
import '../providers/all_users_provider.dart';

class ShowFeedbackScreen extends StatefulWidget {
  final String feedbackId;
  const ShowFeedbackScreen({super.key, required this.feedbackId});

  @override
  State<ShowFeedbackScreen> createState() => _ShowFeedbackScreenState();
}

class _ShowFeedbackScreenState extends State<ShowFeedbackScreen> {
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
            ],
          ),
        ),
      ),
    );
  }
}
