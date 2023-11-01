import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favoritos = <WordPair>[];

  void getSiguiente(){
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorito() {
    if (favoritos.contains(current)) {
      favoritos.remove(current);
    } else {
      favoritos.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0: page = GenratorPage(); break;
      case 1: page = Placeholder(); break;
      default:
        throw UnimplementedError('No hay un widget para: $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 800,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Inicio'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('favoritos')
                    )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair idea;
  const BigCard({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textStyle = tema.textTheme.displayMedium!.copyWith(

      color: tema.colorScheme.onPrimary,
    );
    return Card(
      color: tema.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          idea.asLowerCase, 
          style: textStyle,
          semanticsLabel: "${idea.first} ${idea.second}",
        ),
      ),
    );
  }
}

class GenratorPage extends StatelessWidget {
  const GenratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var idea = appState.current;
    IconData icon;
    if (appState.favoritos.contains(idea)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border_outlined;
    }
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Idea aleatoria'),
            BigCard(idea: appState.current),

            SizedBox(height: 20,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorito();
                  },
                  label: Text('Me gusta'),
                  icon: Icon(icon),
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    appState.getSiguiente();
                  },
                  child: Text('Siguiente'),
                ),
              ],
            )
          ],
        ),
      );
  }
}