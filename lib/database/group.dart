import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

import 'db.dart';

class TGroup {
  final DocumentReference _reference;
  final String _groupId;

  final String owner;

  final String name;
  final String about;

  TGroup._(this._reference, this._groupId, {required this.owner, required this.name, required this.about});

  static TGroup fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TGroup._(
      snapshot.reference,
      snapshot.id,
      owner: data['owner'],
      name: data['name'],
      about: data['about'],
      //about: Delta.fromJson(json.decode(data['about'])),
    );
  }

  static Future<TGroup> get(String group) async {
    final reference = FirebaseFirestore.instance.doc('groups/$group');
    final snapshot = await reference.get();
    return TGroup.fromSnapshot(snapshot);
  }

  static Future<TGroup?> create({required String name, required String about}) async {
    final reference = FirebaseFirestore.instance.collection('groups').doc();
    final group = TGroup._(
      reference,
      reference.id,
      owner: loggedInUser.userId,
      name: name,
      about: about,
    );

    final success = await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(reference, group.toMap());
      transaction.update(loggedInUser.reference, {
        'ownedGroups': FieldValue.arrayUnion([group._groupId]),
      });
    }).then((value) {
      loggedInUser.ownedGroups.add(group._groupId);
      return true;
    }, onError: (e) {
      return false;
    });

    return success ? group : null;
  }

  Future<bool> uploadIcon(Uint8List data) async {
    final ref = FirebaseStorage.instance.ref('groups/$_groupId/icon.jpg');
    return await _uploadImage(
      ref: ref,
      data: data,
      width: 256,
      height: 256,
      cropCircle: true,
      quality: 70,
    );
  }

  Future<bool> uploadBanner(Uint8List data) async {
    final ref = FirebaseStorage.instance.ref('groups/$_groupId/banner.jpg');
    return await _uploadImage(
      ref: ref,
      data: data,
      width: 1200,
      height: 600,
      cropCircle: false,
      quality: 80,
    );
  }

  Future<bool> _uploadImage({required Reference ref, required Uint8List data, required int width, required int height, required bool cropCircle, required int quality}) async {
    try {
      final result = await compute(
        (message) {
          var image = decodeImage(message.$1);
          if (image == null) return null;
          image = copyResize(image, width: message.$2, height: message.$3, interpolation: Interpolation.cubic);
          if (message.$4) image = copyCropCircle(image);
          final bytes = encodeJpg(image, quality: message.$5);
          return bytes;
        },
        (data, width, height, cropCircle, quality),
      );
      if (result == null) return false;
      await ref.putData(result);
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> toMap() => {
        'owner': owner,
        'name': name,
        'about': about,
        //'about': json.encode(about.toJson()),
      };

  Future<void> save() async {
    await _reference.set(toMap());
  }
}

class TGroupMember {
  final DocumentReference _reference;
  final String _groupId;
  final String _userId;

  final TGroupMemberNotificationPreference notificationPreference;

  TGroupMember._(this._reference, this._groupId, this._userId, {required this.notificationPreference});

  static Future<TGroupMember> get(String group, String user) async {
    final reference = FirebaseFirestore.instance.doc('groups/$group/members/$user');
    final snapshot = await reference.get();
    return TGroupMember._(
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
