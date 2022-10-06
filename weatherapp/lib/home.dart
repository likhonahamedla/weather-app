import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
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
    fetchdata();
  }

  fetchdata() async {
    var weatherapi =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=c05bc98192aa48b04f9710b62b4777f3';
    var forecastapi =
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=c05bc98192aa48b04f9710b62b4777f3';
    var weatherResponse = await http.get(Uri.parse(weatherapi));
    var forecastResponse = await http.get(Uri.parse(forecastapi));

    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (weatherMap == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      var celsious = weatherMap!["main"]["temp"] - 273.15;

      var feal_celsious = weatherMap!["main"]["feels_like"] - 273.15;
      var temp_min_celsious = weatherMap!["main"]["temp_min"] - 273.15;
      var temp_max_celsious = weatherMap!["main"]["temp_max"] - 273.15;
      return SafeArea(
          child: Scaffold(
        body: weatherMap == null
            ? SizedBox(child: CircularProgressIndicator())
            : Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 238, 196, 142),
                  Color.fromARGB(255, 253, 142, 44)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.search_rounded),
                              Text(
                                "Weather",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0XFF313341)),
                              ),
                              Icon(Icons.menu_sharp)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${weatherMap!["name"]}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 20, 20, 20),
                          ),
                        ),
                        Text(
                          "${Jiffy(DateTime.now()).format('EEEE,dd MMM , h:mm a')}",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 19, 18, 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 5, bottom: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Image.network(
                                  'https://openweathermap.org/img/wn/${weatherMap!['weather'][0]['icon']}@2x.png'),
                              SizedBox(
                                width: 30,
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${celsious.toStringAsFixed(1)}°C',
                                    style: TextStyle(
                                        fontSize: 43,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromARGB(255, 19, 18, 18)),
                                  ),
                                  Text(
                                    "${weatherMap!['weather'][0]['main']}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 19, 18, 18)),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 80, right: 80, bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                padding: EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            'https://cdn3d.iconscout.com/3d/premium/thumb/sunrise-5294229-4431754.png')),
                                    // color: Color.fromARGB(255, 240, 198, 135),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sunrise',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)).format('h:mm a')}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                height: 100,
                                width: 100,
                                padding: EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            'https://png.pngtree.com/png-clipart/20220124/ourmid/pngtree-cartoon-red-sun-png-download-png-image_4273260.png')),
                                    // color: Color.fromARGB(255, 240, 198, 135),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sunset',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)).format('h:mm a')}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 380,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 240, 198, 135),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                    'https://e7.pngegg.com/pngimages/139/44/png-clipart-thermometer-temperature-thermometer-computer-icons-temperature-s-text-material.png'),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Temperature',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 19, 18, 18)),
                              ),
                              SizedBox(
                                width: 130,
                              ),
                              Text(
                                '${feal_celsious.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 19, 18, 18)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 55,
                          width: 380,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 240, 198, 135),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                    'https://toppng.com/uploads/preview/computer-icons-weather-wind-rain-windy-weather-icon-11553394233bil1pfsjcf.png'),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Wind',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 19, 18, 18)),
                              ),
                              SizedBox(
                                width: 160,
                              ),
                              Text(
                                '${weatherMap!['wind']['speed']} KM/H',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 19, 18, 18)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 55,
                          width: 380,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 240, 198, 135),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                    'https://www.clipartmax.com/png/middle/237-2372103_humidity-free-icon-humidity.png'),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Humidity',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 19, 18, 18)),
                              ),
                              SizedBox(
                                width: 160,
                              ),
                              Text(
                                '${weatherMap!['main']['humidity']}',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 19, 18, 18)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text("Forecast",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold))),
                    ),
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: forecastMap!.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 40,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                height: 30,
                                width: 90,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 240, 198, 135),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Text(
                                          "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE, h:mm a")}"),
                                      Image.network(
                                          'https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png'),
                                      Text(
                                          "${forecastMap!['list'][index]['weather'][0]['main']}"),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
      ));
    }
    ;
  }
}
