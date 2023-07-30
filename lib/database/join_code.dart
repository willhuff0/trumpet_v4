import 'package:trumpet/database/db.dart';

class TJoinCode {
  final DocumentReference _reference;
  final String _joinCode;

  final String groupId;
  final String groupName;

  TJoinCode(this._reference, this._joinCode, {required this.groupId, required this.groupName});

  static TJoinCode fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TJoinCode(
      snapshot.reference,
      snapshot.id,
      groupId: data['groupId'],
      groupName: data['groupName'],
    );
  }

  static Future<TJoinCode?> get(String joinCode) async {
    final reference = FirebaseFirestore.instance.doc('joinCodes/$joinCode');
    final snapshot = await reference.get();
    if (!snapshot.exists) return null;
    return TJoinCode.fromSnapshot(snapshot);
  }

  Future<void> save() async {
    await _reference.set({
      'groupId': groupId,
      'groupName': groupName,
    });
  }
}
