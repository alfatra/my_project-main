import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Pastikan ini diimpor untuk Distance class
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'visual_guidance_screen.dart'; // Ini sudah ada, bagus!
import 'models/place_model.dart'; // Pastikan ini diimpor

// Pastikan Anda memiliki file 'splash_screen.dart' di folder lib/ Anda
import 'splash_screen.dart';

// --- main.dart ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Navigasi Rumah Sakit STELLA',
      theme: ThemeData(
        primaryColor: const Color(0xFF004D40),
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF004D40),
          foregroundColor: Colors.white,
          elevation: 6.0,
          shadowColor: Colors.black.withOpacity(0.3),
          titleTextStyle: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(10),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        iconTheme: IconThemeData(color: Colors.teal[700]),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// --- Layar untuk Menampilkan Tur 3D Matterport ---
class MatterportViewerScreen extends StatefulWidget {
  final String tourUrl;

  const MatterportViewerScreen({super.key, required this.tourUrl});

  @override
  State<MatterportViewerScreen> createState() => _MatterportViewerScreenState();
}

class _MatterportViewerScreenState extends State<MatterportViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print("Error loading web page: ${error.description}");
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.tourUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tur Virtual 3D"),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// --- Data Tempat dengan Ikon (MODIFIED FOR VISUAL GUIDANCE) ---


// --- Layar Pemindai Kode QR ---
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanProcessed = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Kode QR Tujuan'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isScanProcessed) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? rawValue = barcodes.first.rawValue;
                if (rawValue != null) {
                  setState(() {
                    _isScanProcessed = true;
                  });
                  Navigator.pop(context, rawValue);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _animationController.value *
                            (MediaQuery.of(context).size.width * 0.7),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(0.7),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Class untuk Logika Pencarian ---
class PlaceSearchDelegate extends SearchDelegate<Place?> {
  @override
  String get searchFieldLabel => 'Cari nama lokasi...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionList();
  }

  Widget _buildSuggestionList() {
    final List<Place> suggestions = places.values.where((place) {
      return place.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final Place suggestion = suggestions[index];
        return ListTile(
          leading: Icon(suggestion.icon, color: Colors.teal),
          title: Text(suggestion.name),
          onTap: () {
            close(context, suggestion);
          },
        );
      },
    );
  }
}

// --- Layar Peta Navigasi Utama (NavigationMapScreen) ---
class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({super.key});

  @override
  _NavigationMapScreenState createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? userLocation;
  Place? destinationPlace;
  List<LatLng> routePoints = [];
  bool _isLoadingRoute = false;
  double? _routeDistance;
  double? _routeDuration;

  late AnimationController _userMarkerController;

  final LatLngBounds mapBounds = LatLngBounds.fromPoints([
    const LatLng(-5.1500, 119.4050),
    const LatLng(-5.1400, 119.4150),
  ]);

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
    _userMarkerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _userMarkerController.dispose();
    super.dispose();
  }

  void _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog("Layanan Lokasi Mati",
          "Harap aktifkan layanan lokasi di perangkat Anda.");
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog(
            "Izin Lokasi Ditolak", "Izin lokasi diperlukan untuk navigasi.");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog("Izin Lokasi Ditolak Permanen",
          "Anda perlu mengaktifkan izin lokasi dari pengaturan aplikasi.");
      return;
    }
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          userLocation = LatLng(position.latitude, position.longitude);
        });
        if (routePoints.isEmpty) {
          _mapController.move(userLocation!, 18.0);
        }
      }
    });
  }

  Future<void> getRoute() async {
    if (destinationPlace == null || userLocation == null) {
      _showErrorSnackbar("Pilih tujuan dan pastikan lokasi Anda aktif.");
      return;
    }
    setState(() {
      _isLoadingRoute = true;
      routePoints.clear();
      _routeDistance = null;
      _routeDuration = null;
    });
    final Dio dio = Dio();
    const String apiKey =
        "5b3ce3597851110001cf624811f5bce45962419394fd091e8cd28637";
    final String url =
        "https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=${userLocation!.longitude},${userLocation!.latitude}&end=${destinationPlace!.location.longitude},${destinationPlace!.location.latitude}";
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200 &&
          response.data['features'] != null &&
          response.data['features'].isNotEmpty) {
        final List<dynamic> coordinates =
            response.data['features'][0]['geometry']['coordinates'];
        final summary = response.data['features'][0]['properties']['summary'];
        if (mounted) {
          setState(() {
            routePoints =
                coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
            _routeDistance = summary['distance'];
            _routeDuration = summary['duration'];
          });
          if (routePoints.isNotEmpty) {
            _mapController.fitCamera(CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(routePoints),
              padding: const EdgeInsets.all(50.0),
            ));
          }
        }
      } else {
        throw Exception(
            'Failed to load route: Status code ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            "Gagal mendapatkan rute. Periksa koneksi atau API Key.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _resetNavigation() {
    setState(() {
      destinationPlace = null;
      routePoints.clear();
      _routeDistance = null;
      _routeDuration = null;
      if (userLocation != null) {
        _mapController.move(userLocation!, 18.0);
      }
    });
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return "0 menit";
    final duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final hours = duration.inHours > 0 ? "${duration.inHours} jam " : "";
    return "$hours$minutes menit";
  }

  String _formatDistance(double? meters) {
    if (meters == null) return "0 m";
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    } else {
      double km = meters / 1000;
      return "${km.toStringAsFixed(2)} km";
    }
  }

  void _navigateToQrScanner() async {
    final String? qrResult = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (qrResult != null && mounted) {
      if (qrResult.startsWith("PLACE_KEY:")) {
        final placeKey = qrResult.substring("PLACE_KEY:".length);
        final Place? foundPlace = places[placeKey];
        if (foundPlace != null) {
          _setDestinationAndFetchRoute(foundPlace);
        } else {
          _showErrorSnackbar(
              "Error: Kode QR valid, tapi tempat tidak ditemukan.");
        }
      } else {
        _showErrorSnackbar("Error: Format Kode QR tidak dikenali.");
      }
    }
  }

  void _openSearch() async {
    final Place? selectedPlace = await showSearch<Place?>(
      context: context,
      delegate: PlaceSearchDelegate(),
    );
    if (selectedPlace != null && mounted) {
      _setDestinationAndFetchRoute(selectedPlace);
    }
  }

void _setDestinationAndFetchRoute(Place place) {
  setState(() {
    destinationPlace = place;
    // Kosongkan rute lama saat tujuan baru dipilih
    routePoints.clear(); 
    _routeDistance = null;
    _routeDuration = null;
  });
  _mapController.move(place.location, 18.0);
  // getRoute() tidak lagi dipanggil di sini
}

  // Fungsi pembantu untuk menemukan tempat terdekat (NEW)
  String? _findNearestPlaceKey(LatLng currentLatLng) {
    double minDistance = double.infinity;
    String? nearestPlaceKey;

    places.forEach((key, place) {
      final double distanceInMeters = const Distance().as(
        LengthUnit.Meter,
        currentLatLng,
        place.location,
      );
      if (distanceInMeters < minDistance) {
        minDistance = distanceInMeters;
        nearestPlaceKey = key;
      }
    });
    // Jika pengguna terlalu jauh dari tempat yang dikenal (misalnya, >100 meter)
    if (minDistance > 100) {
      // Anda bisa sesuaikan nilai ambang batas ini
      return null;
    }
    return nearestPlaceKey;
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Navigasi RS STELLA"),
      actions: [
        IconButton(icon: const Icon(Icons.search), tooltip: "Cari Lokasi", onPressed: _openSearch),
        IconButton(icon: const Icon(Icons.refresh), tooltip: "Reset Navigasi", onPressed: _resetNavigation),
      ],
    ),
    body: Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLocation ?? const LatLng(-5.1450, 119.4095),
            initialZoom: 17.5,
            minZoom: 16.0,
            maxZoom: 20.0,
            cameraConstraint: CameraConstraint.contain(bounds: mapBounds),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.stella.navigasi',
            ),
            if (routePoints.isNotEmpty)
              PolylineLayer(polylines: [Polyline(points: routePoints, strokeWidth: 6, gradientColors: [Colors.tealAccent, Colors.cyan])]),
            MarkerLayer(
              markers: [
                if (userLocation != null)
                  Marker(point: userLocation!, width: 80, height: 80, child: UserLocationMarker(controller: _userMarkerController)),
                ...places.entries.map((entry) {
                  bool isDestination = destinationPlace == entry.value;
                  return Marker(
                    point: entry.value.location,
                    width: 120,
                    height: 80,
                    child: DestinationMarker(place: entry.value, isDestination: isDestination, onTap: () => _setDestinationAndFetchRoute(entry.value)),
                  );
                }),
              ],
            ),
          ],
        ),
        _buildTopControlPanel(),
        _buildRouteInfoCard(),
        if (_isLoadingRoute)
          Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
      ],
    ),

    // --- TAMBAHAN BARU: Tombol "Mulai" yang terkondisi ---
    floatingActionButton: destinationPlace != null && routePoints.isEmpty
        ? FloatingActionButton.extended(
            onPressed: getRoute, // Panggil fungsi getRoute saat ditekan
            label: const Text('Mulai'),
            icon: const Icon(Icons.navigation_outlined),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          )
        : null, // Sembunyikan tombol jika belum ada tujuan, atau jika rute sudah tampil
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}
  Widget _buildTopControlPanel() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Place>(
                decoration: const InputDecoration(
                  labelText: "Pilih Tujuan Anda",
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                value: destinationPlace,
                isExpanded: true,
                items: places.entries.map((entry) {
                  final place = entry.value;
                  return DropdownMenuItem<Place>(
                    value: place,
                    child: Row(
                      children: [
                        Icon(place.icon, color: Colors.teal[800], size: 22),
                        const SizedBox(width: 12),
                        Text(place.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Place? newDestination) {
                  if (newDestination != null) {
                    _setDestinationAndFetchRoute(newDestination);
                  }
                },
                hint: const Text("Tap untuk memilih tujuan"),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: (userLocation != null &&
                            destinationPlace != null &&
                            !_isLoadingRoute)
                        ? () => getRoute()
                        : null,
                    icon: const Icon(Icons.route_outlined, size: 18),
                    label: const Text("Refresh Rute"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToQrScanner,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text("Pindai"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (destinationPlace == null) {
                        _showErrorSnackbar(
                            "Pilih tujuan dahulu untuk panduan AR.");
                        return;
                      }
                      if (userLocation == null) {
                        _showErrorSnackbar(
                            "Lokasi Anda belum ada untuk fitur AR.");
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PanoramaViewerScreen(
                            currentPlace: destinationPlace!,
                            userLocation: userLocation!,
                            destinationLocation: destinationPlace!.location,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text("AR"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                  ),
                // --- GANTI DENGAN KODE BARU INI ---
// START: Tombol Panduan Visual Baru
ElevatedButton.icon(
  onPressed: () {
    // Bagian validasi awal tidak berubah
    if (userLocation == null) {
      _showErrorSnackbar("Lokasi Anda belum ditemukan.");
      return;
    }
    if (destinationPlace == null) {
      _showErrorSnackbar("Pilih tujuan terlebih dahulu.");
      return;
    }
    final String? startPlaceKey = _findNearestPlaceKey(userLocation!);
    if (startPlaceKey == null) {
      _showErrorSnackbar("Anda terlalu jauh dari lokasi yang dikenali.");
      return;
    }
    // 'places' sekarang diambil dari file place_model.dart yang di-import
    final Place? startPlace = places[startPlaceKey]; 
    final Place? destPlace = destinationPlace;
    if (startPlace == null || destPlace == null) {
      _showErrorSnackbar("Gagal menentukan lokasi awal atau tujuan.");
      return;
    }

    // Ambil data panduan gambar 2D
    final List<String>? guidanceImages =
        startPlace.visualGuidanceRoutes?[startPlace.name]
            ?[destPlace.name];
            
    // Ambil data urutan panorama 3D
    final List<String>? panoramaKeys =
        startPlace.panoramaSequenceRoutes?[startPlace.name]
            ?[destPlace.name];

    // Cek jika salah satu dari panduan (2D atau 3D) tersedia
    if ((guidanceImages != null && guidanceImages.isNotEmpty) ||
        (panoramaKeys != null && panoramaKeys.isNotEmpty)) {
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisualGuidanceScreen(
            imagePaths: guidanceImages ?? [],
            destinationName: destPlace.name,
            startLocationName: startPlace.name,
            
            // Kirim parameter yang dibutuhkan oleh VisualGuidanceScreen versi terbaru
            allPlaces: places,
            panoramaSequenceKeys: panoramaKeys ?? [],
          ),
        ),
      );
    } else {
      _showErrorSnackbar(
          "Panduan visual atau panorama untuk rute ini tidak tersedia.");
    }
  },
  icon: const Icon(Icons.image_outlined, size: 18),
  label: const Text("Panduan Visual"),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
),
// END: Tombol Panduan Visual Baru
                  // END: Tombol Panduan Visual Baru
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      bottom: (_routeDistance != null && _routeDuration != null) ? 10 : -100,
      left: 10,
      right: 10,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    _formatDistance(_routeDistance),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_routeDuration),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget Kustom untuk Marker ---
class UserLocationMarker extends StatelessWidget {
  final AnimationController controller;
  const UserLocationMarker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.8).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withOpacity(0.3),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class DestinationMarker extends StatelessWidget {
  final Place place;
  final bool isDestination;
  final VoidCallback onTap;

  const DestinationMarker({
    super.key,
    required this.place,
    required this.isDestination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDestination ? Colors.red[600] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              place.name,
              style: TextStyle(
                color: isDestination ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            place.icon,
            color: isDestination ? Colors.red[600] : Colors.teal[800],
            size: 35,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// --- Layar Panorama dengan Penunjuk Arah AR ---
class PanoramaViewerScreen extends StatefulWidget {
  final Place currentPlace;
  final LatLng userLocation;
  final LatLng destinationLocation;

  const PanoramaViewerScreen({
    super.key,
    required this.currentPlace,
    required this.userLocation,
    required this.destinationLocation,
  });

  @override
  State<PanoramaViewerScreen> createState() => _PanoramaViewerScreenState();
}

class _PanoramaViewerScreenState extends State<PanoramaViewerScreen> {
  double? _deviceHeading;
  double? _bearingToDestination;

  @override
  void initState() {
    super.initState();
    _calculateBearing();
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          _deviceHeading = event.heading;
        });
      }
    });
  }

  void _calculateBearing() {
    const Distance distance = Distance();
    final bearing = distance.bearing(
      widget.userLocation,
      widget.destinationLocation,
    );
    setState(() {
      _bearingToDestination = (bearing + 360) % 360;
    });
  }

  @override
  Widget build(BuildContext context) {
    double rotationAngle = 0.0;
    if (_deviceHeading != null && _bearingToDestination != null) {
      double angle = _bearingToDestination! - _deviceHeading!;
      rotationAngle = angle * (math.pi / 180);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Panduan AR - ${widget.currentPlace.name}"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PanoramaViewer(
            child: Image.asset(
              widget.currentPlace.panoramaPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                    "Gagal memuat panorama: ${widget.currentPlace.panoramaPath}"),
              ),
            ),
          ),
          if (_deviceHeading != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Transform.rotate(
                  angle: rotationAngle,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: Colors.cyanAccent,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Arah Ponsel: ${_deviceHeading?.toStringAsFixed(0)}° | Arah Tujuan: ${_bearingToDestination?.toStringAsFixed(0)}°',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
