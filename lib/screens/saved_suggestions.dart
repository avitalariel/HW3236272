import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_notifier.dart';
import '../providers/suggestions_notifier.dart';

class SavedSuggestionsScreen extends StatefulWidget {
  const SavedSuggestionsScreen({super.key});
  // const SavedSuggestionsScreen(this._saved, {super.key});

  @override
  State<SavedSuggestionsScreen> createState() => _SavedSuggestionsScreenState();
}

class _SavedSuggestionsScreenState extends State<SavedSuggestionsScreen> {
  late List<WordPair> _saved;
  late User? _user;

  @override
  Widget build(BuildContext context) {
    _saved = context.read<SuggestionsNotifier>().saved;
    _user = context.read<AuthNotifier>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestions'),
      ),
      body: ListView.builder(
          itemCount: _saved.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
                background: Container(
                  color: Colors.deepPurple,
                  child: Row(
                    children: const <Widget>[
                      SizedBox(width: 10), // give it width

                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 30), // give it width

                      Text('Delete suggestion',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                key: ValueKey<String>(_saved[index].asPascalCase),
                confirmDismiss: (direction) async {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Suggestion'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                  'Are you sure you want to delete ${_saved[index].asPascalCase} from your saved suggestions?'),
                              // Text('Would you like to approve of this message?'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            onPressed: () {
                              setState(() {
                                _saved.removeAt(index);
                                context.read<SuggestionsNotifier>().setSavedSuggestions(_saved, _user?.uid);
                              } );
                              Navigator.pop(context, true);
                            },
                            child: const Text('Yes'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                        ],
                      );
                    },
                  );
                  return false;
                },
                child:
                    ListTile(title: Text(_saved[index].asPascalCase)));
          }),
    );
  }
}
