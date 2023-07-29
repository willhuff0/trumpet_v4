import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uicons_brands/uicons_brands.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  var loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 4, child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 48),
                Text('Trumpet', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
            Expanded(flex: 5, child: Container()),
            FilledButton.icon(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);
                        try {
                          final googleSignIn = GoogleSignIn(
                            scopes: [
                              'profile',
                              'email',
                              'openid',
                            ],
                          );
                          final account = await googleSignIn.signIn();

                          if (account != null) {
                            final auth = await account.authentication;

                            final credential = GoogleAuthProvider.credential(
                              accessToken: auth.accessToken,
                              idToken: auth.idToken,
                            );

                            await FirebaseAuth.instance.signInWithCredential(credential);
                          }
                        } finally {
                          setState(() => loading = false);
                        }
                      },
                icon: Icon(const UIconsBrands().google),
                label: const Text('Sign in with Google')),
            FilledButton.tonalIcon(onPressed: loading ? null : () {}, icon: Icon(const UIconsBrands().apple), label: const Text('Sign in with Apple')),
            Expanded(flex: 3, child: Container()),
          ],
        ),
      ),
    );
  }
}
