// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/feedback_provider.dart';
import '../providers/locations_provider.dart';
import '../providers/auth_provider.dart';

class AddFeedbackScreen extends StatefulWidget {
  final String placeId;
  const AddFeedbackScreen({super.key, required this.placeId});

  @override
  State<AddFeedbackScreen> createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationsProvider>(context, listen: false)
        .locations
        .firstWhere(
          (element) => element.id == widget.placeId,
        );
    String content = '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('דיווח על בעיה ב${location.name}'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  'פרטו על הבעיה:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                onChanged: (value) => content = value,
              ),
            ],
          ),
        ),
        floatingActionButton: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final response = await Provider.of<FeedbackProvider>(context,
                          listen: false)
                      .publishFeedback(FirebaseAuth.instance.currentUser!.uid,
                          widget.placeId, content);
                  if (response == 'done') {
                    await Provider.of<FeedbackProvider>(context, listen: false)
                        .fetchData(
                            Provider.of<AuthProvider>(context, listen: false)
                                .appUserData!
                                .isAdmin);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('המשוב נשלח, תודה!'),
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('שלחו את המשוב'),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
