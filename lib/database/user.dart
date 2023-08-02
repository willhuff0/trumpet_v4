import 'package:firebase_auth/firebase_auth.dart';

import 'db.dart';

class TUser {
  final DocumentReference reference;
  final String userId;

  final String name;

  final List<String> ownedGroups;
  final List<String> joinedGroups;

  TUser._(this.reference, this.userId, {bool caching = false, required this.name, required this.ownedGroups, required this.joinedGroups}) : _caching = caching;

  static TUser fromSnapshot(DocumentSnapshot snapshot, {bool caching = false}) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TUser._(
      snapshot.reference,
      snapshot.id,
      caching: caching,
      name: data['name'],
      ownedGroups: data['ownedGroups']?.cast<String>() ?? [],
      joinedGroups: data['joinedGroups']?.cast<String>() ?? [],
    );
  }

  var _caching = false;

  static Future<TUser> get(String user, {bool caching = false}) async {
    final reference = FirebaseFirestore.instance.doc('users/$user');
    final snapshot = await reference.get();
    return TUser.fromSnapshot(snapshot, caching: caching);
  }

  static Future<TUser> getOrCreate(User firebaseUser, {bool caching = false}) async {
    final reference = FirebaseFirestore.instance.doc('users/${firebaseUser.uid}');
    final snapshot = await reference.get();
    if (snapshot.exists) {
      return TUser.fromSnapshot(snapshot, caching: caching);
    } else {
      final newUser = TUser._(
        reference,
        firebaseUser.uid,
        caching: caching,
        name: firebaseUser.displayName ?? 'Trumpet User',
        ownedGroups: [],
        joinedGroups: [],
      );
      await newUser.save();
      return newUser;
    }
  }

  Future<void> save() async {
    await reference.set({
      'name': name,
      if (ownedGroups.isNotEmpty) 'ownedGroups': ownedGroups,
      if (joinedGroups.isNotEmpty) 'joinedGroups': joinedGroups,
    });
  }

  void enableCaching() => _caching = true;
  void disableCaching() => _caching = false;

  // Functions

  (Iterable<TGroup> iterable, int count)? _ownedGroupsCache;
  Future<(Iterable<TGroup> iterable, int count)>? _getOwnedGroupsCall;

  /// Results are cached on this instance only if caching is enabled.
  /// Multiple calls to this function will join and await the same single future.
  Future<(Iterable<TGroup> iterable, int count)> getOwnedGroups() {
    if (ownedGroups.isEmpty) return Future.value((<TGroup>[], 0));

    if (_getOwnedGroupsCall != null) return _getOwnedGroupsCall!;
    return _getOwnedGroupsCall = _getOwnedGroups();
  }

  Future<(Iterable<TGroup> iterable, int count)> _getOwnedGroups() async {
    if (_caching && _ownedGroupsCache != null) return _ownedGroupsCache!;
    final collection = FirebaseFirestore.instance.collection('groups');
    final query = collection.where(FieldPath.documentId, whereIn: ownedGroups);
    final snapshot = await query.get();
    final result = (snapshot.docs.map((docSnapshot) => TGroup.fromSnapshot(docSnapshot)), snapshot.docs.length);
    if (_caching) _ownedGroupsCache = result;
    return result;
  }

  (Iterable<TGroup> iterable, int count)? _joinedGroupsCache;
  Future<(Iterable<TGroup> iterable, int count)>? _getJoinedGroupsCall;

  /// Results are cached on this instance only if caching is enabled.
  /// Multiple calls to this function will join and await the same single future.
  Future<(Iterable<TGroup> iterable, int count)> getJoinedGroups() {
    if (joinedGroups.isEmpty) return Future.value((<TGroup>[], 0));

    if (_getJoinedGroupsCall != null) return _getJoinedGroupsCall!;
    return _getJoinedGroupsCall = _getJoinedGroups();
  }

  Future<(Iterable<TGroup> iterable, int count)> _getJoinedGroups() async {
    if (_caching && _joinedGroupsCache != null) return _joinedGroupsCache!;
    final collection = FirebaseFirestore.instance.collection('groups');
    final query = collection.where(FieldPath.documentId, whereIn: joinedGroups);
    final snapshot = await query.get();
    final result = (snapshot.docs.map((docSnapshot) => TGroup.fromSnapshot(docSnapshot)), snapshot.docs.length);
    if (_caching) _joinedGroupsCache = result;
    return result;
  }

  (Iterable<TEvent> iterable, int count)? _upcommingEventsCache;
  Future<(Iterable<TEvent> iterable, int count)>? _getUpcommingEventsCall;

  /// Results are cached on this instance only if caching is enabled.
  /// Multiple calls to this function will join and await the same single future.
  Future<(Iterable<TEvent> iterable, int count)> getUpcommingEvents() {
    if (_getUpcommingEventsCall != null) return _getUpcommingEventsCall!;
    return _getUpcommingEventsCall = _getUpcommingEvents();
  }

  Future<(Iterable<TEvent> iterable, int count)> _getUpcommingEvents() async {
    if (_caching && _upcommingEventsCache != null) return _upcommingEventsCache!;
    final collectionGroup = FirebaseFirestore.instance.collectionGroup('upcommingEvents');
    final query = collectionGroup.where('attending', arrayContains: reference.id);
    final snapshot = await query.get();
    final result = (snapshot.docs.map((docSnapshot) => TEvent.fromSnapshot(docSnapshot)), snapshot.docs.length);
    if (_caching) _upcommingEventsCache = result;
    return result;
  }
}
