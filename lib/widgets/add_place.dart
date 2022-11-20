// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:latlong2/latlong.dart';

import 'package:image_picker/image_picker.dart';

import '../providers/locations_provider.dart';

// ignore: must_be_immutable
class AddPlace extends StatefulWidget {
  LatLng latLng;
  AddPlace({required this.latLng, super.key});

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String type = 'מרכז מיחזור';
  String description = '';
  Image? im;
  String imageBytes = '';
  static const listOfTypes = [
    'מרכז מיחזור',
    'ערך מורשת וטבע',
    'קומפוסטר שיתופי',
    'גינה קהילתית',
    'ספסל מסירה',
    'מקרר חברתי',
    'השאלת כלים',
    'עצי פרי',
    'תיבת קינון',
    'גינת כלבים',
    'עסק סביבתי',
    'מוקד קהילתי',
    'אתר בסיכון',
  ];

  void trySubmit() async {
    final isValidInput = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValidInput) {
      _formKey.currentState!.save();
      setState(() async {
        final response = await Provider.of<LocationsProvider>(context,
                listen: false)
            .addLocation(
                name, widget.latLng, address, type, description, imageBytes);
        if (response == 'done') {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('הוסף מיקום'),
      ),
      scrollable: true,
      actions: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
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
                              final pickedImage = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedImage == null) {
                                imageBytes = '';
                              } else {
                                final bytes =
                                    await File(pickedImage.path).readAsBytes();
                                setState(() {
                                  im = Image.file(File(pickedImage.path));
                                  imageBytes = base64.encode(bytes);
                                });
                              }
                            },
                          ),
                        )
                      : Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 4 -
                                            50,
                                    child: Image(image: im!.image)),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        width: 2.5, color: Colors.blue),
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
                ),
                TextFormField(
                  key: const ValueKey('name'),
                  textAlign: TextAlign.right,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    hintText: 'שם האתר',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'הכנס שם אתר';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      name = newValue.trim();
                    }
                  },
                ),
                TextFormField(
                  key: const ValueKey('address'),
                  textAlign: TextAlign.right,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    hintText: 'כתובת',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'הכנס כתובת';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      address = newValue.trim();
                    }
                  },
                ),
                FormField(
                  key: const ValueKey('type'),
                  builder: (FormFieldState fieldState) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Text(
                            'סוג אתר',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          DropdownButton<String>(
                            dropdownColor: Theme.of(context).primaryColor,
                            items: listOfTypes
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
                            value: type,
                            onChanged: (value) => setState(() {
                              type = value!;
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                  validator: (value) {
                    if (type.isEmpty || type == '') {
                      return 'הכנס סוג אתר';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      type = newValue.toString();
                    }
                  },
                ),
                TextFormField(
                  key: const ValueKey('description'),
                  textAlign: TextAlign.right,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    hintText: 'תיאור',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'הכנס תיאור';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      description = newValue.trim();
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => trySubmit(),
                      child: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'הוסף מיקום!',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'ביטול',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
