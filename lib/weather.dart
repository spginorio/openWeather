class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final String iconCode;
  final double feelsLike;
  final String country;
  final double tempMin;
  final double tempMax;
  final double windSpeed;
  final int timezone;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.iconCode,
    required this.feelsLike,
    required this.country,
    required this.tempMin,
    required this.tempMax,
    required this.windSpeed,
    required this.timezone,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      iconCode: json['weather'][0]['icon'],
      feelsLike: json['main']['feels_like'].toDouble(),
      country: json['sys']['country'],
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      timezone: json['timezone'],
    );
  }
}
