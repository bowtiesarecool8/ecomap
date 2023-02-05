import 'package:ecomap/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/all_users_provider.dart';

class UsersLog extends StatefulWidget {
  const UsersLog({super.key});

  @override
  State<UsersLog> createState() => _UsersLogState();
}

class _UsersLogState extends State<UsersLog> {
  final sortOptions = ['כתובת אימייל', 'התחברות אחרונה'];
  String selectedSort = 'כתובת אימייל';

  List<AppUserData> emailSort(List<AppUserData> allUsers) {
    allUsers.sort(
      ((a, b) => a.email.compareTo(b.email)),
    );
    final currentUserIndex = allUsers.indexWhere(
        (element) => element.uid == FirebaseAuth.instance.currentUser!.uid);
    allUsers.insert(0, allUsers.removeAt(currentUserIndex));
    return allUsers;
  }

  List<AppUserData> lastLoginSort(List<AppUserData> allUsers) {
    allUsers.sort(
      ((a, b) => a.lastLogin.compareTo(b.lastLogin)),
    );
    allUsers = allUsers.reversed.toList();
    final currentUserIndex = allUsers.indexWhere(
        (element) => element.uid == FirebaseAuth.instance.currentUser!.uid);
    allUsers.insert(0, allUsers.removeAt(currentUserIndex));
    return allUsers;
  }

  @override
  Widget build(BuildContext context) {
    var allUsers = Provider.of<AllUsers>(context, listen: false).allUsers;
    if (selectedSort == sortOptions[0]) {
      allUsers = emailSort(allUsers);
    } else {
      allUsers = lastLoginSort(allUsers);
    }
    return ListView.builder(
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        final lastSeenFormat =
            '${allUsers[index].lastLogin.day}/${allUsers[index].lastLogin.month}/${allUsers[index].lastLogin.year}';
        if (index == 0) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'מיון לפי: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  DropdownButton(
                    items: sortOptions
                        .map(
                          (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Center(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    value: selectedSort,
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value!;
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Image.network(allUsers[index].profileImageURL),
                  ),
                  title: const Text(
                    'את/ה',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: ListTile(
              leading: CircleAvatar(
                child: Image.network(allUsers[index].profileImageURL),
              ),
              title: Text(
                allUsers[index].email,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                  '${allUsers[index].username}- התחברות אחרונה: $lastSeenFormat'),
            ),
          );
        }
      },
    );
  }
}
