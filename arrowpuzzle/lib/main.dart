import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ArrowPuzzleApp());
}

class ArrowPuzzleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'Arrow Puzzle', theme: ThemeData(useMaterial3: true, primarySwatch: Colors.deepPurple), home: ArrowGame());
  }
}

class ArrowGame extends StatefulWidget { @override _ArrowGameState createState() => _ArrowGameState(); }

class _ArrowGameState extends State<ArrowGame> with TickerProviderStateMixin {
  int level = 1, gridSize = 4, moves = 0, score = 0, combo = 0;
  List<int> arrows = []; // 0=up 1=right 2=down 3=left
  List<bool> exited = [];
  List<double> exitAnim = [];
  bool isWon = false, soundOn = true;
  Random rand = Random();
  final AudioPlayer _player = AudioPlayer();

  // ADS
  BannerAd? _bannerAd; bool _isBannerLoaded = false; InterstitialAd? _interstitialAd;
  final String bannerId = 'ca-app-pub-3940256099942544/6300978111';
  final String interstitialId = 'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() { super.initState(); _newLevel(); _loadBanner(); _loadInterstitial(); }

  // ---- SOUND ----
  Future<void> _playSound(String type) async {
    if (!soundOn) return;
    try {
      if (type == 'tap') {
        SystemSound.play(SystemSoundType.click);
        await _player.play(AssetSource('sounds/tap.mp3'));
      } else if (type == 'exit') {
        await _player.play(AssetSource('sounds/exit.mp3'));
        HapticFeedback.lightImpact();
      } else if (type == 'win') {
        await _player.play(AssetSource('sounds/win.mp3'));
        HapticFeedback.heavyImpact();
      } else if (type == 'rotate') {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _loadBanner() {
    _bannerAd = BannerAd(adUnitId: bannerId, size: AdSize.banner, request: AdRequest(), listener: BannerAdListener(onAdLoaded: (_) => setState(() => _isBannerLoaded = true), onAdFailedToLoad: (ad, err) => ad.dispose()))..load();
  }
  void _loadInterstitial() {
    InterstitialAd.load(adUnitId: interstitialId, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => _interstitialAd = ad, onAdFailedToLoad: (_) => _interstitialAd = null));
  }
  void _showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) { ad.dispose(); _loadInterstitial(); });
      _interstitialAd!.show(); _interstitialAd = null;
    }
  }

  void _newLevel() {
    isWon = false;
    gridSize = 3 + level; if (gridSize > 6) gridSize = 6;
    arrows = List.generate(gridSize * gridSize, (_) => rand.nextInt(4));
    exited = List.filled(arrows.length, false);
    exitAnim = List.filled(arrows.length, 0.0);
    moves = 0; isWon = false; combo = 0;
    setState(() {});
  }

  // Arrow nikalne ka logic - agar arrow border ki taraf point kare to bahar nikal jayega
  bool _canExit(int index) {
    int r = index ~/ gridSize, c = index % gridSize, dir = arrows[index];
    if (dir == 0 && r == 0) return true; // up + top row
    if (dir == 2 && r == gridSize - 1) return true; // down + bottom
    if (dir == 3 && c == 0) return true; // left + left col
    if (dir == 1 && c == gridSize - 1) return true; // right + right col
    // beech wale - agar uske aage wala already nikal gaya to bhi nikal sakta hai
    if (dir == 0) { for (int rr = r - 1; rr >= 0; rr--) if (!exited[rr * gridSize + c]) return false; return true; }
    if (dir == 2) { for (int rr = r + 1; rr < gridSize; rr++) if (!exited[rr * gridSize + c]) return false; return true; }
    if (dir == 3) { for (int cc = c - 1; cc >= 0; cc--) if (!exited[r * gridSize + cc]) return false; return true; }
    if (dir == 1) { for (int cc = c + 1; cc < gridSize; cc++) if (!exited[r * gridSize + cc]) return false; return true; }
    return false;
  }

  void _tap(int index) async {
    if (isWon || exited[index]) return;
    await _playSound('rotate');
    setState(() { arrows[index] = (arrows[index] + 1) % 4; moves++; });

    // check exit after rotate
    await Future.delayed(Duration(milliseconds: 150));
    _checkExits();
  }

  void _checkExits() async {
    if (isWon) return;
    bool anyExit = false;
    for (int i = 0; i < arrows.length; i++) {
      if (!exited[i] && _canExit(i)) {
        anyExit = true;
        setState(() { exited[i] = true; combo++; score += 10 * combo; });
        await _playSound('exit');
        await Future.delayed(Duration(milliseconds: 80));
      }
    }
    if (anyExit) {
      // dobara check karo chain reaction ke liye
      await Future.delayed(Duration(milliseconds: 200));
      _checkExits();
    } else {
      combo = 0;
    }
    if (exited.every((e) => e)) {
      setState(() => isWon = true);
      await _playSound('win');
      score += 100 * level;
      Future.delayed(Duration(milliseconds: 500), _showWin);
    }
    setState(() {});
  }

  void _showWin() {
    _showInterstitial();
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('🎉 Level $level Clear!', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Score: $score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('Moves: $moves'), SizedBox(height: 10), Text('Saare arrows bahar nikal gaye! 🔥')]),
      actions: [Center(child: ElevatedButton(onPressed: () { Navigator.pop(context); setState(() { level++; _newLevel(); }); }, child: Text('NEXT LEVEL →')))],
    ));
  }

  @override
  void dispose() { _bannerAd?.dispose(); _interstitialAd?.dispose(); _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    int remaining = exited.where((e) => !e).length;
    return Scaffold(
      backgroundColor: Color(0xFF130A2E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        title: Text('🏹 ARROW PUZZLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [IconButton(icon: Icon(soundOn ? Icons.volume_up : Icons.volume_off, color: Colors.white), onPressed: () => setState(() => soundOn = !soundOn))],
      ),
      body: Column(children: [
        Container(margin: EdgeInsets.symmetric(horizontal: 16), padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat('LEVEL', '$level'), _stat('SCORE', '$score'), _stat('LEFT', '$remaining'), _stat('MOVES', '$moves')])),
        SizedBox(height: 8),
        Text('Arrow ko tap karke ghumao, border ki taraf karo to wo NIKAL jayega!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
        if (combo > 1) Container(margin: EdgeInsets.only(top: 6), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: Text('🔥 COMBO x$combo!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
        Expanded(child: Center(child: Container(padding: EdgeInsets.all(12), margin: EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Color(0xFF2A1B5A), borderRadius: BorderRadius.circular(20)),
          child: AspectRatio(aspectRatio: 1, child: GridView.builder(physics: NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: arrows.length, itemBuilder: (ctx, i) {
            if (exited[i]) return Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.check, color: Colors.white24));
            bool canExitNow = _canExit(i);
            return GestureDetector(onTap: () => _tap(i), child: AnimatedContainer(duration: Duration(milliseconds: 250), decoration: BoxDecoration(color: canExitNow ? Colors.green : Colors.amber, borderRadius: BorderRadius.circular(12), border: canExitNow ? Border.all(color: Colors.white, width: 2) : null, boxShadow: [BoxShadow(color: (canExitNow ? Colors.green : Colors.amber).withOpacity(0.5), blurRadius: 8)]),
              child: AnimatedRotation(turns: arrows[i] / 4, duration: Duration(milliseconds: 300), child: Icon(Icons.arrow_upward_rounded, size: 36, color: Colors.white))));
          }))))),
        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: _newLevel, icon: Icon(Icons.refresh), label: Text('SHUFFLE'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple))),
          SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(onPressed: () { setState(() { for (int i = 0; i < arrows.length; i++) { int r = i ~/ gridSize, c = i % gridSize; if (r == 0) arrows[i] = 0; else if (r == gridSize - 1) arrows[i] = 2; else if (c == 0) arrows[i] = 3; else arrows[i] = 1; } }); _checkExits(); }, icon: Icon(Icons.lightbulb), label: Text('HINT'), style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white))),
        ])),
        if (_isBannerLoaded && _bannerAd != null) Container(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!))
        else Container(height: 50, alignment: Alignment.center, child: Text('Ad loading...', style: TextStyle(color: Colors.white30, fontSize: 11))),
      ]),
    );
  }
  Widget _stat(String l, String v) => Column(children: [Text(l, style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)), Text(v, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]);
}
