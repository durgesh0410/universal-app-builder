import 'package:flutter/material.dart';

void main() => runApp(ArrowPuzzleApp());

class ArrowPuzzleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ArrowScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ArrowScreen extends StatefulWidget {
  @override
  _ArrowScreenState createState() => _ArrowScreenState();
}

class _ArrowScreenState extends State<ArrowScreen> {
  String message = 'Tap the correct arrow direction!';
  
  void checkDirection(String dir) {
    setState(() {
      message = 'Great! Direction $dir selected.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Arrow Puzzle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            IconButton(
              icon: Icon(Icons.arrow_upward, size: 56, color: Colors.blue),
              onPressed: () => checkDirection('Up'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 56, color: Colors.red),
                  onPressed: () => checkDirection('Left'),
                ),
                SizedBox(width: 60),
                IconButton(
                  icon: Icon(Icons.arrow_forward, size: 56, color: Colors.green),
                  onPressed: () => checkDirection('Right'),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward, size: 56, color: Colors.orange),
              onPressed: () => checkDirection('Down'),
            ),
          ],
        ),
      ),
    );
  }
}