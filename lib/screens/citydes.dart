import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class CityDescription extends StatefulWidget {
  final String cityName;

  CityDescription(this.cityName);

  @override
  _CityDescriptionState createState() => _CityDescriptionState(cityName);
}

class _CityDescriptionState extends State<CityDescription> {
  final String cityName;
  String? rating; // Nullable string
  late SharedPreferences prefs; // Shared Preferences

  _CityDescriptionState(this.cityName);
  @override
  void initState() {
    super.initState();
    _initSharedPreferences();

    // Initialize SharedPreferences in initState
  }

  // Initialize SharedPreferences
  _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Map to store city descriptions, image paths, and YouTube video URLs
  static final Map<String, String> cityData = {
    'Amazon': 'Description for Amazon',
    'London': 'Hello London, the great city!',
    'USA': 'Description for USA',
    'Egypt': 'Description for Egypt',
    'Nuwaraeliya': 'Description for Nuwaraeliya',
    'Kandy': 'Welcome to Kandy',
  };

  static final Map<String, String> cityImages = {
    'Amazon': 'images/city1.jpg',
    'London': 'images/city2.jpg',
    'USA': 'images/city3.jpg',
    'Egypt': 'images/city4.jpg',
    'Nuwaraeliya': 'images/city5.jpg',
    'Kandy': 'images/city6.jpg',
  };

  static final Map<String, String> cityVideos = {
    'Amazon': 'https://www.youtube.com/watch?v=GgXtU-rpzYM',
    'London': 'https://www.youtube.com/watch?v=KGerjHMa90s',
    'USA': 'https://www.youtube.com/watch?v=hYV8GiZA6i0',
    'Egypt': 'https://www.youtube.com/watch?v=dyBkgncVc6g',
    'Nuwaraeliya': 'https://www.youtube.com/watch?vPuUSGypnmIM',
    'Kandy': 'https://www.youtube.com/watch?v=9s1Kejt3Aj4',
  };

  @override
  Widget build(BuildContext context) {
    String description = cityData[cityName] ?? 'No description available';
    String imagePath = cityImages[cityName] ?? 'images/default.jpg';
    String videoUrl = cityVideos[cityName] ?? '';
    String videoId = videoUrl.split("?v=")[1];

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: Column(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 200,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(description),
          ),
          if (videoUrl.isNotEmpty)
            ElevatedButton(
              onPressed: () => _launchVideoUrl(videoUrl),
              child: Text('View Video'),
            ),
          if (videoUrl.isNotEmpty)
            YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: YoutubePlayerFlags(autoPlay: false),
              ),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
            ),
          // Add a "Give Rating" button
          ElevatedButton(
            onPressed: () => _showRatingDialog(context),
            child: Text('Give Rating'),
          ),
        ],
      ),
    );
  }

  // Function to launch the YouTube video URL
  _launchVideoUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Show a dialog to input and save the rating
  _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Give a Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rate $cityName:'),
              DropdownButton<String?>(
                value: rating,
                onChanged: (value) {
                  // Update the rating when a new value is selected
                  setState(() {
                    rating = value;
                  });
                },
                items: <String?>['1', '2', '3', '4', '5'].map((String? value) {
                  return DropdownMenuItem<String?>(
                    value: value,
                    child: Text(
                        value == null ? 'Select a rating' : '$value stars'),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                if (rating != null) {
                  // Save the rating to local storage
                  await prefs.setString(cityName, rating!);

                  // Check if the app is online and synchronize with Firestore
                  if (await _isOnline()) {
                    _synchronizeRatingsWithFirestore();
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to check if the app is online
  Future<bool> _isOnline() async {
    // You can implement your own logic to check network connectivity
    // For simplicity, I'm assuming the app is online if the user has any network connection.
    return true;
  }

  // Function to synchronize ratings with Firestore
  _synchronizeRatingsWithFirestore() {
    // Retrieve the rating from local storage
    String? userRating = prefs.getString(cityName);
    if (userRating != null) {
      // Save the rating to Firestore
      FirebaseFirestore.instance.collection('ratings').add({
        'cityName': cityName,
        'rating': userRating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove the rating from local storage after synchronization
      prefs.remove(cityName);
    }
  }
}
