// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:latlong2/latlong.dart';

import '../providers/locations.dart';

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
  String type = '';
  String description = '';

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
    return AlertDialog(
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
              TextFormField(
                key: const ValueKey('type'),
                textAlign: TextAlign.right,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  hintText: 'סוג אתר',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'הכנס סוג';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  if (newValue != null) {
                    type = newValue.trim();
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
    );
  }
}
