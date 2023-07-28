import 'db.dart';

late final TUser loggedInUser;

final List<TGroup> _ownedGroups = [];
Future<List<TGroup>> getOwnedGroups() async {}

final List<TGroup> _joinedGroups = [];

final List<TEvent> _events = [];
