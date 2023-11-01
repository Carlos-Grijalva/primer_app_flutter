import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
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
  var historial = <WordPair>[];

  GlobalKey? historialListKey;

  void getSiguiente(){
    historial.insert(0, current);
    var animatedList = historialListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    print('Historial $historial');
    notifyListeners();
  }

  void toggleFavorito({WordPair? idea}) {
    idea = idea?? current;
    if (favoritos.contains(idea)) {
      favoritos.remove(idea);
    } else {
      favoritos.add(idea);
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
      case 1: page = FavoritosPage(); break;
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
            Expanded(
              flex: 3,
              child: HistorialListView(),
            ),
            SizedBox(height: 20,),
            //Text('Idea aleatoria'),
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
            ),
            Spacer(flex: 3,)
          ],
        ),
      );
  }
}

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favoritos.isEmpty) {
      return Center(
        child: Text('Aun no hay favoritos'),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('se han elegido ${appState.favoritos.length} favoritos'),
        ),
        for (var idea in appState.favoritos) 
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(idea.asLowerCase),
          )
      ],
    );
  }
}

class HistorialListView extends StatefulWidget {
  const HistorialListView({Key ? key}) : super(key: key);

  @override
  State<HistorialListView> createState() => _HistorialListViewState();
}

class _HistorialListViewState extends State<HistorialListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.historialListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        itemBuilder: (context, index, animation) {
          final idea = appState.historial[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorito(idea: idea);
                },
                icon: appState.favoritos.contains(idea)
                    ? Icon(Icons.favorite, size: 12,)
                    : SizedBox(),
                label: Text(idea.asLowerCase, semanticsLabel: idea.asPascalCase,),
              ),
            ),
          );
        },
        padding: EdgeInsets.only(top: 20),
        initialItemCount: appState.historial.length,
      ),
    );
  }
}