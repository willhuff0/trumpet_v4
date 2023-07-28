import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import 'db.dart';

class TEvent {
  final DocumentReference _reference;
  final String _groupId;
  final String _eventId;

  final DateTime date;

  final String name;
  final Delta about;

  TEvent(this._reference, this._groupId, this._eventId, {required this.date, required this.name, required this.about});

  static Future<TEvent> get(String group, String event) async {
    final reference = FirebaseFirestore.instance.doc('groups/$group/events/$event');
    final snapshot = await reference.get();
    return TEvent(
      reference,
      group,
      event,
      date: (snapshot.get('date') as Timestamp).toDate(),
      name: snapshot.get('name'),
      about: Delta.fromJson(json.decode(snapshot.get('about') as String)),
    );
  }

  Future<void> save() async {
    await _reference.set({
      'date': Timestamp.fromDate(date),
      'name': name,
      'about': json.encode(about.toJson()),
    });
  }
}
