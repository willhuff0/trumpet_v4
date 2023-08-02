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

  final bool hasIcon;
  final bool hasBanner;

  TGroup._(this._reference, this._groupId, {bool caching = false, required this.owner, required this.name, required this.about, required this.hasIcon, required this.hasBanner}) : _caching = caching;

  static TGroup fromSnapshot(DocumentSnapshot snapshot, {bool caching = false}) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TGroup._(
      snapshot.reference,
      snapshot.id,
      owner: data['owner'],
      name: data['name'],
      about: data['about'],
      hasIcon: data['hasIcon'] ?? false,
      hasBanner: data['hasBanner'] ?? false,
      //about: Delta.fromJson(json.decode(data['about'])),
    );
  }

  var _caching = false;

  static Future<TGroup> get(String group, {bool caching = false}) async {
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
      hasIcon: false,
      hasBanner: false,
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

  Map<String, dynamic> toMap() => {
        'owner': owner,
        'name': name,
        'about': about,
        if (hasIcon) 'hasIcon': hasIcon,
        if (hasBanner) 'hasBanner': hasBanner,
        //'about': json.encode(about.toJson()),
      };

  Future<void> save() async {
    await _reference.set(toMap());
  }

  void enableCaching() => _caching = true;
  void disableCaching() => _caching = false;

  String get iconRefUrl => 'gs://announce-trumpet.appspot.com/$_groupId/icon.jpg';
  String get bannerRefUrl => 'gs://announce-trumpet.appspot.com/$_groupId/banner.jpg';

  // Functions

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

  (Iterable<TEvent> iterable, int count)? _upcommingEventsCache;
  Future<(Iterable<TEvent> iterable, int count)>? _getUpcommingEventsCall;

  /// Results are cached on this instance only if caching is enabled.
  /// Multiple calls to this function will join and await the same single future.
  Future<(Iterable<TEvent> iterable, int count)> getUpcommingEvents() {
    if (_getUpcommingEventsCall != null) return _getUpcommingEventsCall!;
    return _getUpcommingEventsCall = _getUpcommingEvents();
  }

  Future<(Iterable<TEvent> iterable, int count)> _getUpcommingEvents({String? userId}) async {
    if (_caching && _upcommingEventsCache != null) return _upcommingEventsCache!;
    final collection = _reference.collection('upcommingEvents');
    final query = userId == null ? collection : collection.where('attending', arrayContains: userId);
    final snapshot = await query.get();
    final result = (snapshot.docs.map((docSnapshot) => TEvent.fromSnapshot(docSnapshot)), snapshot.docs.length);
    if (_caching) _upcommingEventsCache = result;
    return result;
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
