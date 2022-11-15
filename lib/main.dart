import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_me/providers/auth_notifier.dart';
import 'package:hello_me/providers/suggestions_notifier.dart';
import 'package:hello_me/screens/random_words.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController listViewController = ScrollController();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthNotifier>(create: (_) => AuthNotifier()),
          ChangeNotifierProvider<SuggestionsNotifier>(
              create: (_) => SuggestionsNotifier()),
        ],
        child: MaterialApp(
          title: 'Startup Name Generator',
          theme: ThemeData(
            // Add the 5 lines from here...
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.black,
            ),
          ),
          home: const RandomWordsScreen(),
        ));
  }
}