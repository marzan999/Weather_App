import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;

  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position!.latitude;
      longatude = position!.longitude;
    });
    fetchWeatherData();
  }

  var latitude;
  var longatude;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  fetchWeatherData() async {
    String weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longatude&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR0BccOYK9qFjmf2TTdAfo5BQLiFTf6wajC9R51BoXnLgMltJJKN-q4zhuk';
    String forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longatude&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR0BccOYK9qFjmf2TTdAfo5BQLiFTf6wajC9R51BoXnLgMltJJKN-q4zhuk';

    var weatherResponse = await http.get(Uri.parse(weatherUrl));
    var forecastResponse = await http.get(Uri.parse(forecastUrl));

    weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
    forecastMap = Map<String, dynamic>.from(jsonDecode(forecastResponse.body));

    setState(() {});

    //print('qqqqqqqqqqqqqqqqqq ${weatherMap!['base']}');
    // print('qqqqqqqqqqqqqqqqqq ${latitude}, ${longatude}');
  }

  @override
  void initState() {
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 137, 169, 196),
              Color.fromARGB(255, 173, 165, 94),
              Color.fromARGB(255, 179, 109, 104),
            ],
          )),
          child: Container(
            padding: EdgeInsets.all(25),
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${Jiffy(DateTime.now()).format(
                      'MMM do yyy, h:mm a',
                    )}',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 65,
                ),
                // Text('${weatherMap!['name]}')
                Text(
                  '${weatherMap!['name']}',
                  style: GoogleFonts.roboto(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 10, color: Color.fromARGB(255, 179, 109, 104)),
                    borderRadius: BorderRadius.circular(150),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        '${weatherMap!['weather'][0]['description']}',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${weatherMap!['main']['temp']}°',
                        style: GoogleFonts.roboto(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 75, 62, 62)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Feels like ${weatherMap!['main']['feels_like']}°',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),

                SizedBox(
                  height: 230,
                  child: ListView.builder(
                      itemCount: forecastMap!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          width: 120,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 27,
                              ),
                              Text(
                                '${Jiffy(forecastMap!['list'][index]['dt_txt']).format('EEE h:mm')}',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              Image.network(
                                  'https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png'),
                              Text(
                                '${forecastMap!['list'][index]['main']['temp_min']} / ${forecastMap!['list'][index]['main']['temp_max']}',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                              Text(
                                '${forecastMap!['list'][index]['weather'][0]['description']} ',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 173, 168, 118),
                              borderRadius: BorderRadius.circular(80)),
                        );
                      }),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Humidity ${weatherMap!['main']['humidity']} & Pressure ${weatherMap!['main']['pressure']}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)).format('h:mm a')} & Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)).format('h:mm a')}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
