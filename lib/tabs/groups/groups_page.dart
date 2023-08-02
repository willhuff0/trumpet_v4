import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/firebase_image/firebase_image.dart';
import 'package:trumpet/localization.dart';
import 'package:trumpet/tabs/groups/create_group/create_group_page.dart';
import 'package:trumpet/tabs/groups/group_page.dart';
import 'package:trumpet/widgets.dart';

import 'join_group_flyout.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  var _loading = true;
  (Iterable<TGroup> iterable, int count)? _joinedGroups;
  (Iterable<TGroup> iterable, int count)? _ownedGroups;

  @override
  void initState() {
    loggedInUser.getJoinedGroups().then((value) {
      setState(() {
        _loading = false;
        _joinedGroups = value;
      });
    });
    loggedInUser.getOwnedGroups().then((value) {
      setState(() {
        _ownedGroups = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocale.groupsPage_Title.getString(context)),
        actions: [
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.group_add),
                child: Text(AppLocale.groupsPage_CreateGroupButtonLabel.getString(context)),
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
      body: _loading && _ownedGroups == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                if (_ownedGroups != null && _ownedGroups!.$1.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text('Owned groups', style: Theme.of(context).textTheme.labelMedium),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: _ownedGroups!.$2,
                    itemBuilder: (context, index) {
                      final group = _ownedGroups!.$1.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Card(
                          shadowColor: Colors.transparent,
                          child: SizedBox(
                            height: 74.0,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return GroupPage(group: group);
                                }));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Row(
                                  children: [
                                    GroupIconCircle(group: group),
                                    const SizedBox(width: 10.0),
                                    Text(group.name),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 8.0),
                      child: Divider(),
                    ),
                  ),
                ],
                if (_joinedGroups != null && _joinedGroups!.$1.isNotEmpty && !_loading) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text('Joined groups', style: Theme.of(context).textTheme.labelMedium),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: _joinedGroups!.$2,
                    itemBuilder: (context, index) {
                      final group = _joinedGroups!.$1.elementAt(index);
                      return ListTile(
                        title: Text(group.name),
                      );
                    },
                  ),
                ] else if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Text(AppLocale.groupsPage_NoJoinedGroups.getString(context)),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const JoinGroupFlyout(),
            isScrollControlled: true,
          );
        },
        label: Text(AppLocale.groupsPage_JoinGroupButtonLabel.getString(context)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
