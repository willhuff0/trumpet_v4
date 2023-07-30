import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/tabs/groups/create_group_page.dart';

import 'join_group_flyout.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final Future<(Iterable<TGroup> iterable, int count)> _getJoinedGroupsFuture;

  @override
  void initState() {
    _getJoinedGroupsFuture = loggedInUser.getJoinedGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Groups'),
        actions: [
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.group_add),
                child: const Text('Create group'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateGroupPage()));
                },
              ),
            ],
            builder: (context, controller, child) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  controller.open();
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        initialData: null,
        future: _getJoinedGroupsFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            final (joinedGroups, count) = asyncSnapshot.data!;
            if (count == 0) {
              return const Center(child: Text('You haven\'t joined any groups yet'));
            }
            return ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) {
                final group = joinedGroups.elementAt(index);
                return ListTile(
                  title: Text(group.name),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const JoinGroupFlyout(),
            isScrollControlled: true,
          );
        },
        label: const Text('Join group'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
