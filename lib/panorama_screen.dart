import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PanoramaScreen extends StatelessWidget {
  const PanoramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panorama 360°")),
      body: PanoramaViewer (
        child: Image.asset('assets/panorama.jpg'), // Ganti dengan path gambar panorama kamu
      ),
    );
  }
}
