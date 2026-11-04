import os
import subprocess

apps = [
    {
        "name": "1_Arrow_Puzzle",
        "title": "Arrow Puzzle",
        "code": """
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
"""
    },
    {
        "name": "2_Ludo_Game",
        "title": "Ludo Game",
        "code": """
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
"""
    }
]

# 1. ऐप्स और उनके फोल्डर जनरेट करना
for app in apps:
    app_folder = app["name"]
    lib_folder = os.path.join(app_folder, "lib")
    os.makedirs(lib_folder, exist_ok=True)
    
    with open(os.path.join(lib_folder, "main.dart"), "w") as f:
        f.write(app["code"].strip())
        
    pubspec_code = f"""
name: {app["name"].lower()}
description: A flutter app for {app["title"]}
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=2.17.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter

flutter:
  uses-material-design: true
"""
    with open(os.path.join(app_folder, "pubspec.yaml"), "w") as f:
        f.write(pubspec_code.strip())

print("-> ऐप्स और फोल्डर सफलतापर्वक तैयार हो गए हैं। अब GitHub पर ऑटोमैटिक पुश हो रहा है...")

# 2. Git के जरिए अपने आप GitHub पर भेजना
try:
    subprocess.run(["git", "add", "."], check=True)
    subprocess.run(["git", "commit", "-m", "Auto generated Arrow Puzzle and Ludo apps via Python"], check=True)
    subprocess.run(["git", "push", "origin", "main"], check=True)
    print("-> शानदार! सभी ऐप्स सफलतापर्वक GitHub पर ऑटोमैटिक अपलोड हो गए हैं!")
except Exception as e:
    print(f"Git Push में छोटी सी समस्या आई: {e}")

