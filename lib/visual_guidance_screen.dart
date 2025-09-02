import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'models/place_model.dart'; // Pastikan path import ini benar

// Enum untuk mengelola tiga mode tampilan yang berbeda
enum ViewMode { panoramaOnly, guidanceOnly, panoramaWithPip }

class VisualGuidanceScreen extends StatefulWidget {
  final List<String> imagePaths;
  final String destinationName;
  final String startLocationName;
  
  final Map<String, Place> allPlaces;
  final List<String> panoramaSequenceKeys;

  const VisualGuidanceScreen({
    super.key,
    required this.imagePaths,
    required this.destinationName,
    required this.startLocationName,
    required this.allPlaces,
    required this.panoramaSequenceKeys,
  });

  @override
  State<VisualGuidanceScreen> createState() => _VisualGuidanceScreenState();
}

class _VisualGuidanceScreenState extends State<VisualGuidanceScreen> {
  // State untuk mode utama, dimulai dengan panorama saja
  ViewMode _currentViewMode = ViewMode.panoramaOnly;
  
  // State untuk urutan panorama 360
  int _currentPanoramaIndex = 0;
  Key? _panoramaKey;

  // State untuk urutan panduan gambar 2D
  int _currentGuidanceIndex = 0;
  late final PageController _pageController;

  // State untuk posisi widget mengambang (Picture-in-Picture)
  late double _floatingWidgetTop;
  late double _floatingWidgetLeft;
  bool _isPositionInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Jika tidak ada data panorama, langsung mulai di mode panduan
    if (widget.panoramaSequenceKeys.isEmpty) {
      _currentViewMode = ViewMode.guidanceOnly;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Fungsi untuk maju ke panorama berikutnya dalam urutan
  void _nextPanorama() {
    if (_currentPanoramaIndex < widget.panoramaSequenceKeys.length - 1) {
      setState(() {
        _currentPanoramaIndex++;
        _panoramaKey = UniqueKey();
      });
    }
  }

  
@override
Widget build(BuildContext context) {
  // Inisialisasi posisi awal widget mengambang (hanya sekali)
  if (!_isPositionInitialized) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final appBarHeight = AppBar().preferredSize.height;
    final topPadding = MediaQuery.of(context).padding.top;

    _floatingWidgetTop = screenHeight - (screenHeight * 0.3) - 20 - appBarHeight - topPadding;
    _floatingWidgetLeft = screenWidth - (screenWidth * 0.4) - 15;
    _isPositionInitialized = true;
  }

  return Scaffold(
    appBar: AppBar(
      title: Text('Panduan ke ${widget.destinationName}'),
      
      // --- PERUBAHAN 1: Tambahkan tombol baru di sini ---
      actions: [
        IconButton(
          icon: _buildFabIcon(), // Menggunakan method ikon yang sama
          tooltip: 'Ganti Tampilan',
          onPressed: () {
            // Logika dari FloatingActionButton dipindahkan ke sini
            setState(() {
              if (_currentViewMode == ViewMode.panoramaOnly) {
                _currentViewMode = ViewMode.panoramaWithPip;
              } else if (_currentViewMode == ViewMode.panoramaWithPip) {
                _currentViewMode = ViewMode.guidanceOnly;
              } else { // _currentViewMode == ViewMode.guidanceOnly
                _currentViewMode = ViewMode.panoramaOnly;
              }
            });
          },
        ),
        const SizedBox(width: 8), // Memberi sedikit jarak
      ],
    ),
    
    // Body utama tidak berubah
    body: _buildBody(), 
      // Tombol bulat untuk berganti-ganti mode tampilan
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_currentViewMode == ViewMode.panoramaOnly) {
              _currentViewMode = ViewMode.panoramaWithPip; // Dari Panorama -> Tambah PiP
            } else if (_currentViewMode == ViewMode.panoramaWithPip) {
              _currentViewMode = ViewMode.guidanceOnly; // Dari Panorama+PiP -> Panduan Penuh
            } else { // _currentViewMode == ViewMode.guidanceOnly
              _currentViewMode = ViewMode.panoramaOnly; // Dari Panduan Penuh -> Panorama Penuh
            }
          });
        },
        tooltip: 'Ganti Tampilan',
        child: _buildFabIcon(), // Ikon akan berubah sesuai mode
      ),
    );
  }

  // Method untuk memilih ikon FAB secara dinamis
  Widget _buildFabIcon() {
    switch (_currentViewMode) {
      case ViewMode.panoramaOnly:
        // Saat panorama penuh, aksi berikutnya adalah menampilkan PiP
        return const Icon(Icons.picture_in_picture_alt_outlined, key: ValueKey(1));
      case ViewMode.panoramaWithPip:
        // Saat panorama+PiP, aksi berikutnya adalah ke panduan penuh
        return const Icon(Icons.photo_library_outlined, key: ValueKey(2));
      case ViewMode.guidanceOnly:
        // Saat panduan penuh, aksi berikutnya adalah kembali ke panorama
        return const Icon(Icons.threesixty_rounded, key: ValueKey(3));
    }
  }

  // Method untuk membangun body berdasarkan 3 mode
  Widget _buildBody() {
    switch (_currentViewMode) {
      case ViewMode.guidanceOnly:
        return _buildGuidanceView();
      case ViewMode.panoramaOnly:
        return _buildPanoramaView(showPip: false);
      case ViewMode.panoramaWithPip:
        return _buildPanoramaView(showPip: true);
    }
  }

  // Method untuk membangun UI mode PANORAMA (dengan atau tanpa PiP)
  Widget _buildPanoramaView({required bool showPip}) {
    final bool canGoForward = _currentPanoramaIndex < widget.panoramaSequenceKeys.length - 1;
    final String currentPlaceKey = widget.panoramaSequenceKeys.isNotEmpty 
        ? widget.panoramaSequenceKeys[_currentPanoramaIndex] 
        : "";
    final Place? currentPlace = widget.allPlaces[currentPlaceKey];

    if (currentPlace == null) {
      return const Center(child: Text("Data urutan panorama tidak tersedia."));
    }

    return Stack(
      children: [
        Positioned.fill(child: Panorama(key: _panoramaKey, child: Image.asset(currentPlace.panoramaPath, errorBuilder: (c, e, s) => const Center(child: Text("Gagal memuat panorama."))))),
        Positioned(top: 15, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)), child: Text("Anda berada di: ${currentPlace.name}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
        Positioned(bottom: 20, right: 20, child: ElevatedButton.icon(icon: const Icon(Icons.arrow_forward), label: const Text("Maju"), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white), onPressed: canGoForward ? _nextPanorama : null)),
        
        // Tampilkan widget PiP yang bisa digeser HANYA jika showPip true
        if (showPip)
          Positioned(
            top: _floatingWidgetTop,
            left: _floatingWidgetLeft,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _floatingWidgetTop += details.delta.dy;
                  _floatingWidgetLeft += details.delta.dx;
                  // Logika clamping agar tidak keluar layar
                  final screenHeight = MediaQuery.of(context).size.height;
                  final screenWidth = MediaQuery.of(context).size.width;
                  final appBarHeight = AppBar().preferredSize.height;
                  final topPadding = MediaQuery.of(context).padding.top;
                  final widgetHeight = screenHeight * 0.3;
                  final widgetWidth = screenWidth * 0.4;
                  final safeAreaHeight = screenHeight - appBarHeight - topPadding;
                  if (_floatingWidgetTop < 0) _floatingWidgetTop = 0;
                  if (_floatingWidgetTop > safeAreaHeight - widgetHeight) _floatingWidgetTop = safeAreaHeight - widgetHeight;
                  if (_floatingWidgetLeft < 0) _floatingWidgetLeft = 0;
                  if (_floatingWidgetLeft > screenWidth - widgetWidth) _floatingWidgetLeft = screenWidth - widgetWidth;
                });
              },
              child: SizedBox(width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.height * 0.3, child: _buildFloatingGuidanceView()),
            ),
          ),
      ],
    );
  }

  // Method untuk membangun UI mode PANDUAN GAMBAR LAYAR PENUH
  Widget _buildGuidanceView() {
    if (widget.imagePaths.isEmpty) {
      return const Center(child: Text("Data panduan gambar tidak tersedia."));
    }
    return Column(
      children: [
        Expanded(child: PageView.builder(controller: _pageController, itemCount: widget.imagePaths.length, onPageChanged: (index) => setState(() => _currentGuidanceIndex = index), itemBuilder: (context, index) => Padding(padding: const EdgeInsets.all(16.0), child: InteractiveViewer(panEnabled: false, minScale: 1.0, maxScale: 4.0, child: Image.asset(widget.imagePaths[index], fit: BoxFit.contain))))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ElevatedButton.icon(onPressed: _currentGuidanceIndex == 0 ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), icon: const Icon(Icons.arrow_back), label: const Text("Kembali")), Text("Langkah ${_currentGuidanceIndex + 1} / ${widget.imagePaths.length}", style: const TextStyle(fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: _currentGuidanceIndex >= widget.imagePaths.length - 1 ? null : () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), icon: const Icon(Icons.arrow_forward), label: const Text("Lanjut"))]))
      ],
    );
  }

  // Method untuk membangun WIDGET KECIL PANDUAN (PiP)
  Widget _buildFloatingGuidanceView() {
    final bool isFirstStep = _currentGuidanceIndex == 0;
    final bool isLastStep = _currentGuidanceIndex >= widget.imagePaths.length - 1;
    return Card(
      margin: EdgeInsets.zero, elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        PageView.builder(controller: _pageController, itemCount: widget.imagePaths.length, onPageChanged: (index) => setState(() => _currentGuidanceIndex = index), itemBuilder: (context, index) => Image.asset(widget.imagePaths[index], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 30)))),
        Positioned(left: 0, top: 0, bottom: 0, child: Center(child: Container(margin: const EdgeInsets.only(left: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: Colors.white, onPressed: isFirstStep ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut))))),
        Positioned(right: 0, top: 0, bottom: 0, child: Center(child: Container(margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 18), color: Colors.white, onPressed: isLastStep ? null : () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut))))),
        Positioned(bottom: 8, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)), child: Text("${_currentGuidanceIndex + 1} / ${widget.imagePaths.length}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center))))
      ]),
    );
  }
}