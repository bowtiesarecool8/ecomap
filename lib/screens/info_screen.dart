// ignore_for_file: use_build_context_synchronously

import 'package:ecomap/models/information.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/information_provider.dart';
import '../providers/auth_provider.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  Future<void> updateNotification(
      String id, String content, BuildContext context) async {
    if (content == '') {
      Navigator.of(context).pop();
    } else {
      final response =
          await Provider.of<CityInformationProvider>(context, listen: false)
              .updateNotification(id, content);
      if (response == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('עודכן בהצלחה'),
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
    }
  }

  Future<void> deleteNotification(String id, BuildContext context) async {
    showDialog(
      context: context,
      builder: ((context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('האם למחוק את ההודעה?'),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'לא',
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    final response = await Provider.of<CityInformationProvider>(
                            context,
                            listen: false)
                        .deleteNotification(id);
                    if (response != 'ok') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'כן',
                  ),
                ),
              ],
              actionsAlignment: MainAxisAlignment.spaceAround,
            ),
          )),
    );
  }

  void updateDate(DateTime date, BuildContext ctx) async {
    final newDate = await showDatePicker(
      context: ctx,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      setState(() {
        date = newDate;
      });
    }
  }

  Future<void> addNotification(
      String content, DateTime date, BuildContext context) async {
    if (content != '') {
      final response =
          await Provider.of<CityInformationProvider>(context, listen: false)
              .addNotification(date, content);
      if (response != 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
          ),
        );
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> updateGarbage(String content, BuildContext context) async {
    if (content == '') {
      Navigator.of(context).pop();
    } else {
      final response =
          await Provider.of<CityInformationProvider>(context, listen: false)
              .updateGarbage(content);
      if (response == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('עודכן בהצלחה'),
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
    }
  }

  List<ListTile> generateInformationList(List<CityNotificationObject> infoList,
      bool isAdmin, BuildContext context) {
    List<ListTile> returnList = [];
    infoList.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    infoList = infoList.reversed.toList();
    for (var i in infoList) {
      returnList.add(
        ListTile(
            leading: const SizedBox(
              width: 20,
              height: 30,
              child: Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(radius: 7),
              ),
            ),
            title: Text(i.content),
            subtitle: Text('${i.date.day}/${i.date.month}/${i.date.year}'),
            trailing: isAdmin
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          String fieldContent = i.content;
                          showDialog(
                            context: context,
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                title: const Text('ערוך מידע'),
                                content: TextFormField(
                                    initialValue: i.content,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    onChanged: (value) => fieldContent = value),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'ביטול',
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: () => updateNotification(
                                        i.id, fieldContent, context),
                                    child: const Text(
                                      'עדכון',
                                    ),
                                  ),
                                ],
                                actionsAlignment: MainAxisAlignment.spaceAround,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => deleteNotification(i.id, context),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                : null),
      );
    }
    return returnList;
  }

  @override
  Widget build(BuildContext context) {
    final infoProvider =
        Provider.of<CityInformationProvider>(context, listen: true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    TextEditingController garbageController =
        TextEditingController(text: infoProvider.garbageCollection);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('מידע עירוני'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: Text(
                  'פינוי אשפה וגזם',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Text(infoProvider.garbageCollection),
                        if (authProvider.appUserData!.isAdmin)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () {
                                String fieldContent =
                                    infoProvider.garbageCollection;
                                showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AlertDialog(
                                      title: const Text('ערוך מידע'),
                                      content: TextFormField(
                                        initialValue:
                                            infoProvider.garbageCollection,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.right,
                                        onChanged: (value) =>
                                            fieldContent = value,
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            shape: const StadiumBorder(),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text(
                                            'ביטול',
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            shape: const StadiumBorder(),
                                          ),
                                          onPressed: () => updateGarbage(
                                              fieldContent, context),
                                          child: const Text(
                                            'עדכון',
                                          ),
                                        ),
                                      ],
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'מידע לתושבים',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              ...generateInformationList(
                infoProvider.cityInfo,
                authProvider.appUserData!.isAdmin,
                context,
              ),
            ],
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
              DateTime date = DateTime.now();
              String input = '';
              showDialog(
                context: context,
                builder: ((context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: StatefulBuilder(builder: ((context, setState) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Text('תאריך:'),
                                title: Text(
                                    '${date.day}/${date.month}/${date.year}'),
                                trailing: IconButton(
                                  onPressed: () //=> updateDate(date, context),
                                      async {
                                    DateTime? newDate = await showDatePicker(
                                      context: context,
                                      initialDate: date,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (newDate != null) {
                                      setState(() {
                                        date = newDate;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                ),
                              ),
                              TextFormField(
                                textDirection: TextDirection.rtl,
                                decoration: const InputDecoration(
                                    labelText: 'תוכן ההודעה...'),
                                onChanged: (value) => input = value,
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'ביטול',
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () {
                                addNotification(input, date, context);
                              },
                              child: const Text(
                                'הוסף',
                              ),
                            ),
                          ],
                          actionsAlignment: MainAxisAlignment.spaceAround,
                        );
                      })),
                    )),
              );
            },
            child: const Text('הוסף הודעה'),
          ),
        ),
      ),
    );
  }
}
