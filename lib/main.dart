import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'weather.dart';
import 'weather_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

//flutter build apk --split-per-abi
void main() {
  tz.initializeTimeZones(); // Initialize timezone data
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  WeatherAppState createState() => WeatherAppState();
}

bool _isLoading = false;

class WeatherAppState extends State<WeatherApp> {
  LocationPermission? _permission;
  Position? _position;
  Weather? _weather;
  String? _currentTime;

  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

//!------------------------------CHECK PERMISSION________________________
  Future<void> _checkPermission() async {
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
    }

    _getPosition();
  }

//!------------------------------GET POSITION________________________
  Future<void> _getPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _position = position;
        //  print(position);
      });
      _getWeatherByLocation();
    } catch (e) {
      _checkPermission();
    }
  }

  //!------------------------------GET CURRENT TIME________________________
  void _getCurrentTime(int timezoneOffset) {
    try {
      // Convert UTC offset to timezone
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime.now(location);

      // Adjust for the timezone offset
      final localTime = now.add(Duration(seconds: timezoneOffset));

      // Format the time
      _currentTime = DateFormat('HH:mm a').format(localTime);
    } catch (e) {
      _currentTime = 'Time unavailable';
    }
  }

//!------------------------------GET WEATHER BY LOCATION________________________
  Future<void> _getWeatherByLocation() async {
    if (_position == null) {
      return;
    }
    final weather = await WeatherService.getWeatherByLocation(
        latitude: _position!.latitude, longitude: _position!.longitude);
    setState(() {
      _weather = weather;

      _getCurrentTime(weather.timezone);
    });
  }

//!------------------------------GET WEATHER BY CITY NAME________________________
  Future<void> _getWeatherByCityName() async {
    final cityName = _cityController.text;
    try {
      final weather =
          await WeatherService.getWeatherByCityName(cityName: cityName);
      setState(() {
        _weather = weather;
        _getCurrentTime(weather.timezone);
      });
    } catch (e) {
      // Handle error, e.g. show error message to the user
    }
  }

//!------------------------------GET WEATHER ICON________________________
  Widget _getWeatherIcon() {
    if (_weather == null) {
      return SizedBox();
    }
    final iconAsset = _getIconAsset(_weather!.iconCode);
    return Image.asset(iconAsset);
  }

  String _getIconAsset(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'assets/images/01d.png';
      case '01n':
        return 'assets/images/01n.png';
      case '02d':
        return 'assets/images/02d.png';
      case '02n':
        return 'assets/images/02n.png';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return 'assets/images/0304dn.png';
      case '09d':
        return 'assets/images/09d.png';
      case '09n':
        return 'assets/images/09d.png';
      case '10d':
        return 'assets/images/10d.png';
      case '10n':
        return 'assets/images/10n.png';
      case '11d':
      case '11n':
        return 'assets/images/11dn.png';
      case '13d':
      case '13n':
        return 'assets/images/12dn.png';
      case '50d':
      case '50n':
        return 'assets/images/50dn.png';
      default:
        return 'assets/images/na.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,

        //! -----------APP BAR------------

        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 101, 138, 157),
          centerTitle: true,
          title: Text(
            'Open Weather',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          actions: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.pin_drop_outlined,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                _getWeatherByLocation();
              },
            ),
          ],
        ),
        body: _weather == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(
                      flex: 2,
                    ),
                    LoadingAnimationWidget.discreteCircle(
                      color: const Color.fromARGB(255, 77, 177, 228),
                      size: 90,
                      secondRingColor: Colors.teal,
                      thirdRingColor: Colors.orange,
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Text(
                      "Accessing device location...\nPlease enable location access \nif you have not done so.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35),
                      child: CupertinoButton(
                        onPressed: Geolocator.openLocationSettings,
                        child: Text(
                          "Location Settings",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_weather != null)
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(50, 15, 50, 0),
                            child: TextField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(124, 255, 86, 34),
                                  ),
                                ),
                                hintText: 'Enter a city...',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(164, 117, 117, 117)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(223, 25, 166, 166)),
                                ),
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _getWeatherByCityName();
                                      });
                                    }),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 10, 10),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: Color.fromARGB(198, 61, 93, 103),
                                    size: 30,
                                  ),
                                  SizedBox(width: 3),
                                  Center(
                                    child: Text(
                                      _weather!.cityName,
                                      style: TextStyle(
                                          fontSize: 34.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 81, 141, 171)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _weather!.country,
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 101, 138, 157)),
                                ),
                                SizedBox(width: 20),
                                if (_currentTime != null)
                                  Text(
                                    _currentTime!,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 101, 138, 157),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          //! Temperature, Description, Icon
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          '${_weather!.temperature.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontSize: 36.0,
                                            fontWeight: FontWeight.bold,
                                            color: _weather!.temperature < 17
                                                ? Color.fromARGB(
                                                    255, 34, 175, 240)
                                                : (_weather!.temperature >=
                                                            17 &&
                                                        _weather!.temperature <
                                                            25
                                                    ? Color.fromARGB(
                                                        255, 94, 173, 21)
                                                    : Color.fromARGB(
                                                        255, 217, 154, 77)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _weather!.description.toUpperCase(),
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Color.fromARGB(
                                                    255, 0, 108, 110)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: 150,
                                    width: 140,
                                    child: _getWeatherIcon()),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //! -----------------Min Temp----------------------
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Min: ${_weather!.tempMin.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              wordSpacing: 1,
                                              fontSize: 20.0,
                                              color: Color.fromARGB(
                                                  255, 0, 117, 119)),
                                        ),
                                      ),
                                    ),

                                    //Max Temp----------------------------
                                    SizedBox(),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Max: ${_weather!.tempMax.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Color.fromARGB(
                                                  255, 0, 117, 119)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Feels Like Temp-----------------------
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        ' Feels like:  ${_weather!.feelsLike.toStringAsFixed(0)}°C',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Color.fromARGB(
                                                255, 0, 117, 119))),
                                  ),
                                ),

                                SizedBox(
                                  width: 30,
                                ),

                                //Humidity-----------------------------
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Humidity:  ${_weather!.humidity}%',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color:
                                              Color.fromARGB(255, 0, 117, 119)),
                                    ),
                                  ),
                                ),

                                //Wind Speed-----------------------------
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Wind Speed:  ${(_weather!.windSpeed * 3.6).toStringAsFixed(1)} k/h',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Color.fromARGB(
                                                255, 0, 117, 119)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
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
