import 'dart:async';

import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  late final PageController _pageController;

  var index = 0;

  final pages = const [
    _NamePage(),
  ];

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create group'),
        automaticallyImplyLeading: false,
        actions: [
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
            tween: Tween<double>(begin: 0, end: index / pages.length),
            duration: const Duration(milliseconds: 250),
            builder: (context, value, _) {
              return LinearProgressIndicator(value: value, minHeight: 6.0);
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

class _NamePage extends StatefulWidget {
  const _NamePage({super.key});

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _controller;
  Timer? _onChangedTimer;

  var _valid = false;

  void _onChangedHandler() {
    _onChangedTimer?.cancel();
    _onChangedTimer = Timer(const Duration(milliseconds: 700), () => _validate());
  }

  void _validate() {
    if (_formKey.currentState != null) {
      setState(() {
        _valid = _formKey.currentState!.validate();
      });
    }
  }

  @override
  void initState() {
    _formKey = GlobalKey();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _onChangedHandler,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
              child: Text(
                'Use the shortest complete name for your group. Your name will only be visible to members of your group.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18.0),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                labelText: 'Name',
                contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Provide a name';
                if (value.trim() != value) return 'Name cannot begin or end with a space';
                if (value.length < 3) return 'Must be at least three characters';
                return null;
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          disabledElevation: 0.0,
          onPressed: _valid ? () {} : null,
          child: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}
