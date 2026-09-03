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
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

final Map<String, Map<String, String>> localizedStrings = {
  'en': {
    'welcome': 'Welcome to VibeNet',
    'terms_desc': 'Simple. Secure. All-in-one messaging, social & payments.',
    'agree_continue': 'AGREE AND CONTINUE',
    'enter_phone': 'Enter your phone number',
    'verify_desc': 'VibeNet will need to verify your phone number.',
    'phone_hint': 'phone number',
    'next': 'Next',
    'verify': 'Next / Verify',
    'enter_code': 'Enter 6-digit Code (123456)',
    'invalid_phone': 'Please enter a valid phone number',
    'wrong_otp': 'Wrong OTP! Enter: 123456',
  },
  'bn': {
    'welcome': 'VibeNet-এ স্বাগতম',
    'terms_desc': 'চ্যাট, সোশ্যাল ফিড এবং পেমেন্ট একসাথে একটি অ্যাপে।',
    'agree_continue': 'সম্মতি দিন ও এগিয়ে যান',
    'enter_phone': 'আপনার মোবাইল নম্বর দিন',
    'verify_desc': 'VibeNet আপনার নম্বর যাচাই করার জন্য একটি ওটিপি পাঠাবে।',
    'phone_hint': 'ফোন নম্বর',
    'next': 'পরবর্তী',
    'verify': 'যাচাই করুন',
    'enter_code': '৬ সংখ্যার কোড দিন (123456)',
    'invalid_phone': 'সঠিক মোবাইল নম্বর দিন',
    'wrong_otp': 'ভুল OTP! সঠিক কোডটি দিন: 123456',
  },
  'hi': {
    'welcome': 'VibeNet में आपका स्वागत है',
    'terms_desc': 'चैट, सोशल फीड और भुगतान एक ही ऐप में।',
    'agree_continue': 'स्वीकार करें और जारी रखें',
    'enter_phone': 'अपना फ़ोन नंबर दर्ज करें',
    'verify_desc': 'VibeNet को आपका फ़ोन नंबर सत्यापित करना होगा।',
    'phone_hint': 'फ़ोन नंबर',
    'next': 'आगे बढ़ें',
    'verify': 'सत्यापित करें',
    'enter_code': '6 अंकों का कोड दर्ज करें (123456)',
    'invalid_phone': 'कृपया सही फ़ोन नंबर दर्ज करें',
    'wrong_otp': 'गलत OTP! सही कोड दर्ज करें: 123456',
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
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'VibeNet',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: ThemeData(
                fontFamily: 'Roboto',
                colorSchemeSeed: const Color(0xFF1E88E5),
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData(
                fontFamily: 'Roboto',
                colorSchemeSeed: const Color(0xFF1E88E5),
                useMaterial3: true,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF121212),
              ),
              home: const FirebaseInitWrapper(),
            );
          },
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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ফায়ারস্টোর থেকে ইউজারের ডেটা সরাসরি খুঁজে বের করা
        final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['sessionToken'] != null && data['phone'] != null) {
            final phone = data['phone'] as String;
            final token = data['sessionToken'] as String;
            return MainDashboardScreen(myPhone: phone, currentSessionToken: token);
          }
        }
      }
    } catch (_) {}
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
      appBar: AppBar(
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
              Text(tr('welcome'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Column(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [const Color(0xFF1E88E5).withOpacity(0.3), const Color(0xFF42A5F5).withOpacity(0.1)]),
                    ),
                    child: const Icon(Icons.forum_rounded, size: 85, color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(height: 28),
                  Text(tr('terms_desc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
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
                  const Text('from VibeNet Team', style: TextStyle(fontSize: 12)),
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
      final newSessionToken = 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

      final existingDoc = await FirebaseFirestore.instance.collection('users').doc(_fullPhoneNumber).get();
      
      if (existingDoc.exists && existingDoc.data() != null) {
        await FirebaseFirestore.instance.collection('users').doc(_fullPhoneNumber).update({
          'activeSessionToken': newSessionToken,
          'sessionToken': newSessionToken,
        });

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
      appBar: AppBar(
        title: Text(tr('enter_phone'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(tr('verify_desc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
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
              ElevatedButton(onPressed: _isLoading ? null : _verifyOtp, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white), child: Text(tr('verify'))),
            ] else ...[
              ElevatedButton(onPressed: _isLoading ? null : _sendOtp, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white), child: Text(tr('next'))),
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
  String? _photo;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _photo = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Photo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _photo != null ? FileImage(File(_photo!)) as ImageProvider : null,
              child: _photo == null ? const Icon(Icons.person, size: 60) : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ProfileNameStepScreen(myPhone: widget.myPhone, photoUrl: _photo, sessionToken: widget.sessionToken))),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
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
            ElevatedButton(onPressed: _finish, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white), child: const Text('Finish')),
          ],
        ),
      ),
    );
  }
}

class ContactsScreen extends StatelessWidget {
  final String myPhone;
  const ContactsScreen({super.key, required this.myPhone});

  Future<void> _fetchAndShowContacts(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('All Phone Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final phoneNum = contact.phones.isNotEmpty ? contact.phones.first.number : 'No number';
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(contact.displayName),
                      subtitle: Text(phoneNum),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat, color: Color(0xFF1E88E5)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => ConversationScreen(
                                myPhone: myPhone,
                                receiverPhone: phoneNum,
                                receiverName: contact.displayName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF1E88E5),
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () => _fetchAndShowContacts(context),
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
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').doc(widget.myPhone).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        final activeToken = doc.data()!['activeSessionToken'] as String?;
        if (activeToken != null && activeToken != widget.currentSessionToken) {
          FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()), (r) => false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out due to login on another device')));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF1E88E5),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      _isSearching
                          ? SizedBox(
                              width: 180,
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                onChanged: (v) => setState(() => _searchQuery = v),
                                decoration: const InputDecoration(hintText: 'Search by name/id...', border: InputBorder.none),
                              ),
                            )
                          : const Text('VibeNet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close : Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchQuery = '';
                              _searchController.clear();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
                          SizedBox(width: 8),
                          Text('28°C', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text('Kolkata, West Bengal', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  Icon(Icons.location_on, color: Colors.white54, size: 28),
                ],
              ),
            ),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildStatusItem('My Status', Icons.add),
                  _buildStatusItem('Rahul', null),
                  _buildStatusItem('Priya', null),
                  _buildStatusItem('Anita', null),
                  _buildStatusItem('Vikram', null),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _currentIndex == 0
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final users = snapshot.data!.docs.where((d) {
                          if (d.id == widget.myPhone) return false;
                          if (_searchQuery.isEmpty) return true;
                          final data = d.data() as Map<String, dynamic>;
                          final name = (data['name'] ?? '').toString().toLowerCase();
                          final phone = (data['phone'] ?? '').toString().toLowerCase();
                          return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
                        }).toList();

                        if (users.isEmpty) {
                          return const Center(child: Text('No registered contacts found'));
                        }

                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final data = users[index].data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'User';
                            final phone = data['phone'] ?? '';
                            final photo = data['photoUrl'] ?? '';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: photo.isNotEmpty ? (photo.startsWith('http') ? NetworkImage(photo) : FileImage(File(photo)) as ImageProvider) : null,
                                child: photo.isEmpty ? const Icon(Icons.person) : null,
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(maskPhoneNumber(phone)),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => ConversationScreen(myPhone: widget.myPhone, receiverPhone: phone, receiverName: name)));
                              },
                            );
                          },
                        );
                      },
                    )
                  : (_currentIndex == 1
                      ? const Center(child: Text('Facebook Style News Feed', style: TextStyle(fontSize: 16)))
                      : (_currentIndex == 2
                          ? const Center(child: Text('Create Post Section', style: TextStyle(fontSize: 16)))
                          : (_currentIndex == 3
                              ? const Center(child: Text('Reels & Videos', style: TextStyle(fontSize: 16)))
                              : ProfileScreen(myPhone: widget.myPhone)))),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? ContactsScreen(myPhone: widget.myPhone) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1E88E5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box, size: 30), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String name, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1E88E5), width: 2),
            ),
            child: CircleAvatar(
              radius: 24,
              child: Icon(icon ?? Icons.person, size: icon != null ? 20 : 24),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String myPhone;
  const ProfileScreen({super.key, required this.myPhone});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _newPhoto;
  String _profilePhotoPrivacy = 'everyone';
  String _lastSeenPrivacy = 'everyone';

  Future<void> _updateProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _newPhoto = pickedFile.path);
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
        'photoUrl': _newPhoto,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated successfully!')));
      }
    }
  }

  void _showPrivacyDialog(String title, String currentVal, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'everyone',
              groupValue: currentVal,
              onChanged: (v) {
                onSelected(v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('My contacts'),
              value: 'contacts',
              groupValue: currentVal,
              onChanged: (v) {
                onSelected(v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Only me (Nobody)'),
              value: 'nobody',
              groupValue: currentVal,
              onChanged: (v) {
                onSelected(v!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.myPhone).snapshots(),
        builder: (context, snapshot) {
          String photoUrl = '';
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            photoUrl = data?['photoUrl'] ?? '';
            _profilePhotoPrivacy = data?['photoPrivacy'] ?? 'everyone';
            _lastSeenPrivacy = data?['lastSeenPrivacy'] ?? 'everyone';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _updateProfilePhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (_newPhoto != null && _newPhoto!.isNotEmpty)
                            ? FileImage(File(_newPhoto!)) as ImageProvider
                            : (photoUrl.isNotEmpty
                                ? (photoUrl.startsWith('http') ? NetworkImage(photoUrl) : FileImage(File(photoUrl)) as ImageProvider)
                                : null),
                        child: (_newPhoto == null && photoUrl.isEmpty) ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF1E88E5),
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  maskPhoneNumber(widget.myPhone),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E88E5), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet, color: Color(0xFF1E88E5)),
                          SizedBox(width: 8),
                          Text('VibeNet UPI & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('Scan QR'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text('Pay UPI'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Privacy Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.visibility, color: Color(0xFF1E88E5)),
                  title: const Text('Last Seen'),
                  subtitle: Text(_lastSeenPrivacy.toUpperCase()),
                  onTap: () {
                    _showPrivacyDialog('Last Seen Privacy', _lastSeenPrivacy, (val) async {
                      setState(() => _lastSeenPrivacy = val);
                      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'lastSeenPrivacy': val});
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle, color: Color(0xFF1E88E5)),
                  title: const Text('Profile Photo Privacy'),
                  subtitle: Text(_profilePhotoPrivacy.toUpperCase()),
                  onTap: () {
                    _showPrivacyDialog('Profile Photo Privacy', _profilePhotoPrivacy, (val) async {
                      setState(() => _profilePhotoPrivacy = val);
                      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'photoPrivacy': val});
                    });
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF1E88E5)),
                  title: const Text('Change Language / ভাষা পরিবর্তন'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showLanguageSelector(context),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6, color: Color(0xFF1E88E5)),
                  title: const Text('Dark / Light Mode'),
                  trailing: Switch(
                    value: appThemeMode.value == ThemeMode.dark,
                    onChanged: (isDark) {
                      appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()),
                      (r) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
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

  void _deleteMessage(String docId, bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Delete Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text('Delete for me'),
              onTap: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance.collection('chats').doc(docId).delete();
              },
            ),
            if (isMe) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete for everyone', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await FirebaseFirestore.instance.collection('chats').doc(docId).delete();
                },
              ),
            ],
          ],
        ),
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
            Text(maskPhoneNumber(widget.receiverPhone), style: const TextStyle(fontSize: 12)),
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
                      onLongPress: () => _deleteMessage(doc.id, isMe),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF1E88E5) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  data['text'] ?? '',
                                  style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (isMe)
                                Icon(
                                  isSeen ? Icons.done_all : Icons.done,
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
