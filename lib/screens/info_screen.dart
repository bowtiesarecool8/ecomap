import 'package:ecomap/models/information.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/information_provider.dart';
import '../providers/auth_provider.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

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
                ? IconButton(
                    onPressed: () {
                      TextEditingController c =
                          TextEditingController(text: i.content);
                      showDialog(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: const Text('ערוך מידע'),
                            content: TextField(
                              controller: c,
                              onChanged: (value) => c.text = value,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
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
                                showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AlertDialog(
                                      title: const Text('ערוך מידע'),
                                      content: TextField(
                                        controller: garbageController,
                                        onChanged: (value) =>
                                            garbageController.text = value,
                                      ),
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
      ),
    );
  }
}
