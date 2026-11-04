import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(LudoApp());

class LudoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LudoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LudoScreen extends StatefulWidget {
  @override
  _LudoScreenState createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  int diceValue = 1;

  void rollDice() {
    setState(() {
      diceValue = Random().nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ludo Dice Roller')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Roll your Ludo Dice!', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$diceValue',
                style: TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: rollDice,
              child: Text('Roll Dice', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}