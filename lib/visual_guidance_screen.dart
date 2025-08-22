// lib/visual_guidance_screen.dart

import 'package:flutter/material.dart';

class VisualGuidanceScreen extends StatefulWidget {
  final List<String> imagePaths;
  final String destinationName;
  final String startLocationName;

  const VisualGuidanceScreen({
    super.key,
    required this.imagePaths,
    required this.destinationName,
    required this.startLocationName,
  });

  @override
  State<VisualGuidanceScreen> createState() => _VisualGuidanceScreenState();
}

class _VisualGuidanceScreenState extends State<VisualGuidanceScreen> {
  int _currentIndex = 0;

  void _nextStep() {
    if (_currentIndex < widget.imagePaths.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImagePath = _currentIndex < widget.imagePaths.length
        ? widget.imagePaths[_currentIndex]
        : null;

    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.imagePaths.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Panduan Visual ke ${widget.destinationName}"),
      ),
      body: Stack(
        children: [
          // Gambar Utama
          Positioned.fill(
            child: currentImagePath != null
                ? Image.asset(
                    currentImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            "Gagal memuat gambar: $currentImagePath",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text("Tidak ada gambar panduan."),
                  ),
          ),

          // Tombol Kembali (Kiri)
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height / 2 - 30, // Vertikal tengah
            child: Opacity(
              opacity: isFirst ? 0.3 : 0.7,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 60, color: Colors.white),
                onPressed: isFirst ? null : _previousStep,
              ),
            ),
          ),

          // Tombol Maju (Kanan)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 30, // Vertikal tengah
            child: Opacity(
              opacity: isLast ? 0.3 : 0.7,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 60, color: Colors.white),
                onPressed: isLast ? null : _nextStep,
              ),
            ),
          ),

          // Informasi Langkah (Bawah Tengah)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Langkah ${_currentIndex + 1} dari ${widget.imagePaths.length}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
