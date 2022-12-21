import 'package:flutter/material.dart';

import '../widgets/settings_tabs/edit_admins.dart';
import '../widgets/settings_tabs/feedback_view.dart' as feedback_tab;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
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
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    EditAdmins(),
                    feedback_tab.Feedback(),
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
