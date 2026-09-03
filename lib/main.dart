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
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF1E88E5),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
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
        if (snapshot.connectionState == ConnectionState.done) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && user.phoneNumber != null) {
            return MainDashboardScreen(myPhone: user.phoneNumber!);
          }
          return const WelcomeTermsScreen();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
        );
      },
    );
  }
}

// --- ১. Terms & Conditions Screen ---
class WelcomeTermsScreen extends StatelessWidget {
  const WelcomeTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Welcome to VibeNet',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
              ),
              Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1E88E5).withOpacity(0.2), const Color(0xFF42A5F5).withOpacity(0.1)],
                      ),
                    ),
                    child: const Icon(Icons.forum_rounded, size: 90, color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Simple. Secure. Reliable messaging and social feed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('AGREE AND CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  const Text('from VibeNet Team', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ২. Country Picker & Login Screen ---
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
  String _selectedCountryCode = '+91';

  void _sendOtp() {
    if (_phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক ১০ সংখ্যার মোবাইল নম্বর দিন')));
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP পাঠানো হয়েছে! কোড দিন: 123456')));
    });
  }

  void _verifyOtp() async {
    if (_otpController.text.trim() != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ভুল কোড! সঠিক কোডটি হলো: 123456')));
      return;
    }
    setState(() => _isLoading = true);
    final fullNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      await FirebaseFirestore.instance.collection('users').doc(fullNumber).set({
        'phone': fullNumber,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainDashboardScreen(myPhone: fullNumber)),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainDashboardScreen(myPhone: fullNumber)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Enter phone number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_selectedCountryCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isOtpSent,
                    decoration: InputDecoration(
                      hintText: 'Mobile number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isOtpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter OTP (123456)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Verify & Enter', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- ৩. হুবহু স্ক্রিনশটের মতো ড্যাশবোর্ড স্ক্রিন ---
class MainDashboardScreen extends StatefulWidget {
  final String myPhone;
  const MainDashboardScreen({super.key, required this.myPhone});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  void _openNewChatDialog() {
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Chat'),
        content: TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Receiver phone number', prefixText: '+91 '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final target = phoneCtrl.text.trim();
              if (target.isNotEmpty) {
                Navigator.pop(ctx);
                final finalNumber = target.startsWith('+') ? target : '+91$target';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => ConversationScreen(myPhone: widget.myPhone, receiverPhone: finalNumber),
                  ),
                );
              }
            },
            child: const Text('Start'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar & Weather Widget (হুবহু নীল গ্র্যাডিয়েন্ট কার্ড)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1976D2).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Top App Header
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'VibeNet',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Live Weather Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wb_sunny_rounded, color: Colors.amberAccent, size: 38),
                          SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('28°C', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text('Kolkata', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                          Spacer(),
                          Icon(Icons.location_on, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Status / Stories Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildStoryItem('Rahul', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', true),
                      _buildStoryItem('Priya', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', true),
                      _buildStoryItem('Anita', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', true),
                      _buildStoryItem('Vikram', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', false),
                      _buildStoryItem('Sourav', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 3. CHATS Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CHATS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1)),
                    InkWell(
                      onTap: _openNewChatDialog,
                      child: const Icon(Icons.add_circle, color: Color(0xFF1E88E5), size: 24),
                    ),
                  ],
                ),
              ),

              // Firebase Live Chat History
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chats').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  final Set<String> partners = {};
                  final Map<String, String> lastMsgs = {};
                  if (snapshot.hasData) {
                    for (var d in snapshot.data!.docs) {
                      final data = d.data() as Map<String, dynamic>;
                      final s = data['sender'] as String?;
                      final r = data['receiver'] as String?;
                      final txt = data['text'] as String? ?? '';
                      if (s == widget.myPhone && r != null) {
                        partners.add(r);
                        lastMsgs.putIfAbsent(r, () => txt);
                      } else if (r == widget.myPhone && s != null) {
                        partners.add(s);
                        lastMsgs.putIfAbsent(s, () => txt);
                      }
                    }
                  }

                  final list = partners.toList();

                  return Column(
                    children: [
                      // প্রি-বিল্ট কুইক চ্যাট আইটেম (স্ক্রিনশটের মতো)
                      _buildChatTile('Rahul Sen', lastMsgs['+919876543210'] ?? 'Meeting today at 4pm?', '3:30pm', 1, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', '+919876543210'),
                      _buildChatTile('Priya Das', lastMsgs['+919123456780'] ?? 'Check the photo I sent!', '3:15pm', 0, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', '+919123456780'),
                      _buildChatTile('Group Chat (Trip)', 'Trip Planning 🏔️', '3:01pm', 5, null, '+910000000000', isGroup: true),

                      // ডায়নামিক চ্যাট যদি অন্য কোনো নম্বরে হয়ে থাকে
                      ...list.where((p) => p != '+919876543210' && p != '+919123456780').map((phone) {
                        return _buildChatTile(phone, lastMsgs[phone] ?? 'Tap to chat', 'Just now', 0, null, phone);
                      }),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // 4. NEWS FEED & REELS Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('NEWS FEED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1)),
                    Text('REELS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade700, letterSpacing: 1)),
                  ],
                ),
              ),

              // Feed and Reel Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feed Card
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100'),
                                ),
                                SizedBox(width: 8),
                                Text('Anita Roy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Image.network(
                                    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Traveling! 🌲', style: TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text('150', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                SizedBox(width: 12),
                                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text('12', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Reels Card
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 198,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.white, size: 14),
                                    SizedBox(width: 2),
                                    Text('2.1k', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // 5. Bottom Navigation Bar (হুবহু ৫টি আইকন সহ)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.feed_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 28), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Profile / Pay'),
        ],
      ),
    );
  }

  // স্টোরি সার্কেল উইজেট
  Widget _buildStoryItem(String name, String imgUrl, bool isOnline) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E88E5), width: 2),
                ),
                child: CircleAvatar(radius: 26, backgroundImage: NetworkImage(imgUrl)),
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // চ্যাট আইটেম উইজেট
  Widget _buildChatTile(String title, String subtitle, String time, int unread, String? avatarUrl, String phone, {bool isGroup = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => ConversationScreen(myPhone: widget.myPhone, receiverPhone: phone),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: isGroup ? const Color(0xFFE3F2FD) : Colors.grey.shade200,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? Icon(isGroup ? Icons.groups : Icons.person, color: const Color(0xFF1E88E5)) : null,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(10)),
                child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

// --- ৪. মেসেজিং স্ক্রিন (হোয়াটসঅ্যাপ স্টাইল প্লাস ও ডাবল টিক সহ) ---
class ConversationScreen extends StatefulWidget {
  final String myPhone;
  final String receiverPhone;

  const ConversationScreen({super.key, required this.myPhone, required this.receiverPhone});

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
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        title: Text(widget.receiverPhone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final s = data['sender'];
                  final r = data['receiver'];
                  return (s == widget.myPhone && r == widget.receiverPhone) ||
                         (s == widget.receiverPhone && r == widget.myPhone);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['sender'] == widget.myPhone;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(data['text'] ?? '', style: const TextStyle(fontSize: 15)),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.done_all, size: 15, color: Color(0xFF34B7F1)),
                            ],
                          ],
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF1E88E5)),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1E88E5),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
