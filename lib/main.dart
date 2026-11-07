import 'package:flutter/material.dart';

void main() {
  runApp(const ColonyFixApp());
}

class ColonyFixApp extends StatelessWidget {
  const ColonyFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colony Fix - Plumber & Worker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String myRole = "Plumber / Worker"; // Aap yahan worker ya customer switch kar sakte hain

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colony Fix - सर्विस और मेंटेनेंस'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'स्वागत है दुर्गेश जी!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('आप क्या देखना चाहते हैं?'),
            const SizedBox(height: 20),
            
            // Customer View Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerScreen()));
              },
              icon: const Icon(Icons.person),
              label: const Text('मैं ग्राहक हूँ (काम बुक करना है)', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            
            // Worker/Plumber View Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerScreen()));
              },
              icon: const Icon(Icons.handyman),
              label: const Text('मैं प्लंबर/वर्कर हूँ (रेट भेजना है)', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Customer Screen: Photo & Request
class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ग्राहक - काम बुक करें')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'मकान नंबर / समस्या (जैसे: नल लीक हो रहा है)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('खराब नल की फोटो अपलोड हो गई!')));
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('फोटो खींचकर अपलोड करें'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('रिकॉर्ड दर्ज हो गया!'),
                    content: const Text('आपकी रिक्वेस्ट सभी प्लंबर के पास भेज दी गई है। वे अपना लेबर चार्ज भेज रहे हैं।'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ठीक है'))],
                  ),
                );
              },
              child: const Text('प्लंबर को रिक्वेस्ट भेजें'),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Worker Screen: Bidding Price & Payment/OTP Verification
class WorkerScreen extends StatefulWidget {
  const WorkerScreen({super.key});

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  final _priceController = TextEditingController();
  final _otpController = TextEditingController();
  bool jobAccepted = false;
  bool jobCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('प्लंबर डैशबोर्ड (लेबर चार्ज और पेमेंट)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('उपलब्ध काम (Colony House #102):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('समस्या: बाथरूम का नल बदलना है (सामान ग्राहक का है)'),
              const Divider(height: 30),
              
              if (!jobAccepted) ...[
                const Text('अपना लेबर चार्ज (बोली) दर्ज करें:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'सिर्फ काम का दाम (₹ जैसे 300)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (_priceController.text.isEmpty) return;
                    setState(() {
                      jobAccepted = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('आपका रेट ग्राहक को भेज दिया गया है!')));
                  },
                  child: const Text('ग्राहक को रेट भेजें'),
                ),
              ] else if (!jobCompleted) ...[
                const Card(
                  color: Colors.yellowAccent,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('काम बुक हो गया है! घर जाकर काम पूरा करें। सामान ग्राहक देगा, आपको सिर्फ लेबर लेना है।'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('काम पूरा होने के बाद कस्टमर से पेमेंट और OTP लें:'),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'कस्टमर के मोबाइल पर आया 4-अंकों का OTP डालें', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                
                // Payment Mode Selection info
                const Text('भुगतान का तरीका (Payment Mode):', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ChoiceChip(label: const Text('नकद (Cash)'), selected: true, onSelected: (val){}),
                    const SizedBox(width: 10),
                    ChoiceChip(label: const Text('ऑनलाइन (UPI / QR)'), selected: false, onSelected: (val){}),
                  ],
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (_otpController.text.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही OTP दर्ज करें!')));
                      return;
                    }
                    setState(() {
                      jobCompleted = true;
                    });
                  },
                  child: const Text('OTP वेरिफ़ाई करें और काम बंद करें'),
                ),
              ] else ...[
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 80),
                      SizedBox(height: 16),
                      Text('काम सफलताપूर्वक पूरा हुआ!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('कमिशन (Platform Fee) आपके वॉलेट से कट गया है।'),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

