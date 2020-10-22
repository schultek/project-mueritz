import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jufa/service/DynamicLinkService.dart';

import 'pages/Home.dart';
import 'pages/SignIn.dart';
import 'service/AppService.dart';
import 'service/AuthService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Jufa',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
          future: AppService.initApp(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder<User>(
                stream: AuthService.getUserStream(),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  print(snapshot.connectionState);
                  print(snapshot.data);
                  if (snapshot.data != null) {
                    return Home();
                  } else {
                    return SignIn();
                  }
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
