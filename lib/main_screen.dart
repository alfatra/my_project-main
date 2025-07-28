import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Utama")),
      body: const Center(
        child: Text(
          "Ini adalah halaman utama aplikasi",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
