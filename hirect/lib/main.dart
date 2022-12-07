import 'package:flutter/material.dart';
import 'package:hirectt/screens/typeSelector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hirect',
        initialRoute: "/",
        routes: {
          "/": (context) => const Scaffold(
                body: TypeSelector(),
              )
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ));
  }
}
