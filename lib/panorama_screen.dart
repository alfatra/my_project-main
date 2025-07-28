import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

class PanoramaScreen extends StatelessWidget {
  const PanoramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panorama 360°")),
      body: Panorama(
        child: Image.asset('assets/panorama.jpg'), // Ganti dengan path gambar panorama kamu
      ),
    );
  }
}
