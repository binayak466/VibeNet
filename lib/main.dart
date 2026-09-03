import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VibeNetApp());
}

String maskPhoneNumber(String phone) {
  if (phone.length > 6) {
    return '${phone.substring(0, 3)}••••••${phone.substring(phone.length - 4)}';
  }
  return '••••••••';
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
          const Text('Choose Language / ভাষা নির্বাচন করুন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
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
      } else {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!['phone'] != null) {
          final phone = userDoc.data()!['phone'] as String;
          final token = userDoc.data()!['sessionToken'] as String? ?? '';
          return MainDashboardScreen(myPhone: phone, currentSessionToken: token);
        }
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
              return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))));
            },
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))));
      },
    );
  }
}

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
              Text(tr('welcome'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
              Column(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [const Color(0xFF1E88E5).withOpacity(0.2), const Color(0xFF42A5F5).withOpacity(0.1)]),
                    ),
                    child: const Icon(Icons.forum_rounded, size: 85, color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(height: 28),
                  Text(tr('terms_desc'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      UserCredential userCred = await FirebaseAuth.instance.signInAnonymously();
      final uid = userCred.user!.uid;
      final newSessionToken = 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

      final existingDoc = await FirebaseFirestore.instance.collection('users').doc(_fullPhoneNumber).get();
      
      if (existingDoc.exists && existingDoc.data() != null) {
        await FirebaseFirestore.instance.collection('users').doc(_fullPhoneNumber).update({
          'activeSessionToken': newSessionToken,
        });
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'phone': _fullPhoneNumber,
          'sessionToken': newSessionToken,
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainDashboardScreen(myPhone: _fullPhoneNumber, currentSessionToken: newSessionToken)),
            (r) => false,
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePhotoStepScreen(myPhone: _fullPhoneNumber, sessionToken: newSessionToken)));
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePhotoStepScreen(myPhone: _fullPhoneNumber, sessionToken: '')));
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(tr('verify_desc'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 14)),
            const SizedBox(height: 28),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                onChanged: _isOtpSent ? null : (v) => setState(() => _selectedCountry = v!),
                items: _countries.map((c) => DropdownMenuItem(value: c['name'], child: Center(child: Text(c['name']!)))).toList(),
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
                  child: Text(_selectedCountryCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isOtpSent,
                    decoration: InputDecoration(hintText: tr('phone_hint')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_isOtpSent) ...[
              TextField(controller: _otpController, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: InputDecoration(labelText: tr('enter_code'))),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _isLoading ? null : _verifyOtp, child: Text(tr('verify'))),
            ] else ...[
              ElevatedButton(onPressed: _isLoading ? null : _sendOtp, child: Text(tr('next'))),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfilePhotoStepScreen extends StatefulWidget {
  final String myPhone;
  final String sessionToken;
  const ProfilePhotoStepScreen({super.key, required this.myPhone, required this.sessionToken});

  @override
  State<ProfilePhotoStepScreen> createState() => _ProfilePhotoStepScreenState();
}

class _ProfilePhotoStepScreenState extends State<ProfilePhotoStepScreen> {
  final List<String> _avatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  ];
  String? _photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Photo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, backgroundImage: _photo != null ? NetworkImage(_photo!) : null, child: _photo == null ? const Icon(Icons.person, size: 60) : null),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => setState(() => _photo = _avatars[0]), child: const Text('Select Avatar')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ProfileNameStepScreen(myPhone: widget.myPhone, photoUrl: _photo, sessionToken: widget.sessionToken))),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileNameStepScreen extends StatefulWidget {
  final String myPhone;
  final String? photoUrl;
  final String sessionToken;
  const ProfileNameStepScreen({super.key, required this.myPhone, this.photoUrl, required this.sessionToken});

  @override
  State<ProfileNameStepScreen> createState() => _ProfileNameStepScreenState();
}

class _ProfileNameStepScreenState extends State<ProfileNameStepScreen> {
  final TextEditingController _nameCtrl = TextEditingController();

  void _finish() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final data = {'phone': widget.myPhone, 'name': name, 'photoUrl': widget.photoUrl ?? '', 'sessionToken': widget.sessionToken, 'activeSessionToken': widget.sessionToken};
    await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).set(data, SetOptions(merge: true));
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => MainDashboardScreen(myPhone: widget.myPhone, currentSessionToken: widget.sessionToken)), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Name')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your Name')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _finish, child: const Text('Finish')),
          ],
        ),
      ),
    );
  }
}

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
                content: const Text('অন্য ডিভাইসে লগইন করার কারণে এই ডিভাইস থেকে লগআউট করা হলো।'),
                actions: [
                  ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()), (r) => false), child: const Text('OK'))
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
        onTap: (i) {
          if (i == 2) {
            openContactsChat(context, widget.myPhone);
          } else {
            setState(() => _currentIndex = i);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.feed_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 32, color: Color(0xFF1E88E5)), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}

void openContactsChat(BuildContext context, String myPhone) async {
  final status = await Permission.contacts.request();
  if (!status.isGranted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কনট্যাক্ট অ্যাক্সেসের অনুমতি দিন')));
    }
    return;
  }

  final phoneContacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: false);
  final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
  
  final Map<String, String> registeredPhones = {};
  for (var doc in usersSnapshot.docs) {
    final data = doc.data();
    final p = data['phone'] as String?;
    final n = data['name'] as String? ?? 'VibeNet User';
    if (p != null && p.isNotEmpty) {
      final cleanDbPhone = p.replaceAll(RegExp(r'\D'), '');
      if (cleanDbPhone.length >= 10) {
        registeredPhones[cleanDbPhone.substring(cleanDbPhone.length - 10)] = p;
      }
    }
  }

  final List<Map<String, String>> matchedContacts = [];
  for (var contact in phoneContacts) {
    for (var phoneObj in contact.phones) {
      var rawNum = phoneObj.number.replaceAll(RegExp(r'\D'), '');
      if (rawNum.length >= 10) {
        final last10 = rawNum.substring(rawNum.length - 10);
        if (registeredPhones.containsKey(last10)) {
          final matchedFullPhone = registeredPhones[last10]!;
          if (matchedFullPhone != myPhone) {
            matchedContacts.add({
              'name': contact.displayName.isNotEmpty ? contact.displayName : 'VibeNet User',
              'phone': matchedFullPhone,
            });
            break;
          }
        }
      }
    }
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) {
        String searchQuery = '';
        final filteredList = matchedContacts.where((c) {
          return c['name']!.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Contact (সেভ থাকা নম্বর)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) => setModalState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search contact by name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              if (filteredList.isEmpty)
                const Expanded(child: Center(child: Text('আপনার সেভ থাকা কন্ট্যাক্টগুলোর মধ্যে এই অ্যাপে কেউ রেজিস্টার্ড নেই।', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = filteredList[i];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFF1E88E5), child: Icon(Icons.person, color: Colors.white)),
                        title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(maskPhoneNumber(c['phone']!)),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(myPhone: myPhone, receiverPhone: c['phone']!, receiverName: c['name']!),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationScreen(myPhone: myPhone, receiverPhone: c['phone']!, receiverName: c['name']!),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class DashboardHomeBody extends StatefulWidget {
  final String myPhone;
  const DashboardHomeBody({super.key, required this.myPhone});

  @override
  State<DashboardHomeBody> createState() => _DashboardHomeBodyState();
}

class _DashboardHomeBodyState extends State<DashboardHomeBody> {
  String _weatherCity = 'Kolkata';
  String _weatherTemp = '28°C';
  IconData _weatherIcon = Icons.wb_sunny_rounded;
  String _myPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchLiveWeather();
    _loadMyProfile();
  }

  void _loadMyProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _myPhotoUrl = doc.data()!['photoUrl'] ?? '';
      });
    }
  }

  Future<void> _fetchLiveWeather() async {
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

        if (mounted) {
          setState(() {
            _weatherCity = city;
            _weatherTemp = '$temp°C';
          });
        }
      }
    } catch (_) {}
  }

  void _openGlobalSearch(BuildContext context) {
    showSearch(context: context, delegate: GlobalUserSearchDelegate(myPhone: widget.myPhone));
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
                        radius: 16,
                        backgroundColor: Colors.white24,
                        backgroundImage: _myPhotoUrl.isNotEmpty
                            ? (_myPhotoUrl.startsWith('/') ? FileImage(File(_myPhotoUrl)) : NetworkImage(_myPhotoUrl)) as ImageProvider
                            : null,
                        child: _myPhotoUrl.isEmpty ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('VibeNet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () => _openGlobalSearch(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                        onPressed: () => openContactsChat(context, widget.myPhone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStatusItem('Rahul', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                  _buildStatusItem('Priya', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
                  _buildStatusItem('Anita', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200'),
                  _buildStatusItem('Vikram', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200'),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text('CHATS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1)),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                final Set<String> partners = {};
                final Map<String, String> lastMsgs = {};
                if (snapshot.hasData) {
                  for (var d in snapshot.data!.docs) {
                    final data = d.data() as Map<String, dynamic>;
                    final s = data['sender'];
                    final r = data['receiver'];
                    final txt = data['text'] ?? '';
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
                      child: Text('কোনো চ্যাট নেই। নিচে (+) বাটন অথবা ওপরের কন্ট্যাক্ট আইকন থেকে চ্যাট শুরু করুন।', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final phone = list[i];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(phone).get(),
                      builder: (context, userSnap) {
                        String name = phone;
                        if (userSnap.hasData && userSnap.data!.exists) {
                          name = userSnap.data!['name'] ?? phone;
                        }
                        return ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF1E88E5), child: Icon(Icons.person, color: Colors.white)),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(lastMsgs[phone] ?? maskPhoneNumber(phone), maxLines: 1),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ConversationScreen(myPhone: widget.myPhone, receiverPhone: phone, receiverName: name))),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String name, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1E88E5), width: 2.5)),
            child: CircleAvatar(radius: 24, backgroundImage: NetworkImage(imgUrl)),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class GlobalUserSearchDelegate extends SearchDelegate<String> {
  final String myPhone;
  GlobalUserSearchDelegate({required this.myPhone});

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => _searchResult(context);

  @override
  Widget buildSuggestions(BuildContext context) => _searchResult(context);

  Widget _searchResult(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString();
          if (phone == myPhone) return false;
          return name.contains(query.toLowerCase());
        }).toList();

        if (docs.isEmpty) return const Center(child: Text('কাউকে পাওয়া যায়নি'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (ctx, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'User';
            final phone = data['phone'] ?? '';
            final photo = data['photoUrl'] ?? '';

            return ListTile(
              leading: CircleAvatar(backgroundImage: photo.isNotEmpty && !photo.startsWith('/') ? NetworkImage(photo) : (photo.isNotEmpty ? FileImage(File(photo)) as ImageProvider : null), child: photo.isEmpty ? const Icon(Icons.person) : null),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(maskPhoneNumber(phone)),
              trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1E88E5)),
              onTap: () {
                close(context, phone);
                Navigator.push(context, MaterialPageRoute(builder: (c) => ConversationScreen(myPhone: myPhone, receiverPhone: phone, receiverName: name)));
              },
            );
          },
        );
      },
    );
  }
}

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
  String _profilePhotoPrivacy = 'Everyone';
  bool _readReceipts = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _userName = doc.data()!['name'] ?? _userName;
        _about = doc.data()!['about'] ?? _about;
        _photoUrl = doc.data()!['photoUrl'] ?? '';
        _lastSeenOption = doc.data()!['lastSeen'] ?? 'Everyone';
        _profilePhotoPrivacy = doc.data()!['profilePhotoPrivacy'] ?? 'Everyone';
        _readReceipts = doc.data()!['readReceipts'] ?? true;
      });
    }
  }

  void _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String imagePath = image.path;
      setState(() => _photoUrl = imagePath);
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
        'photoUrl': imagePath,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('প্রোফাইল ছবি সফলভাবে আপডেট করা হয়েছে!')),
        );
      }
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
                subtitle: Text(_profilePhotoPrivacy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showChoiceDialog('Profile photo', ['Everyone', 'My contacts', 'Nobody'], _profilePhotoPrivacy, (val) {
                    setState(() => _profilePhotoPrivacy = val);
                    setModalState(() {});
                    FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'profilePhotoPrivacy': val});
                  });
                },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile / Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _photoUrl.isNotEmpty
                            ? (_photoUrl.startsWith('/') ? FileImage(File(_photoUrl)) : NetworkImage(_photoUrl)) as ImageProvider
                            : null,
                        child: _photoUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_about, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(maskPhoneNumber(widget.myPhone), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.grey),
            title: const Text('Privacy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: const Text('Last seen, profile photo, read receipts', style: TextStyle(fontSize: 13, color: Colors.grey)),
            onTap: _openPrivacySettings,
          ),
          const Divider(thickness: 1, height: 1),
          ListTile(
            leading: const Icon(Icons.translate, color: Color(0xFF1E88E5)),
            title: const Text('App Language / ভাষা'),
            subtitle: Text(appLanguage.value == 'bn' ? 'বাংলা' : (appLanguage.value == 'hi' ? 'हिन्दी' : 'English')),
            onTap: () => showLanguageSelector(context),
          ),
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 30),
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
        ],
      ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  final String myPhone;
  final String receiverPhone;
  final String receiverName;
  const ConversationScreen({super.key, required this.myPhone, required this.receiverPhone, required this.receiverName});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  void _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await FirebaseFirestore.instance.collection('chats').add({
      'sender': widget.myPhone,
      'receiver': widget.receiverPhone,
      'text': text,
      'isSeen': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _deleteMessage(String docId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('chats').doc(docId).delete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(maskPhoneNumber(widget.receiverPhone), style: const TextStyle(fontSize: 11)),
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
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['sender'] == widget.myPhone;
                    final isSeen = data['isSeen'] ?? false;

                    if (!isMe && !isSeen) {
                      FirebaseFirestore.instance.collection('chats').doc(doc.id).update({'isSeen': true});
                    }

                    return GestureDetector(
                      onLongPress: () => _deleteMessage(doc.id),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  data['text'] ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (isMe)
                                Icon(
                                  Icons.done_all,
                                  size: 16,
                                  color: isSeen ? Colors.blue : Colors.grey,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E88E5)),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
