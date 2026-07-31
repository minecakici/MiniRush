import 'package:flutter/material.dart';
import 'dart:ui';
import 'scoreboard_screen.dart';

class GameSummaryScreen extends StatelessWidget {
  final String playerName;
  final int memoryGameSeconds;
  final int cupGameSeconds;
  final int moleGameSeconds;

  const GameSummaryScreen({
    super.key,
    required this.playerName,
    this.memoryGameSeconds = 30,
    required this.cupGameSeconds,
    required this.moleGameSeconds,
  });

  int get finalTotalSeconds => memoryGameSeconds + cupGameSeconds + moleGameSeconds;

  String formatTime(int totalSecs) {
    int minutes = totalSecs ~/ 60;
    int seconds = totalSecs % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1F1B2E), Color(0xFF120E24)],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.2),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: const Text("🏆", style: TextStyle(fontSize: 65)),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    const Text(
                      "Mini Rush Tamamlandı!",
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    Text(
                      "Tebrikler, $playerName!",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.amberAccent.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildScoreRow("🃏 Hafıza Kartları:", formatTime(memoryGameSeconds)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(color: Colors.white24, height: 1),
                              ),
                              _buildScoreRow("🥤 Bardak Oyunu:", formatTime(cupGameSeconds)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(color: Colors.white24, height: 1),
                              ),
                              _buildScoreRow("🔨 Köstebek Oyunu:", formatTime(moleGameSeconds)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(color: Colors.amberAccent, height: 1.5),
                              ),
                              _buildScoreRow(
                                "🔥 Final Toplam Süre:", 
                                formatTime(finalTotalSeconds), 
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () {
                          // ScoreboardScreen parametreleri güncellendi
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScoreboardScreen(
                                playerName: playerName,
                                memoryTime: memoryGameSeconds,
                                cupTime: cupGameSeconds,
                                holeTime: moleGameSeconds,
                                penaltyTime: 0,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Skor Tablosunu Gör 🏆",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text(
                          "Ana Menüye Dön 🏠",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.amberAccent : Colors.white70,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? Colors.amberAccent : Colors.white,
            fontSize: isBold ? 20 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}