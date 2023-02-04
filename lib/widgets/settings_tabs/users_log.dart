import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/all_users_provider.dart';

class UsersLog extends StatelessWidget {
  const UsersLog({super.key});

  @override
  Widget build(BuildContext context) {
    var allUsers = Provider.of<AllUsers>(context, listen: false).allUsers;
    allUsers.sort(
      ((a, b) => a.email.compareTo(b.email)),
    );
    final currentUserIndex = allUsers.indexWhere(
        (element) => element.uid == FirebaseAuth.instance.currentUser!.uid);
    allUsers.insert(0, allUsers.removeAt(currentUserIndex));
    return ListView.builder(
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        final lastSeenFormat =
            '${allUsers[index].lastLogin.day}/${allUsers[index].lastLogin.month}/${allUsers[index].lastLogin.year}';
        return Padding(
          padding: const EdgeInsets.all(2),
          child: ListTile(
            leading: CircleAvatar(
              child: Image.network(allUsers[index].profileImageURL),
            ),
            title: index == 0
                ? const Text(
                    'את/ה',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  )
                : Text(
                    allUsers[index].email,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
            subtitle: index == 0
                ? null
                : Text(
                    '${allUsers[index].username}- התחברות אחרונה: $lastSeenFormat'),
          ),
        );
      },
    );
  }
}
