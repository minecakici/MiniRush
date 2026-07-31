import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Buzlama (blur) efekti için
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'game_timer.dart';
import 'cup_game_screen.dart'; // Bardak oyunu ekranını dahil ettik

class MemoryGameScreen extends StatefulWidget {
  final String playerName; // Oyuncu ismi dışarıdan alınacak şekilde eklendi

  const MemoryGameScreen({
    super.key,
    this.playerName = "Oyuncu", // Varsayılan değer verildi
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final GameTimer gameTimer = GameTimer();
  late ConfettiController confettiController;

  final List<String> imagePaths = [
    "assets/images/star.png",
    "assets/images/dice.png",
    "assets/images/darts.png",
    "assets/images/purple_dart.png",
    "assets/images/cards.png",
    "assets/images/confetti.png",
    "assets/images/ribbon.png",
    "assets/images/rocket.png",
    "assets/images/game_over.png",
    "assets/images/puzzle.png",
  ];

  late List<String> cards;
  late List<bool> opened;
  late List<bool> matched;

  int firstCard = -1;
  int secondCard = -1;
  int moves = 0;
  bool lockBoard = false;

  @override
  void initState() {
    super.initState();

    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    startGame();
    gameTimer.start();
  }

  void startGame() {
    cards = [
      ...imagePaths,
      ...imagePaths,
    ];

    cards.shuffle(Random());

    opened = List.generate(
      cards.length,
      (index) => false,
    );

    matched = List.generate(
      cards.length,
      (index) => false,
    );

    moves = 0;
  }

  void cardClick(int index) {
    if (lockBoard) return;
    if (opened[index]) return;
    if (matched[index]) return;

    setState(() {
      opened[index] = true;
    });

    if (firstCard == -1) {
      firstCard = index;
    } else {
      secondCard = index;
      moves++;
      checkCards();
    }
  }

  void checkCards() {
    if (cards[firstCard] == cards[secondCard]) {
      setState(() {
        matched[firstCard] = true;
        matched[secondCard] = true;
      });

      firstCard = -1;
      secondCard = -1;

      if (matched.every((element) => element)) {
        gameTimer.stop(); // Kartlar bitince süreyi durdur
        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            showWinDialog();
          },
        );
      }
    } else {
      lockBoard = true;

      Future.delayed(
        const Duration(milliseconds: 900),
        () {
          setState(() {
            opened[firstCard] = false;
            opened[secondCard] = false;
          });

          firstCard = -1;
          secondCard = -1;
          lockBoard = false;
        },
      );
    }
  }

  void showWinDialog() {
    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🏆",
                  style: TextStyle(
                    fontSize: 70,
                  ),
                ),
                const Text(
                  "🎉 HARİKA!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Hafıza Kartları Tamamlandı",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 15),
                Text(
                  "🎯 Hamle: $moves\n"
                  "⏱ Süre: ${gameTimer.formattedTime}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF381C7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Dialog'u kapat

                    // BARDAK OYUNUNA GEÇİŞ YAP, SÜREYİ VE OYUNCU İSMİNİ AKTAR
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CupGameScreen(
                          previousTotalSeconds: gameTimer.elapsedSeconds,
                          playerName: widget.playerName,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Sıradaki Oyuna Geç 🚀",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. KATMAN: ARKA PLAN GÖRSELİ
          SizedBox.expand(
            child: Image.asset(
              "assets/images/game_bg_muted.png",
              fit: BoxFit.cover,
            ),
          ),

          // 2. KATMAN: BUZLU CAM (BLUR) VE HAFİF KARARTMA
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
              child: Container(
                color: Colors.black.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              "🃏 Hafıza Kartları ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 45),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: gameTimer,
                        builder: (context, child) {
                          return Text(
                            "⏱ Mini Rush Süresi: "
                            "${gameTimer.formattedTime}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        "🎯 Hamle: $moves",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GridView.builder(
                      itemCount: cards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 6,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            cardClick(index);
                          },
                          child: MemoryCard(
                            image: cards[index],
                            open: opened[index],
                            matched: matched[index],
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),

          // 🎊 GERÇEK KONFETİ
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.08,
              numberOfParticles: 40,
              gravity: 0.25,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryCard extends StatelessWidget {
  final String image;
  final bool open;
  final bool matched;

  const MemoryCard({
    super.key,
    required this.image,
    required this.open,
    required this.matched,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: open ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        final angle = value * pi;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: value < 0.5
              ? cardBack()
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: cardFront(),
                ),
        );
      },
    );
  }

  Widget cardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B42C8).withOpacity(0.75),
            const Color(0xFF381C7A).withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            "assets/images/card_back.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget cardFront() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: matched
                ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.9),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        if (matched)
          const Positioned(
            top: 3,
            right: 3,
            child: Text(
              "✨",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ),
      ],
    );
  }
}