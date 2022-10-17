// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:latlong2/latlong.dart';

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
  String address = '';
  String type = 'מרכז מיחזור';
  String description = '';
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
  ];

  void trySubmit() async {
    final isValidInput = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValidInput) {
      _formKey.currentState!.save();
      setState(() async {
        final response =
            await Provider.of<LocationsProvider>(context, listen: false)
                .addLocation(widget.latLng, address, type, description);
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
    return SizedBox(
      child: AlertDialog(
        title: const Center(
          child: Text('הוסף מיקום'),
        ),
        actions: [
          Form(
            key: _formKey,
            child: Column(
              children: [
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
        ],
      ),
    );
  }
}
