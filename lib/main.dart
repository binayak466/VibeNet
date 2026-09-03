import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorSchemeSeed: const Color(0xFF075E54),
        useMaterial3: true,
      ),
      home: const FirebaseInitWrapper(),
    );
  }
}

class FirebaseInitWrapper extends StatefulWidget {
  const FirebaseInitWrapper({super.key});

  @override
  State<FirebaseInitWrapper> createState() => _FirebaseInitWrapperState();
}

class _FirebaseInitWrapperState extends State<FirebaseInitWrapper> {
  late final Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCj7GM2yfp_16tgFpZqaxGU4InlcUgKFA4',
        appId: '1:328420807383:android:49db8e29dc03664c64d692',
        messagingSenderId: '328420807383',
        projectId: 'vibenet-chat',
        storageBucket: 'vibenet-chat.firebasestorage.app',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Initialization Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            return ChatListScreen(myPhone: currentUser.phoneNumber ?? '+91 User');
          }
          return const WelcomeTermsScreen();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF075E54)),
          ),
        );
      },
    );
  }
}

// --- WhatsApp স্টাইল Terms & Conditions স্ক্রিন ---
class WelcomeTermsScreen extends StatelessWidget {
  const WelcomeTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Welcome to VibeNet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF075E54).withOpacity(0.08),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 110,
                      color: Color(0xFF25D366),
                    ),
                  ),
                  const SizedBox(height: 36),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                      children: [
                        TextSpan(text: 'Read our '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: Color(0xFF027EB5), fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: '. Tap "Agree and continue" to accept the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: Color(0xFF027EB5), fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 1,
                    ),
                    child: const Text(
                      'AGREE AND CONTINUE',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'from\nGoogle / VibeNet Team',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WhatsApp স্টাইল কান্ট্রি সিলেক্ট ও ফোন নম্বর স্ক্রিন ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _isOtpSent = false;
  String _fullPhoneNumber = '';

  final List<Map<String, String>> _countries = [
    {'name': 'India', 'code': '+91'},
    {'name': 'Bangladesh', 'code': '+880'},
    {'name': 'United States', 'code': '+1'},
    {'name': 'United Kingdom', 'code': '+44'},
    {'name': 'United Arab Emirates', 'code': '+971'},
    {'name': 'Saudi Arabia', 'code': '+966'},
    {'name': 'Nepal', 'code': '+977'},
  ];

  late String _selectedCountry;
  late String _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0]['name']!;
    _selectedCountryCode = _countries[0]['code']!;
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক মোবাইল নম্বর দিন')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _fullPhoneNumber = '$_selectedCountryCode $phone';
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP পাঠানো হয়েছে! টেস্ট কোড: 123456')),
        );
      }
    });
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল OTP! সঠিক কোডটি দিন: 123456')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListScreen(myPhone: _fullPhoneNumber),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListScreen(myPhone: _fullPhoneNumber),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Enter your phone number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF075E54),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Text(
              'VibeNet will need to verify your phone number.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 28),

            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF075E54)),
                onChanged: _isOtpSent
                    ? null
                    : (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCountry = newValue;
                            _selectedCountryCode = _countries.firstWhere((c) => c['name'] == newValue)['code']!;
                          });
                        }
                      },
                items: _countries.map<DropdownMenuItem<String>>((Map<String, String> country) {
                  return DropdownMenuItem<String>(
                    value: country['name'],
                    child: Center(
                      child: Text(
                        country['name']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(height: 1, color: const Color(0xFF075E54)),

            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF075E54), width: 1.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedCountryCode,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isOtpSent,
                    decoration: const InputDecoration(
                      hintText: 'phone number',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF075E54), width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF075E54), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            if (_isOtpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-digit Code (123456)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Next / Verify', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
    {'name': 'Rahul Sharma', 'phone': '+919876543210', 'status': 'Hey there! Using VibeNet.'},
    {'name': 'Priya Das', 'phone': '+919123456780', 'status': 'Available'},
    {'name': 'Amit Roy', 'phone': '+919988776655', 'status': 'Busy at work'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeNet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeTermsScreen()),
                );
              }
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
              backgroundColor: const Color(0xFF128C7E),
              foregroundColor: Colors.white,
              child: Text(person['name']![0]),
            ),
            title: Text(person['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(person['status']!),
            trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF075E54)),
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

// --- মেসেজিং স্ক্রিন ---
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
        backgroundColor: const Color(0xFF075E54),
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
                          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                        ),
                        child: Text(
                          data['text'] ?? '',
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
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
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF075E54)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
