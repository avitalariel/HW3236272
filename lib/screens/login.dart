import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hello_me/providers/suggestions_notifier.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../providers/auth_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool isButtonLoginDisabled = false;
  bool isButtonSignupDisabled = false;
  bool _validate = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Welcome to Startup Names Generator, please log in!',
                  // style: TextStyle(
                  //     color: Colors.blue,
                  //     fontWeight: FontWeight.w500,
                  //     fontSize: 30),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                controller: _password,
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: ElevatedButton(
                  onPressed: isButtonLoginDisabled
                      ? null
                      : () async {
                          setState(() => isButtonLoginDisabled = true);
                          if (!await context
                              .read<AuthNotifier>()
                              .signIn(_email.text, _password.text)) {
                            setState(() => isButtonLoginDisabled = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'There was an error logging into the app')));
                          } else {
                            var userUid =
                                context.read<AuthNotifier>().user?.uid;
                            await context
                                .read<SuggestionsNotifier>()
                                .getUserSavedSuggestions(userUid);
                            await context
                                .read<AuthNotifier>()
                                .downloadFile(userUid);
                            if (!mounted) return;
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.deepPurple),
                  child: const Text('Log in'),
                )),
            Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: ElevatedButton(
                  onPressed: isButtonSignupDisabled
                      ? null
                      : () async {
                          var bottomHeight =
                              MediaQuery.of(context).viewInsets.bottom;

                          showBarModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              builder: (context) => StatefulBuilder(
                                    builder: (BuildContext context,
                                            StateSetter setState) =>
                                        Container(
                                      height: 450 - bottomHeight,
                                      padding: const EdgeInsets.all(10),
                                      child: Column(children: [
                                        const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              'Please confirm your password below:',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        TextField(
                                          controller: _confirmPassword,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              labelText: 'Password',
                                              errorText: _validate == false
                                                  ? 'Passwords must match'
                                                  : null),
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              if (_confirmPassword.text !=
                                                  _password.text) {
                                                setState(() {
                                                  _validate = false;
                                                  isButtonSignupDisabled =
                                                      false;
                                                });
                                              } else if (await context
                                                      .read<AuthNotifier>()
                                                      .signUp(_email.text,
                                                          _password.text) ==
                                                  null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Unable to sign up.')));
                                                setState(() =>
                                                    isButtonSignupDisabled =
                                                        false);
                                              } else {
                                                var userUid = context
                                                    .read<AuthNotifier>()
                                                    .user
                                                    ?.uid;
                                                context
                                                    .read<SuggestionsNotifier>()
                                                    .addUser(
                                                        _email.text, userUid);
                                                try {
                                                  await context
                                                      .read<AuthNotifier>()
                                                      .downloadFile(userUid);
                                                } catch (e) {
                                                  print(e);
                                                }
                                                if (!mounted) return;
                                                var nav = Navigator.of(context);
                                                nav.pop();
                                                nav.pop();
                                              }
                                            },
                                            child: const Text('Confirm'))
                                      ]),
                                    ),
                                  ));
                        },
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.blueAccent),
                  child: const Text('New user? Click to sign up'),
                )),
          ],
        ));
  }
}
