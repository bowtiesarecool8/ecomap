// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';

import '../../providers/popups_provider.dart';

class PopupsEdit extends StatefulWidget {
  const PopupsEdit({super.key});

  @override
  State<PopupsEdit> createState() => _PopupsEditState();
}

class _PopupsEditState extends State<PopupsEdit> {
  void trySubmit(
    GlobalKey<FormState> formKey,
    String id,
    String title,
    String content,
    String imageBytes,
  ) async {
    final isValidInput = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValidInput) {
      formKey.currentState!.save();
      final response = await Provider.of<PopupsProvider>(context, listen: false)
          .editPopup(id, title, content, imageBytes);
      if (response == 'ok') {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
          ),
        );
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final popups = Provider.of<PopupsProvider>(context, listen: true).popups;
    return ListView.builder(
      itemCount: popups.length,
      itemBuilder: ((context, index) {
        return ListTile(
          title: Text(
            popups[index].title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: (() {
              final formKey = GlobalKey<FormState>();
              Image? im = popups[index].imageBytes == ''
                  ? null
                  : popups[index].getImFromBase64();
              String imageBytes = popups[index].imageBytes;
              String newTitle = popups[index].title;
              String newContent = popups[index].content;
              showDialog(
                context: context,
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      icon: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  title: Text(
                                      'האם למחוק את ${popups[index].title}?'),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceAround,
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: const StadiumBorder(),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('לא'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: const StadiumBorder(),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final response =
                                            await Provider.of<PopupsProvider>(
                                                    context,
                                                    listen: false)
                                                .deletePopup(popups[index].id);
                                        if (response != 'ok') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(response),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('כן'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                      iconPadding: EdgeInsets.zero,
                      title: Center(
                        child: Text('ערוך את ${popups[index].title}'),
                      ),
                      scrollable: true,
                      content: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 4,
                            width: double.maxFinite,
                            child: imageBytes == ''
                                ? Container(
                                    color: Colors.grey,
                                    child: IconButton(
                                      icon: const Icon(Icons.image_search),
                                      onPressed: () async {
                                        final picker = ImagePicker();
                                        final pickedImage =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);
                                        if (pickedImage == null) {
                                          imageBytes = '';
                                        } else {
                                          final bytes =
                                              await File(pickedImage.path)
                                                  .readAsBytes();
                                          setState(() {
                                            im = Image.file(
                                                File(pickedImage.path));
                                            imageBytes = base64.encode(bytes);
                                          });
                                        }
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    4 -
                                                50,
                                            child: Image(image: im!.image)),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 2.5, color: Colors.blue),
                                            shape: const StadiumBorder(),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              im = null;
                                              imageBytes = '';
                                            });
                                          },
                                          child: const Text(
                                            'הסר תמונה',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  key: const ValueKey('title'),
                                  initialValue: newTitle,
                                  textAlign: TextAlign.right,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  enableSuggestions: true,
                                  decoration: const InputDecoration(
                                    hintText: 'כותרת',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'הכנס כותרת';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    newTitle = value.trim();
                                  },
                                ),
                                TextFormField(
                                  key: const ValueKey('content'),
                                  initialValue: newContent,
                                  textAlign: TextAlign.right,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  enableSuggestions: true,
                                  decoration: const InputDecoration(
                                    hintText: 'תוכן',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'הכנס תוכן';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    newContent = value.trim();
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: const StadiumBorder(),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          'ביטול',
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                      ),
                                      onPressed: () => trySubmit(
                                          formKey,
                                          popups[index].id,
                                          newTitle,
                                          newContent,
                                          imageBytes),
                                      child: const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          'שמור את השינויים!',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
