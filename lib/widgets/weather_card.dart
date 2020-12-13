import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/providers/location_provider.dart';
import 'package:weather_app/screens/details_screen.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../utility.dart';

class WeatherCard extends StatelessWidget {
  final LocationModel location;

  const WeatherCard({
    Key key,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    // These are used for getting the proper time and updating it.
    DateTime current = DateTime.now();
    final Stream timer = Stream.periodic(
        const Duration(seconds: 1), (i) => current = current.add(const Duration(seconds: 1)));

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => DetailsScreen(
                  location: location,
                )));
      },
      onLongPress: () {
        Alert(
          style: const AlertStyle(backgroundColor: Colors.blueGrey),
          context: context,
          type: AlertType.warning,
          title: "Do you want to remove this location from your liked locations?",
          // desc: "Flutter is more awesome with RFlutter Alert.",
          buttons: [
            DialogButton(
              onPressed: () {
                locationProvider.removeLocation(location.name);
                Navigator.pop(context);
              },
              color: Colors.lightGreen[100],
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            DialogButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.redAccent[200],
              child: const Text(
                "Remove",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ).show();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
              child: CachedNetworkImage(
                imageUrl: 'https://i.ibb.co/df35Y8Q/2.png',
                height: getHeight(context) * 0.35,
                width: getWidth(context) * 0.425,
                fit: BoxFit.cover,
                // placeholder: (context, url) => const Center(
                //   child: CircularProgressIndicator(),
                // ),
                fadeInDuration: const Duration(seconds: 1),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {},
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: timer,
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    // COULD ADD 'hh:mm:ss' into DateFormat's constructor
                    // COULD HAVE JUST ADDED .add_jm() instead of doing 'hh:mm:ss a'
                    return Text(DateFormat('hh:mm: a').format(DateTime.fromMillisecondsSinceEpoch(
                        current.millisecondsSinceEpoch + location.timezone)));
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  '${location.temperature.round()}°F',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                Icon(
                  getIcon(location.weather),
                  color: Colors.white,
                  size: 50,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime> getCurrentTime() async {
    DateTime currentTime = DateTime.now();
    NTP.getNtpOffset().then((value) => currentTime.add(Duration(milliseconds: value)));
    return currentTime;
  }

  // https://openweathermap.org/weather-conditions
  // Converts ['weather']['main'] into an IconData to be displayed
  IconData getIcon(String weather) {
    switch (weather) {
      case 'Thunderstorm':
        return WeatherIcons.thunderstorm;
      case 'Drizzle':
        return WeatherIcons.sprinkle;
      case 'Rain':
        return WeatherIcons.rain;
      case 'Snow':
        return WeatherIcons.snow;
      case 'Atmosphere':
        return WeatherIcons.fog;
      case 'Clear':
        return WeatherIcons.day_sunny;
      case 'Clouds':
        return WeatherIcons.cloud;
      default:
        return WeatherIcons.cloud;
    }
  }
}
