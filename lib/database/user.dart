import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'db.dart';

class TUser {
  final DocumentReference _reference;
  final String _userId;

  final String name;

  final List<String> ownedGroups;
  final List<String> joinedGroups;

  TUser(this._reference, this._userId, {bool caching = false, required this.name, required this.ownedGroups, required this.joinedGroups}) : _caching = caching;
  TUser.fromSnapshot(DocumentSnapshot snapshot)
      : _reference = snapshot.reference,
        _userId = snapshot.id,
        name = snapshot.get('name'),
        ownedGroups = snapshot.get('ownedGroups') ?? [],
        joinedGroups = snapshot.get('joinedGroups') ?? [];

  var _caching = false;

  static Future<TUser> get(String user, {bool caching = false}) async {
    final reference = FirebaseFirestore.instance.doc('users/$user');
    final snapshot = await reference.get();
    return TUser.fromSnapshot(snapshot);
  }

  static Future<TUser> getOrCreate(User firebaseUser, {bool caching = false}) async {
    final reference = FirebaseFirestore.instance.doc('users/${firebaseUser.uid}');
    final snapshot = await reference.get();
    if (snapshot.exists) {
      return TUser.fromSnapshot(snapshot);
    } else {
      final newUser = TUser(
        reference,
        firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Trumpet User',
        ownedGroups: [],
        joinedGroups: [],
      );
      await newUser.save();
      return newUser;
    }
  }

  Future<void> save() async {
    await _reference.set({
      'name': name,
      if (ownedGroups.isNotEmpty) 'ownedGroups': ownedGroups,
      if (joinedGroups.isNotEmpty) 'joinedGroups': joinedGroups,
    });
  }

  void enableCaching() => _caching = true;
  void disableCaching() => _caching = false;

  // Functions

  Iterable<TGroup>? _ownedGroupsCache;
  Future<Iterable<TGroup>>? _getOwnedGroupsCall;

  /// Results are cached on this instance only if caching is enabled.
  /// Multiple calls to this function will join and await the same single future.
  Future<Iterable<TGroup>> getOwnedGroups() async {
    if (_getOwnedGroupsCall != null) return _getOwnedGroupsCall!;
    return _getOwnedGroupsCall = _getOwnedGroups();
  }

  Future<Iterable<TGroup>> _getOwnedGroups() async {
    if (_caching && _ownedGroupsCache != null) return _ownedGroupsCache!;
    final collection = FirebaseFirestore.instance.collection('groups');
    final query = collection.where(FieldPath.documentId, whereIn: ownedGroups);
    final snapshot = await query.get();
    final result = snapshot.docs.map((snapshot) => TGroup.fromSnapshot(snapshot));
    if (_caching) _ownedGroupsCache = result;
    return result;
  }

  (Iterable<TEvent> iterable, int count)? _upcommingEventsCache;
  Future<(Iterable<TEvent> iterable, int count)>? _getUpcommingEventsCall;

  /// Results are cached on this instance only if caching is enabled.
  /// Multiple calls to this function will join and await the same single future.
  Future<(Iterable<TEvent> iterable, int count)> getUpcommingEvents() async {
    if (_getUpcommingEventsCall != null) return _getUpcommingEventsCall!;
    return _getUpcommingEventsCall = _getUpcommingEvents();
  }

  Future<(Iterable<TEvent> iterable, int count)> _getUpcommingEvents() async {
    if (_caching && _upcommingEventsCache != null) return _upcommingEventsCache!;
    final collectionGroup = FirebaseFirestore.instance.collectionGroup('upcommingEvents');
    final query = collectionGroup.where('attending', arrayContains: _reference.id);
    final snapshot = await query.get();
    final result = (snapshot.docs.map((snapshot) => TEvent.fromSnapshot(snapshot)), snapshot.docs.length);
    if (_caching) _upcommingEventsCache = result;
    return result;
  }
}
