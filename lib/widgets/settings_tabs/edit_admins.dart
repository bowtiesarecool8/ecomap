// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import '../../providers/all_users_provider.dart';

import '../../models/app_user.dart';

class EditAdmins extends StatefulWidget {
  const EditAdmins({super.key});

  @override
  State<EditAdmins> createState() => _EditAdminsState();
}

class _EditAdminsState extends State<EditAdmins> {
  List<Widget> createPage(
      List<AppUserData> allUsers, List<AppUserData> admins, String uid) {
    List<Widget> result = [];
    final currentUserIndex = admins.indexWhere((element) => element.uid == uid);
    admins.insert(0, admins.removeAt(currentUserIndex));
    result.add(
      OutlinedButton(
        onPressed: () {
          showSearch(
              context: context, delegate: CustomSearchDelegate(allUsers));
        },
        child: const Text('הוספת מנהל'),
      ),
    );
    for (var admin in admins) {
      if (admin.uid == uid) {
        result.add(ListTile(
          leading: CircleAvatar(
            child: Image.network(FirebaseAuth.instance.currentUser!.photoURL!),
          ),
          title: const Text('את/ה'),
          subtitle: Text(admin.email),
        ));
      } else {
        result.add(
          ListTile(
            leading: CircleAvatar(
              child: Image.network(admin.profileImageURL),
            ),
            title: Text(admin.uid),
            subtitle: Text(admin.email),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('האם להסיר מנהל למשתמש זה?'),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('לא'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary),
                          onPressed: () async {
                            final response = await Provider.of<AllUsers>(
                                    context,
                                    listen: false)
                                .removeAdmin(admin.uid);
                            if (response != 'ok') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response),
                                ),
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('כן'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = Provider.of<AllUsers>(context, listen: false).allUsers;
    final allAdmins = Provider.of<AllUsers>(context, listen: true).allAdmins();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...createPage(
                  allUsers, allAdmins, FirebaseAuth.instance.currentUser!.uid),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<AppUserData> _users;

  CustomSearchDelegate(this._users);

  @override
  String? get searchFieldLabel => 'חיפוש כתובת מייל';

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    final result = _users.firstWhere(
      (element) => element.email == query,
    );
    return AlertDialog(
      title: Text('להגדיר את ${result.username} כמנהל?'),
      content: ListTile(
        leading: CircleAvatar(
          child: Image.network(result.profileImageURL),
        ),
        title: Text(result.username),
        subtitle: Text(result.email),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('לא'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary),
          onPressed: () async {
            final response = await Provider.of<AllUsers>(context, listen: false)
                .addAdmin(result.uid);
            if (response != 'ok') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response),
                ),
              );
            }
            Navigator.of(context).pop();
            close(context, null);
          },
          child: const Text('כן'),
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != '') {
      final suggestions = _users
          .where((element) =>
              (element.email.toLowerCase().startsWith(query.toLowerCase()) &&
                  element.isAdmin == false))
          .toList();
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final s = suggestions[index];
          return ListTile(
            title: Text(s.email),
            onTap: () {
              query = s.email;
              showResults(context);
            },
          );
        },
      );
    } else {
      return Container();
    }
  }
}
