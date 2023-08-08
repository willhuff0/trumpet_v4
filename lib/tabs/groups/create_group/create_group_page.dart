import 'dart:async';
import 'dart:ui';

import 'package:coast/coast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/localization.dart';

part 'coast_0_name.dart';
part 'coast_1_about.dart';
part 'coast_2_iconBanner.dart';
part 'coast_3_done.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  late final CoastController _coastController;

  var _index = 0;

  String? _name;
  String? _about;
  Uint8List? _icon;
  Uint8List? _banner;

  late final List<Beach> _beaches;
  late final List<Key> _keys;

  @override
  void initState() {
    _coastController = CoastController();

    _keys = [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ];

    _beaches = [
      Beach(
        builder: (context) => _NamePage(
          key: _keys[0],
          initialName: _name,
          onSubmit: (name) {
            _name = name;
            _nextPage();
          },
        ),
      ),
      Beach(
        builder: (context) => _AboutPage(
          key: _keys[1],
          initialAbout: _about,
          onBack: (about) {
            _about = about;
            _previousPage();
          },
          onSubmit: (about) {
            _about = about;
            _nextPage();
          },
        ),
      ),
      Beach(
        builder: (context) => _IconBannerPage(
          key: _keys[2],
          name: _name,
          initalIcon: _icon,
          initalBanner: _banner,
          onBack: (icon, banner) {
            _icon = icon;
            _banner = banner;
            _previousPage();
          },
          onSubmit: (icon, banner) {
            _icon = icon;
            _banner = banner;
            _nextPage();
          },
        ),
      ),
      Beach(
        builder: (context) => _DonePage(
          key: _keys[3],
          name: _name,
          about: _about,
          icon: _icon,
          banner: _banner,
          onComplete: () {
            Navigator.pop(context);
          },
        ),
      ),
    ];

    super.initState();
  }

  void _previousPage() {
    setState(() => _index--);
    _coastController.animateTo(
      beach: _index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    setState(() => _index++);
    _coastController.animateTo(
      beach: _index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _coastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocale.createGroup_AppBar_Title.getString(context)),
        automaticallyImplyLeading: false,
        actions: _index == _beaches.length - 1
            ? null
            : [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                )
              ],
      ),
      body: Column(
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: _index / (_beaches.length - 1)),
            duration: const Duration(milliseconds: 250),
            builder: (context, value, _) {
              return LinearProgressIndicator(value: value, minHeight: 6.0);
            },
          ),
          Expanded(
            child: Coast(
              controller: _coastController,
              physics: const NeverScrollableScrollPhysics(),
              beaches: _beaches,
              observers: [
                CrabController(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
