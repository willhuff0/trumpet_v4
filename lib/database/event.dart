import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import 'db.dart';

class TEvent {
  final DocumentReference _reference;
  final String _groupId;
  final String _eventId;

  final DateTime date;
  final GeoPoint? location;

  final String name;
  final Delta about;

  final List<String> attending;

  TEvent(this._reference, this._groupId, this._eventId, {required this.date, required this.location, required this.name, required this.about, required this.attending});

  static TEvent fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    var aboutJson = data['about'];
    Delta about;
    if (aboutJson == null) {
      about = Delta()..push(Operation.insert('\n'));
    } else {
      about = Delta.fromJson(aboutJson);
      if (about.isEmpty) about.push(Operation.insert('\n'));
    }

    return TEvent(
      snapshot.reference,
      snapshot.reference.id,
      snapshot.reference.parent.parent!.id,
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      name: data['name'],
      about: about,
      attending: data['attending']?.cast<String>() ?? [],
    );
  }

  static Future<TEvent> get(String group, String event) async {
    final reference = FirebaseFirestore.instance.doc('groups/$group/events/$event');
    final snapshot = await reference.get();
    return TEvent.fromSnapshot(snapshot);
  }

  Future<void> save() async {
    await _reference.set({
      'date': Timestamp.fromDate(date),
      if (location != null) 'location': location,
      'name': name,
      if (about.isNotEmpty) 'about': about.toJson(),
      'attending': attending,
    });
  }
}
