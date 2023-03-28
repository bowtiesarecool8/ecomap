import 'package:flutter/material.dart';

import '../widgets/settings_tabs/edit_admins.dart';
import '../widgets/settings_tabs/feedback_view.dart' as feedback_tab;
import '../widgets/settings_tabs/users_log.dart';
import '../widgets/settings_tabs/popups_edit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('הגדרות מנהל'),
          ),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.feedback,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.list,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    EditAdmins(),
                    feedback_tab.Feedback(),
                    UsersLog(),
                    PopupsEdit(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
