import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/providers/auth_notifier.dart';
import 'package:hello_me/screens/saved_suggestions.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../helpers/avatar.dart';
import '../providers/suggestions_notifier.dart';
import 'login.dart';

final snappingSheetController = SnappingSheetController();

class RandomWordsScreen extends StatefulWidget {
  const RandomWordsScreen({Key? key}) : super(key: key);

  @override
  State<RandomWordsScreen> createState() => _RandomWordsScreenState();
}

class _RandomWordsScreenState extends State<RandomWordsScreen> {
  final _suggestions = <WordPair>[];
  late List<WordPair> _saved;
  final _biggerFont = const TextStyle(fontSize: 18);
  late User? _user;
  ScrollController listViewController = ScrollController();
  late bool close = true;

  @override
  Widget build(BuildContext context) {
    _saved = context.watch<SuggestionsNotifier>().saved;
    _user = context.watch<AuthNotifier>().user;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
              icon: context.watch<AuthNotifier>().status == Status.authenticated
                  ? const Icon(Icons.exit_to_app)
                  : const Icon(Icons.login),
              onPressed:
                  context.watch<AuthNotifier>().status == Status.authenticated
                      ? _logout
                      : _pushLogin,
              tooltip: 'Login',
            ),
          ],
        ),
        body: context.watch<AuthNotifier>().status == Status.authenticated
            ? SnappingSheet(
                lockOverflowDrag: true,
                controller: snappingSheetController,
                grabbing: GrabbingWidget(close),
                grabbingHeight: 40,
                sheetAbove: null,
            snappingPositions: const [
              SnappingPosition.factor(
                positionFactor: 0.0,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.top,
              ),
              SnappingPosition.pixels(
                positionPixels: 400,
                snappingCurve: Curves.easeInExpo,
                snappingDuration: Duration(milliseconds: 1750),
              ),
              SnappingPosition.factor(
                positionFactor: 1.0,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.bottom,
              ),
            ],
                sheetBelow: SnappingSheetContent(
                  draggable: true,
                  // childScrollController: listViewController,
                  child: Container(
                      height: 50,
                      color: Colors.white,
                      child: const SingleChildScrollView(
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: ImageUploads()))),
                ),
                child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, i) {
                      if (i.isOdd) return const Divider();

                      final index = i ~/ 2;
                      if (index >= _suggestions.length) {
                        _suggestions.addAll(generateWordPairs().take(10));
                      }
                      final alreadySaved = _saved.contains(_suggestions[index]);

                      return ListTile(
                          title: Text(
                            _suggestions[index].asPascalCase,
                            style: _biggerFont,
                          ),
                          trailing: Icon(
                            alreadySaved
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: alreadySaved ? Colors.red : null,
                            semanticLabel:
                                alreadySaved ? 'Remove from saved' : 'Save',
                          ),
                          onTap: () {
                            setState(() {
                              if (alreadySaved) {
                                _saved.remove(_suggestions[index]);
                                context
                                    .read<SuggestionsNotifier>()
                                    .setSavedSuggestions(_saved, _user?.uid);
                              } else {
                                _saved.add(_suggestions[index]);
                                context
                                    .read<SuggestionsNotifier>()
                                    .setSavedSuggestions(_saved, _user?.uid);
                              }
                            });
                          });
                    }))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  if (i.isOdd) return const Divider();

                  final index = i ~/ 2;
                  if (index >= _suggestions.length) {
                    _suggestions.addAll(generateWordPairs().take(10));
                  }
                  final alreadySaved = _saved.contains(_suggestions[index]);

                  return ListTile(
                      title: Text(
                        _suggestions[index].asPascalCase,
                        style: _biggerFont,
                      ),
                      trailing: Icon(
                        alreadySaved ? Icons.favorite : Icons.favorite_border,
                        color: alreadySaved ? Colors.red : null,
                        semanticLabel:
                            alreadySaved ? 'Remove from saved' : 'Save',
                      ),
                      onTap: () {
                        setState(() {
                          if (alreadySaved) {
                            _saved.remove(_suggestions[index]);
                            context
                                .read<SuggestionsNotifier>()
                                .setSavedSuggestions(_saved, _user?.uid);
                          } else {
                            _saved.add(_suggestions[index]);
                            context
                                .read<SuggestionsNotifier>()
                                .setSavedSuggestions(_saved, _user?.uid);
                          }
                        });
                      });
                }));
  }

  void _pushSaved() async {
    await context
        .read<SuggestionsNotifier>()
        .getUserSavedSuggestions(_user?.uid);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SavedSuggestionsScreen()),
    );
  }

  void _pushLogin() {
    context.read<SuggestionsNotifier>().setSavedSuggestions(_saved, _user?.uid);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _logout() {
    context.read<AuthNotifier>().logOut();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Successfully logged out')));
  }
}

class GrabbingWidget extends StatefulWidget {
  late bool close;
  GrabbingWidget(this.close, {super.key});


  @override
  State<GrabbingWidget> createState() => _GrabbingWidgetState();
}

class _GrabbingWidgetState extends State<GrabbingWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          widget.close
              ? snappingSheetController
              .setSnappingSheetPosition(145)
              : snappingSheetController
              .setSnappingSheetPosition(30);

          setState(() {
            widget.close = !widget.close;
          });
        },
        child: SizedBox(
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Welcome back, ${context.read<AuthNotifier>().user?.email}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          )),
                      const Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.arrow_drop_down)),
                          ))
                    ]))));
  }
}
