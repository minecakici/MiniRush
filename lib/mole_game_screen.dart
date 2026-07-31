import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'scoreboard_screen.dart'; // GameSummaryScreen yerine güncel ScoreboardScreen import edildi!

class InternalGameTimer extends ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;

  int get elapsedSeconds => _seconds;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      notifyListeners();
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void addPenalty(int seconds) {
    _seconds += seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class MoleGameScreen extends StatefulWidget {
  final int previousTotalSeconds;
  final String playerName;

  const MoleGameScreen({
    super.key,
    this.previousTotalSeconds = 0,
    required this.playerName,
  });

  @override
  State<MoleGameScreen> createState() => _MoleGameScreenState();
}

class _MoleGameScreenState extends State<MoleGameScreen> {
  final InternalGameTimer gameTimer = InternalGameTimer();
  late ConfettiController confettiController;

  int hitCount = 0; 
  int activeHoleIndex = -1; 
  bool isMoleABomb = false; 
  
  Timer? moleTimer;
  String penaltyMessage = "";

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
    gameTimer.start();
    startMoleSpawner();
  }

  void startMoleSpawner() {
    moleTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (!mounted) return;

      setState(() {
        penaltyMessage = "";
        isMoleABomb = Random().nextDouble() < 0.30; 
        activeHoleIndex = Random().nextInt(6);
      });
    });
  }

  void onTapHole(int index) {
    if (activeHoleIndex != index) return;

    if (isMoleABomb) {
      gameTimer.addPenalty(2);
      setState(() {
        penaltyMessage = "+2 Sn Ceza! 💣";
        activeHoleIndex = -1;
      });
    } else {
      setState(() {
        hitCount++;
        activeHoleIndex = -1;
      });

      if (hitCount >= 5) {
        moleTimer?.cancel();
        gameTimer.stop();
        confettiController.play();

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            showWinDialog();
          }
        });
      }
    }
  }

  int get currentGameSeconds => gameTimer.elapsedSeconds;
  int get cumulativeTotalSeconds => widget.previousTotalSeconds + currentGameSeconds;

  String formatTime(int totalSecs) {
    int minutes = totalSecs ~/ 60;
    int seconds = totalSecs % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1B2E),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.amberAccent, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🏆🎉", style: TextStyle(fontSize: 55)),
                const SizedBox(height: 10),
                const Text(
                  "TÜM OYUNLAR BİTTİ!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "⏱ Bu Bölümdeki Süren: ${formatTime(currentGameSeconds)}\n\n"
                  "🔥 FİNAL TOPLAM SÜREN: ${formatTime(cumulativeTotalSeconds)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Dialogu kapat

                    // Güncellenen ScoreboardScreen sayfasına yönlendiriyoruz
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoreboardScreen(
                          playerName: widget.playerName,
                          memoryTime: 20, // Tahmini ilk oyun süresi
                          cupTime: widget.previousTotalSeconds > 20 
                              ? widget.previousTotalSeconds - 20 
                              : widget.previousTotalSeconds,
                          holeTime: currentGameSeconds,
                          penaltyTime: 0,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Özeti Gör 🏆",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    moleTimer?.cancel();
    gameTimer.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/game_bg_muted.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF120E24),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("İlk ekran, geri dönülecek sayfa yok!")),
                                );
                              }
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Expanded(
                            child: Text(
                              "🔨 Köstebek Avı",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 45),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                            child: Icon(
                              index < hitCount ? Icons.pets : Icons.pets_outlined,
                              color: index < hitCount ? Colors.amberAccent : Colors.white38,
                              size: 22,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),

                      AnimatedBuilder(
                        animation: gameTimer,
                        builder: (context, child) {
                          return Text(
                            "⏱ Toplam Süre: ${formatTime(cumulativeTotalSeconds)}",
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 30,
                  child: Text(
                    penaltyMessage.isNotEmpty 
                        ? penaltyMessage 
                        : "Hızlı Ol, Bombalardan Sakın! ⚠️",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: penaltyMessage.isNotEmpty ? Colors.redAccent : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 25,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      bool isHereActive = (activeHoleIndex == index);

                      return GestureDetector(
                        onTap: () => onTapHole(index),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E2723),
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(color: const Color(0xFF5D4037), width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 90,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A0C08),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),

                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOut,
                              bottom: isHereActive ? 28 : -10,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 100),
                                opacity: isHereActive ? 1.0 : 0.0,
                                child: Text(
                                  isMoleABomb ? "💣" : "🐹",
                                  style: const TextStyle(fontSize: 52),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),

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