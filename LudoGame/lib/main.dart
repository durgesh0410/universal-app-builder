import 'package:flutter/material.dart';
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
