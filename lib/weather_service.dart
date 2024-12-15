import 'weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Weather> getWeatherByLocation(
      {required double latitude, required double longitude}) async {
    final url =
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);

    //print(response.body);
    return Weather.fromJson(json);
  }

  static Future<Weather> getWeatherByCityName(
      {required String cityName}) async {
    final url = '$_baseUrl/weather?q=$cityName&units=metric&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    //print(response.body);
    return Weather.fromJson(json);
  }
}
