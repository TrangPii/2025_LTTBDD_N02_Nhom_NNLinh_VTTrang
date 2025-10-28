import 'package:flutter/material.dart';
import 'utils/constants.dart';

void main() {
  runApp(const CardSagaApp());
}

class CardSagaApp extends StatelessWidget {
  const CardSagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Saga',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const Scaffold(body: Center(child: Text('App is loading...'))),
    );
  }
}
