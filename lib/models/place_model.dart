// lib/models/place_model.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// --- DEFINISI CLASS PLACE (SUDAH DILENGKAPI) ---
class Place {
  final String name;
  final LatLng location;
  final String panoramaPath;
  final String? description;
  final IconData icon;
  final Map<String, Map<String, List<String>>>? visualGuidanceRoutes;

  // --- TAMBAHAN PROPERTI UNTUK URUTAN PANORAMA ---
  final Map<String, Map<String, List<String>>>? panoramaSequenceRoutes;

  Place({
    required this.name,
    required this.location,
    required this.panoramaPath,
    this.description,
    required this.icon,
    this.visualGuidanceRoutes,
    this.panoramaSequenceRoutes, // <-- Tambahan di constructor
  });
}

// --- DATA SEMUA TEMPAT (SUDAH DILENGKAPI DENGAN CONTOH URUTAN) ---
final Map<String, Place> places = {
  "ST. Maria": Place(
    name: "ST. Maria",
    location: const LatLng(-5.1439286, 119.4085484),
    panoramaPath: "assets/panorama/panorama_st_maria.jpg", // Sesuaikan path Anda
    icon: Icons.meeting_room_outlined,
    visualGuidanceRoutes: {
      "ST. Maria": {
        "IGD": [
          "assets/guidance/st_maria_to_igd_01.webp",
          "assets/guidance/st_maria_to_igd_02_belok_kanan.webp",
          "assets/guidance/st_maria_to_igd_03_depan_igd.webp",
        ],
        "ST. Joseph": [
          "assets/guidance/st_maria_to_st_joseph_01.webp",
          "assets/guidance/st_maria_to_st_joseph_02.webp",
        ],
      },
    },
  ),
  "ST. Joseph": Place(
    name: "ST. Joseph",
    location: const LatLng(-5.1446786, 119.4090680),
    panoramaPath: "assets/panorama/panorama_demo.jpg", // Sesuaikan path Anda
    icon: Icons.meeting_room_sharp,
    visualGuidanceRoutes: {
      "ST. Joseph": {
        "BERNADETH": [
          "assets/guidance/st_joseph_to_bernadeth_01.webp",
          "assets/guidance/st_joseph_to_bernadeth_02.webp",
        ],
        "ST. Maria": [
          "assets/guidance/st_joseph_to_st_maria_01.webp",
          "assets/guidance/st_joseph_to_st_maria_02.webp",
        ],
      },
    },
    // --- TAMBAHAN DATA URUTAN PANORAMA UNTUK RUTE INI ---
    panoramaSequenceRoutes: {
      "ST. Joseph": {
        "BERNADETH": [
          // Ini adalah urutan KEY dari map 'places'
          "ST. Joseph",
          "Koridor Antara", // Titik perantara
          "BERNADETH",
        ]
      }
    },
  ),

  // --- TAMBAHAN LOKASI PERANTARA SEBAGAI CONTOH ---
  "Koridor Antara": Place(
    name: "Koridor Antara",
    location: const LatLng(-5.144400, 119.409200), // Lokasi fiktif
    panoramaPath: "assets/panorama/panorama_koridor.jpg", // Siapkan gambar panorama untuk ini
    icon: Icons.linear_scale,
  ),

  "IGD": Place(
    name: "IGD",
    location: const LatLng(-5.1437681, 119.4088918),
    panoramaPath: "assets/panorama/panorama_igd.jpg", // Sesuaikan path Anda
    icon: Icons.emergency_outlined,
    visualGuidanceRoutes: {
      "IGD": {
        "ST. Maria": [
          "assets/guidance/igd_to_st_maria_01.webp",
          "assets/guidance/igd_to_st_maria_02.webp",
        ],
        "BERNADETH": [
          "assets/guidance/igd_to_bernadeth_01.webp",
          "assets/guidance/igd_to_bernadeth_02.webp",
        ],
      },
    },
  ),
  "BERNADETH": Place(
    name: "BERNADETH",
    location: const LatLng(-5.144139, 119.40939),
    panoramaPath: "assets/panorama/panorama_bernadeth.jpg", // Sesuaikan path Anda
    icon: Icons.king_bed_outlined,
    visualGuidanceRoutes: {
      "BERNADETH": {
        "ST. Joseph": [
          "assets/guidance/bernadeth_to_st_joseph_01.webp",
          "assets/guidance/bernadeth_to_st_joseph_02.webp",
        ],
        "IGD": [
          "assets/guidance/bernadeth_to_igd_01.webp",
          "assets/guidance/bernadeth_to_igd_02.webp",
        ],
      },
    },
  ),
};