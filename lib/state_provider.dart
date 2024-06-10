import 'package:flutter/material.dart';

class NoteProvider with ChangeNotifier {
  List<Map<String, dynamic>> _latestNotes = [];

  List<Map<String, dynamic>> get latestNotes => _latestNotes;

  set latestNotes(List<Map<String, dynamic>> notes) {
    _latestNotes = notes;
    notifyListeners();
  }
}
