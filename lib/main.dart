import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryMatchApp());
}

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MemoryGamePage(),
    );
  }
}

class MemoryCardItem {
  final String id;
  final String imagePath;
  final String emoji;
  bool isFaceUp;
  bool isMatched;

  MemoryCardItem({
    required this.id,
    required this.imagePath,
    required this.emoji,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class AnimalData {
  final String id;
  final String imagePath;
  final String emoji;

  const AnimalData({
    required this.id,
    required this.imagePath,
    required this.emoji,
  });
}

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  final List<AnimalData> _animals = const [
    AnimalData(id: 'bear', imagePath: 'assets/images/bear.png', emoji: '🐻'),
    AnimalData(id: 'cat', imagePath: 'assets/images/cat.png', emoji: '🐱'),
    AnimalData(id: 'dog', imagePath: 'assets/images/dog.png', emoji: '🐶'),
    AnimalData(id: 'fox', imagePath: 'assets/images/fox.png', emoji: '🦊'),
    AnimalData(id: 'lion', imagePath: 'assets/images/lion.png', emoji: '🦁'),
    AnimalData(id: 'monkey', imagePath: 'assets/images/monkey.png', emoji: '🐵'),
    AnimalData(id: 'panda', imagePath: 'assets/images/panda.png', emoji: '🐼'),
    AnimalData(id: 'rabbit', imagePath: 'assets/images/rabbit.png', emoji: '🐰'),
    AnimalData(id: 'tiger', imagePath: 'assets/images/tiger.png', emoji: '🐯'),
    AnimalData(id: 'zebra', imagePath: 'assets/images/zebra.png', emoji: '🦓'),
  ];

  late List<MemoryCardItem> _cards;

  int? _firstSelectedIndex;
  int _moves = 0;
  int _matchedPairs = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final List<MemoryCardItem> newCards = [];

    for (final animal in _animals) {
      newCards.add(
        MemoryCardItem(
          id: animal.id,
          imagePath: animal.imagePath,
          emoji: animal.emoji,
        ),
      );

      newCards.add(
        MemoryCardItem(
          id: animal.id,
          imagePath: animal.imagePath,
          emoji: animal.emoji,
        ),
      );
    }

    newCards.shuffle(Random());

    setState(() {
      _cards = newCards;
      _firstSelectedIndex = null;
      _moves = 0;
      _matchedPairs = 0;
      _isChecking = false;
    });
  }

  void _onCardTap(int index) {
    if (_isChecking) return;

    final selectedCard = _cards[index];

    if (selectedCard.isFaceUp || selectedCard.isMatched) return;

    setState(() {
      selectedCard.isFaceUp = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      final int firstIndex = _firstSelectedIndex!;
      final int secondIndex = index;

      setState(() {
        _moves++;
        _isChecking = true;
      });

      if (_cards[firstIndex].id == _cards[secondIndex].id) {
        Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;

          setState(() {
            _cards[firstIndex].isMatched = true;
            _cards[secondIndex].isMatched = true;
            _matchedPairs++;
            _firstSelectedIndex = null;
            _isChecking = false;
          });

          if (_matchedPairs == _animals.length) {
            _showWinDialog();
          }
        });
      } else {
        Timer(const Duration(milliseconds: 900), () {
          if (!mounted) return;

          setState(() {
            _cards[firstIndex].isFaceUp = false;
            _cards[secondIndex].isFaceUp = false;
            _firstSelectedIndex = null;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Congratulations!',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'You matched all pairs in $_moves moves.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startNewGame();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xfff8efff),
              Color(0xfffff8d6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 6),
                    const Text(
                      'Find all matching pairs!',
                      style: TextStyle(
                        color: Color(0xff5b9b2f),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final int crossAxisCount =
                          _getCrossAxisCount(constraints.maxWidth);

                          return GridView.builder(
                            itemCount: _cards.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.86,
                            ),
                            itemBuilder: (context, index) {
                              return MemoryCardWidget(
                                card: _cards[index],
                                index: index,
                                onTap: () => _onCardTap(index),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _startNewGame,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text(
                        'Restart',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _startNewGame,
            icon: const Icon(Icons.arrow_back_ios_new),
            color: Colors.deepPurple,
          ),
        ),
        const Expanded(
          child: Text(
            'Memory Match',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.touch_app,
                color: Colors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                '$_moves',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MemoryCardWidget extends StatelessWidget {
  final MemoryCardItem card;
  final int index;
  final VoidCallback onTap;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.index,
    required this.onTap,
  });

  static const List<List<Color>> backGradients = [
    [Color(0xff6c4df6), Color(0xff8f6fff)],
    [Color(0xffffb000), Color(0xffffd34f)],
    [Color(0xff6ee000), Color(0xff9cff2e)],
    [Color(0xffff80d5), Color(0xffff4f9a)],
    [Color(0xffff8a5b), Color(0xffffbd82)],
    [Color(0xff13b6c7), Color(0xff00d6d6)],
    [Color(0xff4ea3e3), Color(0xff73c0ff)],
  ];

  @override
  Widget build(BuildContext context) {
    final bool showFront = card.isFaceUp || card.isMatched;
    final gradient = backGradients[index % backGradients.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: showFront ? _buildFrontCard() : _buildBackCard(gradient),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      key: ValueKey('front_${card.id}_$index'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: card.isMatched ? Colors.green : Colors.deepPurple.shade100,
          width: card.isMatched ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              card.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 46),
                );
              },
            ),
          ),
          if (card.isMatched)
            const Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackCard(List<Color> gradient) {
    return Container(
      key: ValueKey('back_$index'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Color(0xffe32118),
            fontSize: 38,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}