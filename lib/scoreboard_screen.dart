import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'memory_game_screen.dart';

class ScoreboardScreen extends StatefulWidget {
  final String playerName;
  final int memoryTime;
  final int cupTime;
  final int holeTime;
  final int penaltyTime;

  const ScoreboardScreen({
    super.key,
    required this.playerName,
    this.memoryTime = 25,
    this.cupTime = 18,
    this.holeTime = 22,
    this.penaltyTime = 0,
  });

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class ScoreItem {
  final String name;
  final int totalSeconds;

  ScoreItem(this.name, this.totalSeconds);
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  List<ScoreItem> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _skorlariKaydetVeYukle();
  }

  Future<void> _skorlariKaydetVeYukle() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Toplam süreyi hesapla
    int currentTotal = widget.memoryTime + widget.cupTime + widget.holeTime + widget.penaltyTime;

    // 1. Oyuncunun en iyi skorunu kaydet/güncelle
    String currentKey = "score_${widget.playerName}";
    int? existingScore = prefs.getInt(currentKey);
    
    if (existingScore == null || currentTotal < existingScore) {
      await prefs.setInt(currentKey, currentTotal);
    }

    // 2. Cihazda kayıtlı gerçek oyuncu skorlarını çek
    Map<String, int> scoresMap = {};
    Set<String> keys = prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith("score_")) {
        String pName = key.replaceFirst("score_", "");
        int? pScore = prefs.getInt(key);
        if (pScore != null && pName.isNotEmpty) {
          scoresMap[pName] = pScore;
        }
      }
    }

    // 3. Küçükten büyüğe (en hızlı süreye göre) sırala
    List<ScoreItem> list = scoresMap.entries
        .map((e) => ScoreItem(e.key, e.value))
        .toList();
    
    list.sort((a, b) => a.totalSeconds.compareTo(b.totalSeconds));

    setState(() {
      leaderboard = list;
      isLoading = false;
    });
  }

  // Saniyeyi "2dk 05sn" veya "45sn" formatına dönüştüren fonksiyon
  String formatDuration(int totalSecs) {
    int minutes = totalSecs ~/ 60;
    int seconds = totalSecs % 60;
    
    if (minutes > 0) {
      return "${minutes}dk ${seconds.toString().padLeft(2, '0')}sn";
    }
    return "${seconds}sn";
  }

  @override
  Widget build(BuildContext context) {
    int currentTotal = widget.memoryTime + widget.cupTime + widget.holeTime + widget.penaltyTime;

    return Scaffold(
      body: Stack(
        children: [
          // 1. ARKA PLAN GÖRSELİ
          SizedBox.expand(
            child: Image.asset(
              "assets/images/game_bg_muted.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F1B2E), Color(0xFF120E24)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 2. ARKA PLAN BULANIKLAŞTIRMA VE HAFİF KARARTMA
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),

          // 3. EKRAN İÇERİĞİ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // BAŞLIK (Ana ekrandaki parlak tarzda)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("🏆 ", style: TextStyle(fontSize: 30)),
                      Text(
                        "SKOR TABLOSU",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(blurRadius: 15, color: Colors.orangeAccent),
                          ],
                        ),
                      ),
                      Text(" 🏆", style: TextStyle(fontSize: 30)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Liderlik Kürsüsü ve En İyi Süreler",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ANA MENÜDEKİ CANLI MOR GLASSKART
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF5B21B6).withValues(alpha: 0.70),
                                const Color(0xFF2E1065).withValues(alpha: 0.88),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.amberAccent.withValues(alpha: 0.45),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                                blurRadius: 22,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SON TUR ÖZET KUTUSU
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.amberAccent.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text("🎮 ", style: TextStyle(fontSize: 20)),
                                        Text(
                                          "Son Turun (${widget.playerName}):",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formatDuration(currentTotal),
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),
                              const Divider(color: Colors.white30, height: 1),
                              const SizedBox(height: 16),

                              // SIRA İSİM SÜRE LİSTESİ
                              Expanded(
                                child: isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(color: Colors.amber),
                                      )
                                    : leaderboard.isEmpty
                                        ? const Center(
                                            child: Text(
                                              "Henüz kayıtlı skor bulunmuyor.",
                                              style: TextStyle(color: Colors.white70, fontSize: 16),
                                            ),
                                          )
                                        : ListView.builder(
                                            physics: const BouncingScrollPhysics(),
                                            itemCount: leaderboard.length,
                                            itemBuilder: (context, index) {
                                              final item = leaderboard[index];
                                              bool isCurrentPlayer = (item.name == widget.playerName);

                                              String rankBadge;
                                              if (index == 0) {
                                                rankBadge = "🥇 1.";
                                              } else if (index == 1) {
                                                rankBadge = "🥈 2.";
                                              } else if (index == 2) {
                                                rankBadge = "🥉 3.";
                                              } else {
                                                rankBadge = "  ${index + 1}.";
                                              }

                                              return Container(
                                                margin: const EdgeInsets.symmetric(vertical: 7),
                                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                                decoration: BoxDecoration(
                                                  color: isCurrentPlayer
                                                      ? Colors.amber.withValues(alpha: 0.25)
                                                      : Colors.white.withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: isCurrentPlayer
                                                        ? Colors.amberAccent
                                                        : Colors.white.withValues(alpha: 0.15),
                                                    width: isCurrentPlayer ? 2 : 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // DERECE
                                                    SizedBox(
                                                      width: 60,
                                                      child: Text(
                                                        rankBadge,
                                                        style: const TextStyle(
                                                          color: Colors.amberAccent,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),

                                                    // OYUNCU ADI
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: TextStyle(
                                                          color: isCurrentPlayer ? Colors.amberAccent : Colors.white,
                                                          fontSize: 17,
                                                          fontWeight: isCurrentPlayer
                                                              ? FontWeight.w900
                                                              : FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),

                                                    // SÜRE (Örn: 2dk 03sn)
                                                    Text(
                                                      formatDuration(item.totalSeconds),
                                                      style: TextStyle(
                                                        color: isCurrentPlayer
                                                            ? Colors.amberAccent
                                                            : Colors.cyanAccent,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // AKSİYON BUTONLARI
                  Row(
                    children: [
                      // TEKRAR OYNA
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemoryGameScreen(
                                    playerName: widget.playerName,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.replay_rounded, size: 26),
                                SizedBox(width: 6),
                                Text(
                                  "TEKRAR",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // ANA MENÜYE DÖN
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                    playerName: widget.playerName,
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: Colors.orange.withValues(alpha: 0.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home_rounded, size: 26),
                                SizedBox(width: 6),
                                Text(
                                  "ANA MENÜ",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}