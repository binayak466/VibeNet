import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const VibeNetApp());
}

class VibeNetApp extends StatelessWidget {
  const VibeNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- লগইন ও ওটিপি স্ক্রিন ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  final String _demoOtp = "1234"; // ডেমো ওটিপি টেস্ট করার জন্য

  void _sendOtp() {
    if (_phoneController.text.trim().length >= 10) {
      setState(() {
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP পাঠানো হয়েছে! (টেস্ট OTP: 1234)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক ১০ সংখ্যার মোবাইল নম্বর দিন')),
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text.trim() == _demoOtp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatListScreen(myPhone: _phoneController.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল OTP! দয়া করে 1234 লিখুন')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeNet Login', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.forum_rounded, size: 80, color: Color(0xFF6750A4)),
            const SizedBox(height: 16),
            const Text(
              'Welcome to VibeNet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_isOtpSent,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            if (_isOtpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP (1234)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Verify & Enter Chat', style: TextStyle(fontSize: 16)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Send OTP', style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- কন্টাক্ট / চ্যাট লিস্ট স্ক্রিন ---
class ChatListScreen extends StatefulWidget {
  final String myPhone;
  const ChatListScreen({super.key, required this.myPhone});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, String>> contacts = [
    {'name': 'Rahul Sharma', 'phone': '9876543210', 'status': 'Hey there! Using VibeNet.'},
    {'name': 'Priya Das', 'phone': '9123456780', 'status': 'Available'},
    {'name': 'Amit Roy', 'phone': '9988776655', 'status': 'Busy at work'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeNet Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: ListView.separated(
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final person = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              child: Text(person['name']![0]),
            ),
            title: Text(person['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(person['status']!),
            trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF6750A4)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    myPhone: widget.myPhone,
                    receiverName: person['name']!,
                    receiverPhone: person['phone']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- মেসেজিং / কথোপকথন স্ক্রিন ---
class ConversationScreen extends StatefulWidget {
  final String myPhone;
  final String receiverName;
  final String receiverPhone;

  const ConversationScreen({
    super.key,
    required this.myPhone,
    required this.receiverName,
    required this.receiverPhone,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    await _firestore.collection('chats').add({
      'sender': widget.myPhone,
      'receiver': widget.receiverPhone,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.receiverPhone, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['sender'] == widget.myPhone;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF6750A4) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          data['text'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
