import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import 'db.dart';

class TGroup {
  final DocumentReference _reference;
  final String _groupId;

  final String owner;

  final String name;
  final Delta about;

  TGroup(this._reference, this._groupId, {required this.owner, required this.name, required this.about});
  TGroup.fromSnapshot(DocumentSnapshot snapshot)
      : _reference = snapshot.reference,
        _groupId = snapshot.id,
        owner = snapshot.get('owner'),
        name = snapshot.get('name'),
        about = Delta.fromJson(json.decode(snapshot.get('about')));

  static Future<TGroup> get(String group) async {
    final reference = FirebaseFirestore.instance.doc('groups/$group');
    final snapshot = await reference.get();
    return TGroup.fromSnapshot(snapshot);
  }

  Future<void> save() async {
    await _reference.set({
      'name': name,
      'about': json.encode(about.toJson()),
    });
  }
}

class TGroupMember {
  final DocumentReference _reference;
  final String _groupId;
  final String _userId;

  final TGroupMemberNotificationPreference notificationPreference;

  TGroupMember(this._reference, this._groupId, this._userId, {required this.notificationPreference});

  static Future<TGroupMember> get(String group, String user) async {
    final reference = FirebaseFirestore.instance.doc('groups/$group/members/$user');
    final snapshot = await reference.get();
    return TGroupMember(
      reference,
      group,
      user,
      notificationPreference: TGroupMemberNotificationPreference.values[snapshot.get('notify')],
    );
  }

  Future<void> save() async {
    await _reference.set({
      'notify': notificationPreference.index,
    });
  }
}

enum TGroupMemberNotificationPreference {
  none,
  push,
  email,
  sms,
  pushAndEmail,
  pushAndSms,
  emailAndSms,
  pushAndEmailAndSms,
}
