import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final kullaniciAdiController = TextEditingController();
  final sifreController = TextEditingController();

  void girisYap() async {
    final prefs = await SharedPreferences.getInstance();

    String girilenKullanici = kullaniciAdiController.text.trim();
    String girilenSifre = sifreController.text.trim();

    if (girilenKullanici.isEmpty || girilenSifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen kullanıcı adı ve şifrenizi girin."),
        ),
      );
      return;
    }

    // O an kutuya yazılan kullanıcı adına ait şifreyi sorguluyoruz
    String? kaydedilenSifre = prefs.getString("password_$girilenKullanici");

    if (kaydedilenSifre != null && kaydedilenSifre == girilenSifre) {
      // Giriş başarılıysa yazılan ismi HomeScreen'e gönderiyoruz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            playerName: girilenKullanici,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı adı veya şifre yanlış!"),
        ),
      );
    }
  }

  Widget girisKutusu({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool sifre = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Colors.purpleAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.35),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: sifre,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Colors.deepPurple,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/visily-image.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.25),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              bottom: 120,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                girisKutusu(
                  hint: "Oyuncu Adı",
                  icon: Icons.person,
                  controller: kullaniciAdiController,
                ),
                const SizedBox(height: 25),
                girisKutusu(
                  hint: "Şifre",
                  icon: Icons.lock,
                  controller: sifreController,
                  sifre: true,
                ),
                const SizedBox(height: 35),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF8C00),
                        Color(0xFFE65100),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: girisYap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    child: const Text(
                      "🚀 OYUNA BAŞLA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "✨ Yeni oyuncu musun? Kayıt Ol",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}