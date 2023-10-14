import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_app/screens/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomeBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      index: 1,
      items: [
        Icon(Icons.person_outline, size: 30),
        // Icon(Icons.favorite_outline, size: 30),
        Icon(Icons.home, size: 30, color: Colors.redAccent),
        // Icon(Icons.location_on_outlined, size: 30),
        // Icon(Icons.list, size: 30),
      ],
      onTap: (index) {
        if (index == 0) {
          // Navigate to the "Person" page with the logout button.
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PersonPage()));
        } else if (index == 1) {
          // Reload the current page, in this case, DefaultPage.
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
        // You can handle other menu items similarly.
      },
    );
  }
}

class PersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logout"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hey user,  Do you really need to logout?"),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance
                    .signOut()
                    .then((value) => "Successfully Log Out");
                Navigator.pushNamed(context, 'login');
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
