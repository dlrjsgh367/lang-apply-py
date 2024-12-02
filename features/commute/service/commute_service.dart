import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CommuteService {

  static coord2RegionCode(double lat, double lng) async {
    const apiKey = '5118e62bb72b728896d88de20f4b265b';
    final url =
        'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=$lng&y=$lat';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'KakaoAK $apiKey'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> codeMap = {
        'hCode': '',
        'bCode': '',
      };
      final data = json.decode(response.body);
      if (data['documents'].isNotEmpty) {
        for (var region in data['documents']) {
          if (region['region_type'] == 'H') {
            codeMap['hCode'] = region['code'];
          } else if (region['region_type'] == 'B') {
            codeMap['bCode'] = region['code'];
          }
        }
        return codeMap;
      }
    }
    return null;
  }

  static Future<String> coord2Address(double lat, double lng) async {
    const apiKey = '5118e62bb72b728896d88de20f4b265b';
    final url =
        'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lng&y=$lat&input_coord=WGS84';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'KakaoAK $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['documents'] != null && data['documents'].isNotEmpty) {
          final roadAddress = data['documents'][0]['road_address'];
          if (roadAddress != null && roadAddress['address_name'] != null) {
            return roadAddress['address_name'];
          }
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return '';
  }

  static getAddressDongFromCoordinates(
      double latitude, double longitude) async {
    final apiKey = Platform.isIOS
        ? 'AIzaSyBcxhil-S1hlxZm7-76Jk_VimVXHWzhjzk'
        : 'AIzaSyBIDv2VfAHq1ZwcU_6RmoAvKrAGiFpOHNE'; // Google Maps Geocoding API 키
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey&language=ko';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final addressComponents = data['results'];
          for (var component in addressComponents) {
            final types = component['types'];
            if (types.contains('sublocality_level_2')) {
              return component['address_components'];
            }
          }
        } else {
          print('Geocoding API returned status: ${data['status']}');
          return null;
        }
      } else {
        print(
            'Failed to fetch address from coordinates. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching address from coordinates: $e');
      return null;
    }
  }
}
