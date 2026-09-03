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
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                      children: [
                        TextSpan(text: 'Read our '),
                        TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                        TextSpan(text: '. Tap "Agree and continue" to accept the '),
                        TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
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
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                    child: const Text('AGREE AND CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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

// --- ২. কান্ট্রি সিলেক্ট ও ফোন নম্বর লগইন স্ক্রিন ---
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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _fullPhoneNumber = '$_selectedCountryCode$phone';
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP পাঠানো হয়েছে! কোড দিন: 123456')),
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
            builder: (context) => ProfilePhotoStepScreen(myPhone: _fullPhoneNumber),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePhotoStepScreen(myPhone: _fullPhoneNumber),
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
        foregroundColor: const Color(0xFF1E88E5),
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
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E88E5)),
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
            Container(height: 1.5, color: const Color(0xFF1E88E5)),

            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 65,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1E88E5), width: 1.5)),
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
                        borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
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
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Next / Verify', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

// --- ৩. ধাপ ১: প্রোফাইল ফটো সেট স্ক্রিন (Skip বাটন সহ) ---
class ProfilePhotoStepScreen extends StatefulWidget {
  final String myPhone;
  const ProfilePhotoStepScreen({super.key, required this.myPhone});

  @override
  State<ProfilePhotoStepScreen> createState() => _ProfilePhotoStepScreenState();
}

class _ProfilePhotoStepScreenState extends State<ProfilePhotoStepScreen> {
  final List<String> _avatarChoices = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
  ];
  String? _selectedPhoto;

  void _choosePhotoDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarChoices.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedPhoto = _avatarChoices[i]);
                      Navigator.pop(ctx);
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(_avatarChoices[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToNameStep(String? photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileNameStepScreen(
          myPhone: widget.myPhone,
          photoUrl: photo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _proceedToNameStep(null),
            child: const Text('Skip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            children: [
              const Text(
                'Add a profile photo so your friends can recognize you on VibeNet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Spacer(),

              InkWell(
                onTap: _choosePhotoDialog,
                borderRadius: BorderRadius.circular(80),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _selectedPhoto != null ? NetworkImage(_selectedPhoto!) : null,
                      child: _selectedPhoto == null
                          ? const Icon(Icons.person, size: 85, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _choosePhotoDialog,
                icon: const Icon(Icons.photo_library, size: 18),
                label: Text(
                  _selectedPhoto == null ? 'Choose photo' : 'Change photo',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () => _proceedToNameStep(_selectedPhoto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _selectedPhoto != null ? 'Next' : 'Continue without photo',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => _proceedToNameStep(null),
                child: const Text('Skip for now', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ৪. ধাপ ২: নাম লেখার স্ক্রিন ---
class ProfileNameStepScreen extends StatefulWidget {
  final String myPhone;
  final String? photoUrl;

  const ProfileNameStepScreen({
    super.key,
    required this.myPhone,
    this.photoUrl,
  });

  @override
  State<ProfileNameStepScreen> createState() => _ProfileNameStepScreenState();
}

class _ProfileNameStepScreenState extends State<ProfileNameStepScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  void _finishProfileSetup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে আপনার নামটি লিখুন')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).set({
        'phone': widget.myPhone,
        'name': name,
        'photoUrl': widget.photoUrl ?? '',
        'about': 'Hey there! I am using VibeNet.',
        'lastSeen': 'Everyone',
        'readReceipts': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboardScreen(myPhone: widget.myPhone),
          ),
          (route) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboardScreen(myPhone: widget.myPhone),
          ),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Enter your name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                    ? NetworkImage(widget.photoUrl!)
                    : null,
                child: (widget.photoUrl == null || widget.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 45, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Please provide your name for your profile',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 36),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type your name here',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                ],
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: _isSaving ? null : _finishProfileSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Finish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ৫. ড্যাশবোর্ড ও বটম নেভিগেশন ---
class MainDashboardScreen extends StatefulWidget {
  final String myPhone;
  const MainDashboardScreen({super.key, required this.myPhone});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 4
          ? WhatsAppProfileScreen(myPhone: widget.myPhone)
          : DashboardHomeBody(myPhone: widget.myPhone),

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
}

// --- ড্যাশবোর্ড হোম বডি (লাইভ স্টোরি আপলোড সহ) ---
class DashboardHomeBody extends StatefulWidget {
  final String myPhone;
  const DashboardHomeBody({super.key, required this.myPhone});

  @override
  State<DashboardHomeBody> createState() => _DashboardHomeBodyState();
}

class _DashboardHomeBodyState extends State<DashboardHomeBody> {
  String _myPhoto = '';
  String _myName = 'You';

  @override
  void initState() {
    super.initState();
    _loadMyInfo();
  }

  void _loadMyInfo() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _myPhoto = doc.data()!['photoUrl'] ?? '';
        _myName = doc.data()!['name'] ?? 'You';
      });
    }
  }

  // স্ট্যাটাস আপলোড ডায়ালগ
  void _addStatusDialog() {
    final statusCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Status'),
        content: TextField(
          controller: statusCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
            onPressed: () async {
              final text = statusCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance.collection('statuses').add({
                  'phone': widget.myPhone,
                  'name': _myName,
                  'photoUrl': _myPhoto,
                  'text': text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status uploaded successfully!')),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  // স্ট্যাটাস দেখার ডায়ালগ
  void _viewStatus(String name, String text) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: 280,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(color: Color(0xFF1E88E5))),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Weather
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        backgroundImage: _myPhoto.isNotEmpty ? NetworkImage(_myPhoto) : null,
                        child: _myPhoto.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('VibeNet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),
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

            // Stories Row (লাইভ ফায়ারবেস স্ট্যাটাস সহ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 95,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('statuses').orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    final statusDocs = snapshot.data?.docs ?? [];

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // My Status Add Button
                        InkWell(
                          onTap: _addStatusDialog,
                          child: Container(
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: _myPhoto.isNotEmpty ? NetworkImage(_myPhoto) : null,
                                      child: _myPhoto.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
                                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text('My Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),

                        // রিয়েল স্ট্যাটাস তালিকা
                        ...statusDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'User';
                          final photo = data['photoUrl'] ?? '';
                          final text = data['text'] ?? '';
                          return InkWell(
                            onTap: () => _viewStatus(name, text),
                            child: Container(
                              margin: const EdgeInsets.only(right: 14),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF1E88E5), width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                                      child: photo.isEmpty ? const Icon(Icons.person) : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Chats Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CHATS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1)),
                  InkWell(onTap: _openNewChatDialog, child: const Icon(Icons.add_circle, color: Color(0xFF1E88E5), size: 24)),
                ],
              ),
            ),

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

                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('কোনো সক্রিয় চ্যাট নেই। + বাটনে চাপ দিয়ে চ্যাট শুরু করুন।', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: list.map((phone) {
                    return _buildChatTile(phone, lastMsgs[phone] ?? 'Tap to chat', 'Just now', 0, null, phone);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 16),

            // Feed & Reels Section
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                Image.network('https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400', height: 130, width: double.infinity, fit: BoxFit.cover),
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
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 198,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400'), fit: BoxFit.cover),
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
    );
  }

  Widget _buildChatTile(String title, String subtitle, String time, int unread, String? avatarUrl, String phone) {
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
          backgroundColor: Colors.grey.shade200,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null || avatarUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF1E88E5)) : null,
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

// --- ৬. পূর্ণাঙ্গ Profile & Settings Screen ---
class WhatsAppProfileScreen extends StatefulWidget {
  final String myPhone;
  const WhatsAppProfileScreen({super.key, required this.myPhone});

  @override
  State<WhatsAppProfileScreen> createState() => _WhatsAppProfileScreenState();
}

class _WhatsAppProfileScreenState extends State<WhatsAppProfileScreen> {
  String _lastSeenOption = 'Everyone';
  bool _readReceipts = true;
  String _userName = 'VibeNet User';
  String _about = 'Available';
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      setState(() {
        _userName = data['name'] ?? _userName;
        _about = data['about'] ?? _about;
        _photoUrl = data['photoUrl'] ?? '';
      });
    }
  }

  void _openPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Privacy Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
              const SizedBox(height: 16),
              const Text('Who can see my personal info', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Last seen and online'),
                subtitle: Text(_lastSeenOption),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showChoiceDialog('Last seen and online', ['Everyone', 'My contacts', 'Nobody'], _lastSeenOption, (val) {
                    setState(() => _lastSeenOption = val);
                    setModalState(() {});
                  });
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Profile photo'),
                subtitle: const Text('Everyone'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('About'),
                subtitle: const Text('Everyone'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Read receipts (Blue ticks)'),
                subtitle: const Text('If turned off, you won\'t send or receive Read receipts.'),
                value: _readReceipts,
                activeColor: const Color(0xFF1E88E5),
                onChanged: (val) {
                  setState(() => _readReceipts = val);
                  setModalState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChoiceDialog(String title, List<String> options, String currentVal, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return RadioListTile<String>(
              title: Text(opt),
              value: opt,
              groupValue: currentVal,
              activeColor: const Color(0xFF1E88E5),
              onChanged: (v) {
                if (v != null) {
                  onSelect(v);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _editNameDialog() {
    final ctrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter your name'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Your Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _userName = ctrl.text.trim());
                await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'name': _userName});
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: _editNameDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                        child: _photoUrl.isEmpty ? const Icon(Icons.person, size: 36, color: Colors.grey) : null,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: Color(0xFF1E88E5),
                          child: Icon(Icons.edit, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_about, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(widget.myPhone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Color(0xFF1E88E5)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1, height: 1),
          _buildSettingsTile(icon: Icons.key_outlined, title: 'Account', subtitle: 'Security notifications, change number', onTap: () {}),
          _buildSettingsTile(icon: Icons.lock_outline, title: 'Privacy', subtitle: 'Last seen, profile photo, read receipts', onTap: _openPrivacySettings),
          _buildSettingsTile(icon: Icons.chat_outlined, title: 'Chats', subtitle: 'Theme, wallpapers, chat history', onTap: () {}),
          _buildSettingsTile(icon: Icons.notifications_none_outlined, title: 'Notifications', subtitle: 'Message, group & call tones', onTap: () {}),
          _buildSettingsTile(icon: Icons.data_usage_outlined, title: 'Storage and data', subtitle: 'Network usage, auto-download', onTap: () {}),
          _buildSettingsTile(icon: Icons.help_outline, title: 'Help', subtitle: 'Help center, contact us, privacy policy', onTap: () {}),
          _buildSettingsTile(icon: Icons.group_add_outlined, title: 'Invite a friend', subtitle: 'Share VibeNet with friends', onTap: () {}),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()));
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      onTap: onTap,
    );
  }
}

// --- ৭. মেসেজিং স্ক্রিন (অডিও/ভিডিও কলিং স্ক্রিন সহ) ---
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

  // অডিও ও ভিডিও কল ডায়ালগ
  void _startCall(bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: const Color(0xFF1C2833),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1E88E5),
                  child: Icon(isVideo ? Icons.videocam : Icons.person, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(widget.receiverPhone, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(isVideo ? 'VibeNet Video Calling...' : 'VibeNet Audio Calling...', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          spacing: 24,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildActionItem(Icons.insert_drive_file, 'Document', const Color(0xFF7F66FF)),
            _buildActionItem(Icons.camera_alt, 'Camera', const Color(0xFFD33682)),
            _buildActionItem(Icons.photo, 'Gallery', const Color(0xFFAC44CF)),
            _buildActionItem(Icons.headset, 'Audio', const Color(0xFFE95950)),
            _buildActionItem(Icons.location_on, 'Location', const Color(0xFF1B9E5A)),
            _buildActionItem(Icons.person, 'Contact', const Color(0xFF009EE0)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 28, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 28)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
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
          IconButton(icon: const Icon(Icons.videocam), onPressed: () => _startCall(true)),
          IconButton(icon: const Icon(Icons.call), onPressed: () => _startCall(false)),
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
                            Flexible(child: Text(data['text'] ?? '', style: const TextStyle(fontSize: 15))),
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
                          onPressed: _showAttachmentOptions,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
