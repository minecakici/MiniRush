import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'mole_game_screen.dart'; // 3. Oyun (Köstebek Avı) eklendi


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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class RedCupWidget extends StatelessWidget {
  const RedCupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 105),
      painter: RedCupPainter(),
    );
  }
}

class RedCupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    
    final Path cupPath = Path();
    cupPath.moveTo(w * 0.15, 12);
    cupPath.lineTo(w * 0.85, 12);
    cupPath.lineTo(w, h - 8);
    cupPath.lineTo(0, h - 8);
    cupPath.close();

    
    final Paint cupPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF3B30),
          Color(0xFFE00000),
          Color(0xFF990000),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));


    final Path shadowPath = Path();
    shadowPath.addOval(Rect.fromLTWH(-5, h - 6, w + 10, 12));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

   
    canvas.drawPath(cupPath, cupPaint);

    final RRect rimRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-2, h - 12, w + 4, 12),
      const Radius.circular(6),
    );
    final Paint rimPaint = Paint()..color = Colors.white;
    canvas.drawRRect(rimRRect, rimPaint);

   
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(w * 0.1, h * 0.35), Offset(w * 0.9, h * 0.35), linePaint);
    canvas.drawLine(Offset(w * 0.05, h * 0.65), Offset(w * 0.95, h * 0.65), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class CupGameScreen extends StatefulWidget {
  final int previousTotalSeconds;
  final String playerName; 

  const CupGameScreen({
    super.key,
    this.previousTotalSeconds = 0,
    required this.playerName, 
  });

  @override
  State<CupGameScreen> createState() => _CupGameScreenState();
}

class _CupGameScreenState extends State<CupGameScreen> {
  final InternalGameTimer gameTimer = InternalGameTimer();
  late ConfettiController confettiController;

  int winningCupIndex = 1;
  int selectedCupIndex = -1;
  bool isShuffling = false;
  bool isGameOver = false;
  bool areCupsUp = true;
  
  int remainingLives = 3; 
  List<int> cupPositions = [0, 1, 2];

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
    gameTimer.start(); 
    startNewRound();
  }

  void startNewRound() {
    setState(() {
      selectedCupIndex = -1;
      isGameOver = false;
      areCupsUp = true;
      cupPositions = [0, 1, 2];
      winningCupIndex = Random().nextInt(3);
    });

    
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          areCupsUp = false; 
        });

        Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            shuffleCupsOptimalSpeed();
          }
        });
      }
    });
  }

  
  void shuffleCupsOptimalSpeed() async {
    setState(() {
      isShuffling = true;
    });

    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;

      setState(() {
        int idx1 = Random().nextInt(3);
        int idx2 = Random().nextInt(3);
        while (idx1 == idx2) {
          idx2 = Random().nextInt(3);
        }

        int temp = cupPositions[idx1];
        cupPositions[idx1] = cupPositions[idx2];
        cupPositions[idx2] = temp;
      });
    }

    if (mounted) {
      setState(() {
        isShuffling = false;
      });
    }
  }

  void selectCup(int cupIndex) {
    if (isShuffling || isGameOver || areCupsUp) return;

    setState(() {
      selectedCupIndex = cupIndex;
      isGameOver = true;
    });

    if (cupIndex == winningCupIndex) {
      
      gameTimer.stop();
      confettiController.play();

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          showWinDialog();
        }
      });
    } else {
      
      setState(() {
        remainingLives--;
      });

      if (remainingLives <= 0) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            showGameOverToRulesDialog();
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

  // Kazandı Pop-up'ı -> 3. Oyuna (Köstebek Avı) Geçiş Yapar
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
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🏆", style: TextStyle(fontSize: 60)),
                const SizedBox(height: 10),
                const Text(
                  "TEBRİKLER!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "⏱ Bu Oyundaki Süren: ${formatTime(currentGameSeconds)}\n"
                  "🔥 Toplam Süren: ${formatTime(cumulativeTotalSeconds)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Diyaloğu kapat
                    
                    // 3. Oyun olan Köstebek Avı ekranına geçiş (playerName hatasız aktarılıyor)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoleGameScreen(
                          previousTotalSeconds: cumulativeTotalSeconds,
                          playerName: widget.playerName,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Sıradaki Oyuna Geç (Köstebek Avı) 🚀",
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

 
  void showGameOverToRulesDialog() {
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
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("💔", style: TextStyle(fontSize: 60)),
                const SizedBox(height: 10),
                const Text(
                  "HAKLARIN BİTTİ!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "3 hakkını da kullandın. Önceki ekrana yönlendiriliyorsun.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  },
                  child: const Text(
                    "Geri Dön 📜",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    gameTimer.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double step = screenWidth / 3;

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
              child: Container(color: Colors.black.withOpacity(0.15)),
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
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Expanded(
                            child: Text(
                              "🥤 Bardak Oyunu",
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
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              index < remainingLives ? Icons.favorite : Icons.favorite_border,
                              color: index < remainingLives ? Colors.redAccent : Colors.white38,
                              size: 26,
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

                Text(
                  isShuffling
                      ? "Bardaklar Karıştırılıyor... 👀"
                      : areCupsUp
                          ? "Topun Olduğu Yere Dikkatli Bak! 🎯"
                          : isGameOver
                              ? (selectedCupIndex == winningCupIndex
                                  ? "Tebrikler! Buldun 🎉"
                                  : "Yanlış Bardak! ❌")
                              : "Top Hangi Bardağın Altında?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 220,
                  width: screenWidth,
                  child: Stack(
                    children: List.generate(3, (cupIndex) {
                      int targetPosition = cupPositions[cupIndex];
                      double leftPosition = (targetPosition * step) + (step / 2) - 40;

                      bool isThisWinningCup = (cupIndex == winningCupIndex);
                      bool isLifted = areCupsUp ||
                          (isGameOver && (selectedCupIndex == cupIndex || isThisWinningCup));

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeInOut,
                        left: leftPosition,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => selectCup(cupIndex),
                          child: SizedBox(
                            width: 80,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Positioned(
                                  bottom: 15,
                                  child: Opacity(
                                    opacity: isThisWinningCup ? 1.0 : 0.0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Colors.amberAccent,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber,
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  bottom: isLifted ? 75 : 0,
                                  child: const RedCupWidget(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                if (isGameOver && selectedCupIndex != winningCupIndex && remainingLives > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF3B30),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: startNewRound,
                      child: Text(
                        "Yanlış Bildin! Tekrar Dene ($remainingLives Hakkın Kaldı) 🔄",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
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
