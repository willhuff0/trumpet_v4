import 'db.dart';

class TUser {
  final DocumentReference _reference;
  final String _userId;

  final String name;

  final List<String> ownedGroups;
  final List<String> joinedGroups;

  TUser(this._reference, this._userId, {required this.name, required this.ownedGroups, required this.joinedGroups});

  static Future<TUser> get(String user) async {
    final reference = FirebaseFirestore.instance.doc('users/$user');
    final snapshot = await reference.get();
    return TUser(
      reference,
      user,
      name: snapshot.get('name'),
      ownedGroups: snapshot.get('ownedGroups') ?? [],
      joinedGroups: snapshot.get('joinedGroups') ?? [],
    );
  }

  Future<void> save() async {
    await _reference.set({
      'name': name,
      if (ownedGroups.isNotEmpty) 'ownedGroups': ownedGroups,
      if (joinedGroups.isNotEmpty) 'joinedGroups': joinedGroups,
    });
  }
}
