import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sequence Memory Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class TileData {
  final Color backgroundColor;
  final String word;
  final TextStyle style;

  TileData({
    required this.backgroundColor,
    required this.word,
    required this.style,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<int> sequence = [];
  List<int> playerSequence = [];
  List<String> wordHistory = [];
  bool isPlaying = false;
  int score = 0;

  late final List<AnimationController> controllers;
  late final List<Animation<double>> scales;

  late final List<TileData> tilesData;

  @override
  void initState() {
    super.initState();
    
    // Initialize tiles data with Google Fonts
    tilesData = [
      TileData(
        backgroundColor: Colors.red,
        word: "Journey",
        style: GoogleFonts.pacifico(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      TileData(
        backgroundColor: Colors.green,
        word: "Through",
        style: GoogleFonts.robotoMono(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      TileData(
        backgroundColor: Colors.blue,
        word: "Magical",
        style: GoogleFonts.dancingScript(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      TileData(
        backgroundColor: Colors.yellow,
        word: "Worlds",
        style: GoogleFonts.quicksand(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
    
    controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    
    scales = controllers.map((controller) =>
      Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      )
    ).toList();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startGame() {
    setState(() {
      sequence.clear();
      playerSequence.clear();
      wordHistory.clear();
      score = 0;
      addToSequence();
    });
  }

  void addToSequence() {
    setState(() {
      sequence.add(Random().nextInt(4));
      playSequence();
    });
  }

  Future<void> playSequence() async {
    isPlaying = true;
    playerSequence.clear();
    
    for (int index in sequence) {
      await Future.delayed(const Duration(milliseconds: 500));
      await controllers[index].forward();
      await Future.delayed(const Duration(milliseconds: 300));
      await controllers[index].reverse();
    }
    
    setState(() {
      isPlaying = false;
    });
  }

  void onTileTapped(int index) {
    if (isPlaying) return;
    
    setState(() {
      playerSequence.add(index);
      controllers[index].forward().then((_) => controllers[index].reverse());
      
      // Add the word to history
      wordHistory.add(tilesData[index].word);
      
      if (playerSequence.length == sequence.length) {
        checkSequence();
      }
    });
  }

  void checkSequence() {
    bool correct = true;
    for (int i = 0; i < sequence.length; i++) {
      if (sequence[i] != playerSequence[i]) {
        correct = false;
        break;
      }
    }
    
    if (correct) {
      score++;
      Future.delayed(const Duration(milliseconds: 500), () {
        addToSequence();
      });
    } else {
      showGameOver();
    }
  }

  void showGameOver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fim de Jogo!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sua Pontuação Final: $score'),
            const SizedBox(height: 10),
            const Text('História Final:'),
            Text(wordHistory.join(' ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sequence Memory Game'),
      ),
      body: Row(
        children: [
          // Game Area
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Rodada: $score',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: const EdgeInsets.all(20),
                        children: List.generate(4, (index) {
                          return GestureDetector(
                            onTap: () => onTileTapped(index),
                            child: ScaleTransition(
                              scale: scales[index],
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tilesData[index].backgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    tilesData[index].word,
                                    style: tilesData[index].style,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      'Iniciar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Word History Panel
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'História:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        wordHistory.join(' '),
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}