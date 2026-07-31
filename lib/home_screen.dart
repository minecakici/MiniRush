import 'dart:ui';
import 'package:flutter/material.dart';
import 'memory_game_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String playerName;

  const HomeScreen({
    super.key,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
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
                  // ÜST BAR (PROFİL & ÇIKIŞ)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // KULLANICI ADI ÇİPİ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white30, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.amber, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              playerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ÇIKIŞ BUTONU
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.2),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.white70, size: 22),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // OYUN BAŞLIĞI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("⚡ ", style: TextStyle(fontSize: 30)),
                      Text(
                        "MINI RUSH",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                          shadows: [
                            Shadow(blurRadius: 15, color: Colors.orangeAccent),
                          ],
                        ),
                      ),
                      Text(" ⚡", style: TextStyle(fontSize: 30)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "3 Mini Oyunu En Hızlı Sen Tamamla!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BÜYÜTÜLMÜŞ CANLI KART (OYUN AKIŞI & KURALLAR)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
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
                              // KART BAŞLIĞI
                              const Center(
                                child: Text(
                                  "📜 OYUN AKIŞI & KURALLAR",
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Divider(color: Colors.white30, height: 1),
                              const SizedBox(height: 20),

                              // MİNİ OYUN LİSTESİ (YAZILAR BÜYÜTÜLDÜ)
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      _buildRuleItem(
                                        icon: "🧠",
                                        title: "1. Hafıza Oyunu",
                                        desc: "Aynı görsele sahip kartları eşleştirip bölümü geç.",
                                      ),
                                      const SizedBox(height: 20),
                                      _buildRuleItem(
                                        icon: "🥤",
                                        title: "2. Bardak Oyunu",
                                        desc: "Karıştırılan bardakların altındaki gizli topu bul.",
                                      ),
                                      const SizedBox(height: 20),
                                      _buildRuleItem(
                                        icon: "🔨",
                                        title: "3. Magic Holes",
                                        desc: "Deliklerden çıkan doğru hedeflere hızlıca vur.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // GÜNCELLENEN BÜYÜK CEZA SİSTEMİ KUTUSU
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(alpha: 0.65),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 22),
                                        SizedBox(width: 8),
                                        Text(
                                          "CEZA SİSTEMİ",
                                          style: TextStyle(
                                            color: Colors.amberAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Magic Holes oyununda bombalara vurursan sürene +2 sn ceza eklenir. En düşük toplam süreyi yapmaya çalış!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // OYUNA BAŞLA BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.orange.withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemoryGameScreen(
                              playerName: playerName,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 34),
                          SizedBox(width: 8),
                          Text(
                            "OYUNA BAŞLA",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  // KURAL ELEMANI YARDIMCI WIDGET'I
  Widget _buildRuleItem({
    required String icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}