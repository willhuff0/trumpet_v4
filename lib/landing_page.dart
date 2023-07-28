import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note),
              Text(
                'Trumpet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
