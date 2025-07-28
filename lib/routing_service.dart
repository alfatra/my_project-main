import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RoutingService {
  final Dio _dio = Dio();
  final String _apiKey = "5b3ce3597851110001cf624811f5bce45962419394fd091e8cd28637"; // Ganti dengan API Key Anda

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final String url =
    "https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$_apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}";

    try {
      Response response = await _dio.get(url);
      List<dynamic> coordinates = response.data["features"][0]["geometry"]["coordinates"];

      return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
    } catch (e) {
      print("Error fetching route: $e");
      return [];
    }
    }
}
