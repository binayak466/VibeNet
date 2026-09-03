import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VibeNetApp());
}

final ValueNotifier<String> appLanguage = ValueNotifier<String>('en');

final Map<String, Map<String, String>> localizedStrings = {
  'en': {
    'welcome': 'Welcome to VibeNet',
    'terms_desc': 'Simple. Secure. Reliable messaging with your saved contacts.',
    'agree_continue': 'AGREE AND CONTINUE',
    'enter_phone': 'Enter your phone number',
    'verify_desc': 'VibeNet will need to verify your phone number.',
    'phone_hint': 'phone number',
    'next': 'Next',
    'verify': 'Next / Verify',
    'enter_code': 'Enter 6-digit Code (123456)',
    'invalid_phone': 'Please enter a valid phone number',
    'wrong_otp': 'Wrong OTP! Enter: 123456',
    'change_language': 'Language',
  },
  'bn': {
    'welcome': 'VibeNet-এ স্বাগতম',
    'terms_desc': 'সহজ, নিরাপদ এবং সুরক্ষিত যোগাযোগ শুধুমাত্র সেভ থাকা বন্ধুদের সাথে।',
    'agree_continue': 'সম্মতি দিন ও এগিয়ে যান',
    'enter_phone': 'আপনার মোবাইল নম্বর দিন',
    'verify_desc': 'VibeNet আপনার নম্বর যাচাই করার জন্য একটি ওটিপি পাঠাবে।',
    'phone_hint': 'ফোন নম্বর',
    'next': 'পরবর্তী',
    'verify': 'যাচাই করুন',
    'enter_code': '৬ সংখ্যার কোড দিন (123456)',
    'invalid_phone': 'সঠিক মোবাইল নম্বর দিন',
    'wrong_otp': 'ভুল OTP! সঠিক কোডটি দিন: 123456',
    'change_language': 'ভাষা পরিবর্তন',
  },
  'hi': {
    'welcome': 'VibeNet में आपका स्वागत है',
    'terms_desc': 'सरल, सुरक्षित और भरोसेमंद मैसेजिंग आपके संपर्कों के साथ।',
    'agree_continue': 'स्वीकार करें और जारी रखें',
    'enter_phone': 'अपना फ़ोन नंबर दर्ज करें',
    'verify_desc': 'VibeNet को आपका फ़ोन नंबर सत्यापित करना होगा।',
    'phone_hint': 'फ़ोन नंबर',
    'next': 'आगे बढ़ें',
    'verify': 'सत्यापित करें',
    'enter_code': '6 अंकों का कोड दर्ज करें (123456)',
    'invalid_phone': 'कृपया सही फ़ोन नंबर दर्ज करें',
    'wrong_otp': 'गलत OTP! सही कोड दर्ज करें: 123456',
    'change_language': 'भाषा बदलें',
  },
};

String tr(String key) {
  return localizedStrings[appLanguage.value]?[key] ?? localizedStrings['en']![key]!;
}

void showLanguageSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Language / ভাষা নির্বাচন করুন',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('English'),
            trailing: appLanguage.value == 'en' ? const Icon(Icons.check, color: Color(0xFF1E88E5)) : null,
            onTap: () {
              appLanguage.value = 'en';
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('বাংলা (Bengali)'),
            trailing: appLanguage.value == 'bn' ? const Icon(Icons.check, color: Color(0xFF1E88E5)) : null,
            onTap: () {
              appLanguage.value = 'bn';
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('हिन्दी (Hindi)'),
            trailing: appLanguage.value == 'hi' ? const Icon(Icons.check, color: Color(0xFF1E88E5)) : null,
            onTap: () {
              appLanguage.value = 'hi';
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}

class VibeNetApp extends StatelessWidget {
  const VibeNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, child) {
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
      },
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

  Future<Widget> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null && doc.data()!['phone'] != null) {
        final phone = doc.data()!['phone'] as String;
        final token = doc.data()!['sessionToken'] as String? ?? '';
        return MainDashboardScreen(myPhone: phone, currentSessionToken: token);
      }
    }
    return const WelcomeTermsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder<Widget>(
            future: _checkLoginStatus(),
            builder: (context, loginSnapshot) {
              if (loginSnapshot.connectionState == ConnectionState.done && loginSnapshot.hasData) {
                return loginSnapshot.data!;
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
              );
            },
          );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => showLanguageSelector(context),
            icon: const Icon(Icons.language, size: 18, color: Color(0xFF1E88E5)),
            label: Text(
              appLanguage.value == 'bn' ? 'বাংলা' : (appLanguage.value == 'hi' ? 'हिन्दी' : 'English'),
              style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('welcome'),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
              ),
              Column(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1E88E5).withOpacity(0.2), const Color(0xFF42A5F5).withOpacity(0.1)],
                      ),
                    ),
                    child: const Icon(Icons.forum_rounded, size: 85, color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    tr('terms_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                    child: Text(tr('agree_continue'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 14),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('invalid_phone'))));
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
          SnackBar(content: Text(appLanguage.value == 'bn' ? 'OTP পাঠানো হয়েছে! কোড দিন: 123456' : 'OTP sent! Use code: 123456')),
        );
      }
    });
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('wrong_otp'))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCred;
      if (FirebaseAuth.instance.currentUser == null) {
        userCred = await FirebaseAuth.instance.signInAnonymously();
      } else {
        userCred = await FirebaseAuth.instance.signInAnonymously();
      }

      final uid = userCred.user?.uid ?? FirebaseAuth.instance.currentUser!.uid;
      final newSessionToken = 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'phone': _fullPhoneNumber,
        'sessionToken': newSessionToken,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(_fullPhoneNumber).set({
        'phone': _fullPhoneNumber,
        'activeSessionToken': newSessionToken,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePhotoStepScreen(
              myPhone: _fullPhoneNumber,
              sessionToken: newSessionToken,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePhotoStepScreen(myPhone: _fullPhoneNumber, sessionToken: ''),
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
        title: Text(tr('enter_phone'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded, color: Color(0xFF1E88E5)),
            tooltip: tr('change_language'),
            onPressed: () => showLanguageSelector(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Text(
              tr('verify_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
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
                      child: Text(country['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1E88E5), width: 1.5))),
                  alignment: Alignment.center,
                  child: Text(_selectedCountryCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isOtpSent,
                    decoration: InputDecoration(
                      hintText: tr('phone_hint'),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.5)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2)),
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
                decoration: InputDecoration(labelText: tr('enter_code'), border: const OutlineInputBorder()),
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
                    : Text(tr('verify'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                    : Text(tr('next'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 24),

            TextButton.icon(
              onPressed: () => showLanguageSelector(context),
              icon: const Icon(Icons.language, size: 16, color: Colors.grey),
              label: Text(
                '${tr('change_language')}: ${appLanguage.value == 'bn' ? 'বাংলা' : (appLanguage.value == 'hi' ? 'हिन्दी' : 'English')}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ৩. প্রোফাইল ফটো স্ক্রিন ---
class ProfilePhotoStepScreen extends StatefulWidget {
  final String myPhone;
  final String sessionToken;
  const ProfilePhotoStepScreen({super.key, required this.myPhone, required this.sessionToken});

  @override
  State<ProfilePhotoStepScreen> createState() => _ProfilePhotoStepScreenState();
}

class _ProfilePhotoStepScreenState extends State<ProfilePhotoStepScreen> {
  final List<String> _avatarChoices = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
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
                    child: CircleAvatar(radius: 35, backgroundImage: NetworkImage(_avatarChoices[i])),
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
          sessionToken: widget.sessionToken,
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
              const Text('Add a profile photo so your friends can recognize you on VibeNet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                      child: _selectedPhoto == null ? const Icon(Icons.person, size: 85, color: Colors.grey) : null,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
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
                label: Text(_selectedPhoto == null ? 'Choose photo' : 'Change photo', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _proceedToNameStep(_selectedPhoto),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text(_selectedPhoto != null ? 'Next' : 'Continue without photo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: () => _proceedToNameStep(null), child: const Text('Skip for now', style: TextStyle(color: Colors.grey, fontSize: 14))),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ৪. নাম লেখার স্ক্রিন ---
class ProfileNameStepScreen extends StatefulWidget {
  final String myPhone;
  final String? photoUrl;
  final String sessionToken;

  const ProfileNameStepScreen({super.key, required this.myPhone, this.photoUrl, required this.sessionToken});

  @override
  State<ProfileNameStepScreen> createState() => _ProfileNameStepScreenState();
}

class _ProfileNameStepScreenState extends State<ProfileNameStepScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  void _finishProfileSetup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে আপনার নামটি লিখুন')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final userData = {
        'phone': widget.myPhone,
        'name': name,
        'photoUrl': widget.photoUrl ?? '',
        'about': 'Hey there! I am using VibeNet.',
        'sessionToken': widget.sessionToken,
        'lastSeen': 'Everyone',
        'readReceipts': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData, SetOptions(merge: true));
      }
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).set(userData, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboardScreen(
              myPhone: widget.myPhone,
              currentSessionToken: widget.sessionToken,
            ),
          ),
          (route) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboardScreen(myPhone: widget.myPhone, currentSessionToken: widget.sessionToken),
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
      appBar: AppBar(title: const Text('Enter your name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), centerTitle: true, backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E88E5), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.photoUrl != null && widget.photoUrl!.isNotEmpty ? NetworkImage(widget.photoUrl!) : null,
                child: (widget.photoUrl == null || widget.photoUrl!.isEmpty) ? const Icon(Icons.person, size: 45, color: Colors.grey) : null,
              ),
              const SizedBox(height: 20),
              const Text('Please provide your name for your profile', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 36),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Type your name here', border: OutlineInputBorder()),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSaving ? null : _finishProfileSetup,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Finish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ৫. ড্যাশবোর্ড স্ক্রিন ---
class MainDashboardScreen extends StatefulWidget {
  final String myPhone;
  final String currentSessionToken;
  const MainDashboardScreen({super.key, required this.myPhone, required this.currentSessionToken});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _listenToSessionChanges();
  }

  void _listenToSessionChanges() {
    FirebaseFirestore.instance.collection('users').doc(widget.myPhone).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final activeToken = snapshot.data()!['activeSessionToken'] as String?;
        if (activeToken != null && widget.currentSessionToken.isNotEmpty && activeToken != widget.currentSessionToken) {
          FirebaseAuth.instance.signOut();
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Logged Out!'),
                content: const Text('আপনার এই মোবাইল নম্বর দিয়ে অন্য আরেকটি ডিভাইসে লগইন করা হয়েছে। নিরাপত্তা কারণে এই ডিভাইস থেকে লগআউট করা হলো।'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()),
                        (r) => false,
                      );
                    },
                    child: const Text('OK'),
                  )
                ],
              ),
            );
          }
        }
      }
    });
  }

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

// --- ড্যাশবোর্ড বডি ---
class DashboardHomeBody extends StatefulWidget {
  final String myPhone;
  const DashboardHomeBody({super.key, required this.myPhone});

  @override
  State<DashboardHomeBody> createState() => _DashboardHomeBodyState();
}

class _DashboardHomeBodyState extends State<DashboardHomeBody> {
  String _myPhoto = '';
  String _myName = 'You';

  String _weatherCity = 'Detecting...';
  String _weatherTemp = '--°C';
  IconData _weatherIcon = Icons.wb_sunny_rounded;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadMyInfo();
    _fetchLiveWeather();
  }

  Future<void> _fetchLiveWeather() async {
    setState(() => _isLoadingWeather = true);
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(Uri.parse('https://wttr.in/?format=j1'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final current = data['current_condition']?[0];
        final area = data['nearest_area']?[0];

        final temp = current?['temp_C'] ?? '28';
        final city = area?['areaName']?[0]?['value'] ?? 'Local';
        final desc = (current?['weatherDesc']?[0]?['value'] ?? '').toString().toLowerCase();

        IconData icon = Icons.wb_sunny_rounded;
        if (desc.contains('rain') || desc.contains('drizzle')) {
          icon = Icons.grain_rounded;
        } else if (desc.contains('cloud') || desc.contains('overcast')) {
          icon = Icons.cloud_rounded;
        }

        if (mounted) {
          setState(() {
            _weatherCity = city;
            _weatherTemp = '$temp°C';
            _weatherIcon = icon;
            _isLoadingWeather = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _weatherCity = 'Kolkata';
          _weatherTemp = '28°C';
          _isLoadingWeather = false;
        });
      }
    }
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

  void _openContactsOnlyChat() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কনট্যাক্ট অ্যাক্সেসের অনুমতি দিন')),
        );
      }
      return;
    }

    final phoneContacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: false);
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final registeredPhones = <String, String>{};

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      final p = data['phone'] as String?;
      final n = data['name'] as String? ?? 'VibeNet User';
      if (p != null) registeredPhones[p] = n;
    }

    final List<Map<String, String>> matchedContacts = [];

    for (var contact in phoneContacts) {
      for (var phoneObj in contact.phones) {
        var cleanNumber = phoneObj.number.replaceAll(RegExp(r'\s+|-|\(|\)'), '');
        if (!cleanNumber.startsWith('+')) {
          cleanNumber = '+91$cleanNumber';
        }

        if (registeredPhones.containsKey(cleanNumber) && cleanNumber != widget.myPhone) {
          matchedContacts.add({
            'name': contact.displayName.isNotEmpty ? contact.displayName : registeredPhones[cleanNumber]!,
            'phone': cleanNumber,
          });
          break;
        }
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Contact (সেভ থাকা নম্বর)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
            ),
            const SizedBox(height: 10),
            if (matchedContacts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'আপনার ফোনে সেভ থাকা কোনো বন্ধু এখনো VibeNet ইনস্টল করেনি।',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: matchedContacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = matchedContacts[i];
                    return ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFF1E88E5), child: Icon(Icons.person, color: Colors.white)),
                      title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c['phone']!),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationScreen(
                              myPhone: widget.myPhone,
                              receiverPhone: c['phone']!,
                              receiverName: c['name']!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
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
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFF1976D2).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
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
                      const Expanded(child: Text('VibeNet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchLiveWeather),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Icon(_weatherIcon, color: Colors.amberAccent, size: 36),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_weatherTemp, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            Text(_weatherCity, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CHATS (SAVED CONTACTS)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1)),
                  InkWell(
                    onTap: _openContactsOnlyChat,
                    child: const Icon(Icons.person_add_alt_1, color: Color(0xFF1E88E5), size: 24),
                  ),
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
                      padding: EdgeInsets.all(32.0),
                      child: Text('কোনো চ্যাট নেই। সেভ থাকা বন্ধুদের সাথে চ্যাট করতে ডানদিকের আইকনে ট্যাপ করুন।', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: list.map((phone) {
                    return ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFF1E88E5), child: Icon(Icons.person, color: Colors.white)),
                      title: Text(phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(lastMsgs[phone] ?? 'Tap to chat', maxLines: 1),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ConversationScreen(myPhone: widget.myPhone, receiverPhone: phone, receiverName: phone),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// --- ৬. সম্পূর্ণ WhatsApp স্টাইল Profile & Settings Screen ---
class WhatsAppProfileScreen extends StatefulWidget {
  final String myPhone;
  const WhatsAppProfileScreen({super.key, required this.myPhone});

  @override
  State<WhatsAppProfileScreen> createState() => _WhatsAppProfileScreenState();
}

class _WhatsAppProfileScreenState extends State<WhatsAppProfileScreen> {
  String _userName = 'VibeNet User';
  String _about = 'Hey there! I am using VibeNet.';
  String _photoUrl = '';
  String _lastSeenOption = 'Everyone';
  bool _readReceipts = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _userName = doc.data()!['name'] ?? _userName;
        _about = doc.data()!['about'] ?? _about;
        _photoUrl = doc.data()!['photoUrl'] ?? '';
        _lastSeenOption = doc.data()!['lastSeen'] ?? 'Everyone';
        _readReceipts = doc.data()!['readReceipts'] ?? true;
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
                    FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'lastSeen': val});
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
                  FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'readReceipts': val});
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
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({'name': _userName});
                }
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
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          // Profile Card Header
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

          // সমস্ত সেটিংস অপশন
          _buildSettingsTile(
            icon: Icons.key_outlined,
            title: 'Account',
            subtitle: 'Security notifications, change number',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Last seen, profile photo, read receipts',
            onTap: _openPrivacySettings,
          ),
          _buildSettingsTile(
            icon: Icons.chat_outlined,
            title: 'Chats',
            subtitle: 'Theme, wallpapers, chat history',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            subtitle: 'Message, group & call tones',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.data_usage_outlined,
            title: 'Storage and data',
            subtitle: 'Network usage, auto-download',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.translate,
            title: 'App Language / ভাষা',
            subtitle: appLanguage.value == 'bn' ? 'বাংলা' : (appLanguage.value == 'hi' ? 'हिन्दी' : 'English'),
            onTap: () => showLanguageSelector(context),
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help',
            subtitle: 'Help center, contact us, privacy policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.group_add_outlined,
            title: 'Invite a friend',
            subtitle: 'Share VibeNet with friends',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Logout বাটন
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

// --- ৭. মেসেজিং স্ক্রিন ---
class ConversationScreen extends StatefulWidget {
  final String myPhone;
  final String receiverPhone;
  final String receiverName;

  const ConversationScreen({super.key, required this.myPhone, required this.receiverPhone, required this.receiverName});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    await FirebaseFirestore.instance.collection('chats').add({
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.receiverPhone, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final s = data['sender'];
                  final r = data['receiver'];
                  return (s == widget.myPhone && r == widget.receiverPhone) || (s == widget.receiverPhone && r == widget.myPhone);
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
                        decoration: BoxDecoration(color: isMe ? const Color(0xFFDCF8C6) : Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Text(data['text'] ?? '', style: const TextStyle(fontSize: 15)),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1E88E5),
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
