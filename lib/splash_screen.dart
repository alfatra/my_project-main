import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'main.dart'; // Ganti import ini

// SOLUSI: Tambahkan import untuk file yang berisi NavigationMapScreen
import 'hospital_map_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian atas dengan gambar latar belakang
          Expanded(
            flex: 7, // Mengambil 70% dari tinggi layar
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                // Menggunakan DecorationImage untuk kontrol lebih baik
                image: DecorationImage(
                  image: AssetImage('assets/desain.png'),
                  // SOLUSI: Menggunakan BoxFit.contain
                  // Ini akan memastikan seluruh gambar terlihat tanpa terpotong
                  // dan akan menyesuaikan ukurannya di dalam container.
                  fit: BoxFit.contain, 
                  // Jika Anda masih ingin gambar mengisi lebar tapi tidak full
                  // Anda bisa mencoba: fit: BoxFit.fitWidth,
                ),
                // Anda bisa menambahkan warna latar belakang jika gambar Anda transparan
                // atau jika ada ruang kosong akibat BoxFit.contain
                color: Color.fromARGB(255, 2, 46, 73), // Contoh warna latar belakang
              ),
              child: Container(
                // Lapisan gelap untuk membuat teks lebih mudah dibaca
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Selamat Datang",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                // SOLUSI: Pastikan nama class-nya benar (NavigationMapScreen)
                                builder: (context) => const NavigationMapScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade800,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text("Memulai"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
