import 'package:flutter/material.dart';
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
