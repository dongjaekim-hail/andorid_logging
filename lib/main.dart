import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart'; // Ensure correct import path
import 'log_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LogProvider(),
      child: MaterialApp(
        title: 'Behavior Logger',
        home: HomeScreen(),
      ),
    );
  }
}
