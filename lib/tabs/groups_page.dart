import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/database/join_code.dart';

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
                onPressed: () {},
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
          showModalBottomSheet(context: context, builder: (context) => JoinGroupFlyout(), isScrollControlled: true);
        },
        label: const Text('Join group'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class JoinGroupFlyout extends StatefulWidget {
  const JoinGroupFlyout({super.key});

  @override
  State<JoinGroupFlyout> createState() => _JoinGroupFlyoutState();
}

class _JoinGroupFlyoutState extends State<JoinGroupFlyout> {
  Timer? _onChangedTimer;
  var _searching = false;

  var _searched = false;
  TJoinCode? _result;

  void _onChangedHandler(String value) {
    _onChangedTimer?.cancel();
    _onChangedTimer = Timer(const Duration(milliseconds: 700), () => _search(value));
  }

  void _search(String value) async {
    if (_searching) return;
    _searching = true;

    try {
      if (value.length <= 3) {
        setState(() {
          _searched = false;
          _result = null;
        });
        return;
      }

      final joinCode = await TJoinCode.get(value);
      if (joinCode != null) {
        setState(() {
          _searched = true;
          _result = joinCode;
        });
      } else {
        setState(() {
          _searched = true;
          _result = null;
        });
      }
    } catch (e) {
      setState(() {
        _searched = true;
        _result = null;
      });
    } finally {
      _searching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: math.max(375, MediaQuery.viewInsetsOf(context).bottom + (_searched ? 190 : 110)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14.0)),
                      filled: true,
                    ),
                    autocorrect: false,
                    autofillHints: null,
                    autofocus: true,
                    onChanged: _onChangedHandler,
                  ),
                ),
                const SizedBox(width: 14.0),
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinGroupQRCodePage()));
                  },
                  icon: const Icon(Icons.qr_code),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (_searched)
              Card(
                elevation: 6.0,
                shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(_result?.groupName ?? 'Invalid code')),
                      FilledButton(
                        onPressed: _result == null ? null : () {},
                        child: const Text('Join'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class JoinGroupQRCodePage extends StatelessWidget {
  const JoinGroupQRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
              torchEnabled: false,
              formats: [BarcodeFormat.qrCode],
            ),
            onDetect: (capture) {
              //Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(capture.raw.toString()),
                ),
              );
            },
          ),
          ClipRRect(child: Container(color: Colors.black.withOpacity(0.4))),
        ],
      ),
    );
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(center: new Offset(size.width / 2, size.height / 2), radius: size.width * 0.45))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
