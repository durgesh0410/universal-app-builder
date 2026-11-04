import os
import shutil

apps = [
    {
        "name": "ArrowPuzzle",
        "title": "Arrow Puzzle",
        "type": "arrow"
    },
    {
        "name": "LudoGame",
        "title": "Ludo King Clone",
        "type": "ludo"
    }
]

def generate_apps():
    for app in apps:
        app_name = app["name"]
        app_title = app["title"]
        app_type = app["type"]
        
        print(f"Cleaning and generating fresh app for: {app_title}")
        
        if os.path.exists(app_name):
            shutil.rmtree(app_name)
            
        lib_path = os.path.join(app_name, "lib")
        os.makedirs(lib_path, exist_ok=True)
        
        manifest_dir = os.path.join(app_name, "android", "app", "src", "main")
        os.makedirs(manifest_dir, exist_ok=True)
        
        manifest_path = os.path.join(manifest_dir, "AndroidManifest.xml")
        manifest_code = f"""<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.{app_name.lower()}">
    <application
        android:label="{app_title}"
        android:name="${{applicationName}}"
        android:icon="@mipmap/ic_launcher">
        
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
"""
        with open(manifest_path, "w") as f:
            f.write(manifest_code)

        kotlin_dir = os.path.join(app_name, "android", "app", "src", "main", "kotlin", "com", "example", app_name.lower())
        os.makedirs(kotlin_dir, exist_ok=True)
        
        main_activity_path = os.path.join(kotlin_dir, "MainActivity.kt")
        main_activity_code = f"""package com.example.{app_name.lower()}

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {{
}}
"""
        with open(main_activity_path, "w") as f:
            f.write(main_activity_code)

        if app_type == "arrow":
            main_code = """import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const ArrowPuzzleApp());
}

class ArrowPuzzleApp extends StatelessWidget {
  const ArrowPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arrow Puzzle AdMob',
      theme: ThemeData.dark(),
      home: const ArrowGameScreen(),
    );
  }
}

class ArrowGameScreen extends StatefulWidget {
  const ArrowGameScreen({super.key});

  @override
  State<ArrowGameScreen> createState() => _ArrowGameScreenState();
}

class _ArrowGameScreenState extends State<ArrowGameScreen> {
  double _rotationAngle = 0.0;
  int _score = 0;
  int _level = 1;
  int _lives = 5;
  bool _isGameOver = false;
  final Random _rand = Random();
  late double _targetAngle;

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _setNewTarget();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  void _setNewTarget() {
    _targetAngle = _rand.nextDouble() * 2 * pi;
  }

  void _fireArrow() {
    if (_isGameOver) return;
    setState(() {
      _rotationAngle += pi / 3;
      double diff = (_rotationAngle - _targetAngle).abs() % (2 * pi);
      if (diff < 0.4 || diff > (2 * pi - 0.4)) {
        _score += 50 * _level;
        if (_score >= _level * 200) {
          _level++;
          _showInterstitialAd();
        }
        _setNewTarget();
      } else {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _showInterstitialAd();
        }
      }
    });
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _lives = 5;
      _isGameOver = false;
      _rotationAngle = 0.0;
      _setNewTarget();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arrow Puzzle - Level $_level'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: $_score', style: const TextStyle(fontSize: 20, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  Text('Lives: ' + '❤️ ' * _lives, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: _isGameOver
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('GAME OVER', style: TextStyle(fontSize: 32, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _restartGame,
                            child: const Text('Play Again'),
                          ),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _targetAngle,
                            child: const Icon(Icons.gps_fixed, size: 120, color: Colors.orangeAccent),
                          ),
                          Transform.rotate(
                            angle: _rotationAngle,
                            child: const Icon(Icons.navigation, size: 100, color: Colors.cyanAccent),
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.pinkAccent,
                ),
                onPressed: _isGameOver ? null : _fireArrow,
                child: const Text('SHOOT ARROW', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            if (_isBannerLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
"""
        else:
            main_code = """import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const LudoMasterApp());
}

class LudoMasterApp extends StatelessWidget {
  const LudoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ludo King Master AdMob',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LudoMasterScreen(),
    );
  }
}

class LudoMasterScreen extends StatefulWidget {
  const LudoMasterScreen({super.key});

  @override
  State<LudoMasterScreen> createState() => _LudoMasterScreenState();
}

class _LudoMasterScreenState extends State<LudoMasterScreen> {
  int _diceVal = 6;
  bool _rolling = false;
  int _redPosition = 0;
  int _greenPosition = 0;
  bool _isRedTurn = true;
  final Random _rnd = Random();

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;
  int _rollCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  void _rollDice() {
    if (_rolling) return;
    setState(() {
      _rolling = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _rolling = false;
        int val = _rnd.nextInt(6) + 1;
        _diceVal = val;
        
        if (_isRedTurn) {
          _redPosition = (_redPosition + val) % 52;
          if (val != 6) _isRedTurn = false;
        } else {
          _greenPosition = (_greenPosition + val) % 52;
          if (val != 6) _isRedTurn = true;
        }

        _rollCount++;
        if (_rollCount >= 4) {
          _rollCount = 0;
          _showInterstitialAd();
        }
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Master Clone'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        color: Colors.green[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRedTurn ? "Red Player's Turn" : "Green Player's Turn",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _isRedTurn ? Colors.red : Colors.green[800]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Red Token', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$_redPosition', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Green Token', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: Text('$_greenPosition', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade700, width: 4),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 10)],
              ),
              child: Text(
                _rolling ? '...' : '$_diceVal',
                style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.green[900]),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _rolling ? null : _rollDice,
              icon: const Icon(Icons.casino, color: Colors.white),
              label: const Text('ROLL DICE', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const Spacer(),
            if (_isBannerLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
"""

        with open(os.path.join(lib_path, "main.dart"), "w") as f:
            f.write(main_code)
            
        pubspec_path = os.path.join(app_name, "pubspec.yaml")
        pubspec_code = f"""name: {app_name.lower()}
description: Apps with AdMob integration.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_mobile_ads: ^5.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
"""
        with open(pubspec_path, "w") as f:
            f.write(pubspec_code)

if __name__ == "__main__":
    generate_apps()
    print("Fresh apps with clean directories and v2 embedding generated!")
