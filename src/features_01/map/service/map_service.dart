  class MapService {

  static Map<String, dynamic> makeMarker({required String name, required double lat, required double long}) {
    Map<String, dynamic> marker = {
      'name': name,
      'latitude': lat,
      'longitude': long,
    };
    return marker;
  }

  static Map<String, dynamic> currentPosition = {'lat':  37.489082, 'lng': 127.008046};

}