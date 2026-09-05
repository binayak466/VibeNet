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
import 'package:local_auth/local_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'account_settings_screen.dart';

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
    'verify_desc': 'VibeNet will need to verify your phone number via SMS.',
    'phone_hint': 'phone number',
    'next': 'Send OTP',
    'verify': 'Verify & Login',
    'enter_code': 'Enter 6-digit OTP received via SMS',
    'invalid_phone': 'Please enter a valid phone number with country code',
    'wrong_otp': 'Please enter a valid 6-digit OTP',
  },
  'bn': {
    'welcome': 'VibeNet-এ স্বাগতম',
    'terms_desc': 'চ্যাট, সোশ্যাল ফিড এবং পেমেন্ট একসাথে একটি অ্যাপে।',
    'agree_continue': 'সম্মতি দিন ও এগিয়ে যান',
    'enter_phone': 'আপনার মোবাইল নম্বর দিন',
    'verify_desc': 'VibeNet এসএমএসের মাধ্যমে আপনার নম্বর যাচাই করবে।',
    'phone_hint': 'ফোন নম্বর',
    'next': 'ওটিপি পাঠান',
    'verify': 'যাচাই করুন',
    'enter_code': 'এসএমএসে আসা ৬ সংখ্যার ওটিপি দিন',
    'invalid_phone': 'সঠিক মোবাইল নম্বর দিন',
    'wrong_otp': 'সঠিক ৬ সংখ্যার ওটিপি দিন',
  },
  'hi': {
    'welcome': 'VibeNet में आपका स्वागत है',
    'terms_desc': 'चैट, सोशल फीड और भुगतान एक ही ऐप में।',
    'agree_continue': 'स्वीकार करें और जारी रखें',
    'enter_phone': 'अपना फ़ोन नंबर दर्ज करें',
    'verify_desc': 'VibeNet एसएमएस के माध्यम से आपके नंबर को सत्यापित करेगा।',
    'phone_hint': 'फ़ोन नंबर',
    'next': 'OTP भेजें',
    'verify': 'सत्यापित करें',
    'enter_code': 'SMS में प्राप्त 6 अंकों का OTP दर्ज करें',
    'invalid_phone': 'कृपया सही फ़ोन नंबर दर्ज करें',
    'wrong_otp': 'कृपया सही 6 अंकों का OTP दर्ज करें',
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
        final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['phone'] != null) {
            final phone = data['phone'] as String;
            final token = data['sessionToken'] as String? ?? '';
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
  String _verificationId = '';

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

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('invalid_phone'))));
      return;
    }
    setState(() => _isLoading = true);
    _fullPhoneNumber = '$_selectedCountryCode$phone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _navigateToNext(_fullPhoneNumber);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent successfully via SMS!')));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    }
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('wrong_otp'))));
      return;
    }
    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _navigateToNext(_fullPhoneNumber);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP! Please try again.')));
    }
  }

  void _navigateToNext(String phone) async {
    final newSessionToken = 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    final existingDoc = await FirebaseFirestore.instance.collection('users').doc(phone).get();
    
    if (mounted) {
      if (existingDoc.exists && existingDoc.data() != null) {
        await FirebaseFirestore.instance.collection('users').doc(phone).update({
          'activeSessionToken': newSessionToken,
          'sessionToken': newSessionToken,
          'lastActive': FieldValue.serverTimestamp(),
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainDashboardScreen(myPhone: phone, currentSessionToken: newSessionToken)),
          (r) => false,
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePhotoStepScreen(myPhone: phone, sessionToken: newSessionToken)));
      }
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
    final data = {
      'phone': widget.myPhone,
      'name': name,
      'photoUrl': widget.photoUrl ?? '',
      'sessionToken': widget.sessionToken,
      'activeSessionToken': widget.sessionToken,
      'lastActive': FieldValue.serverTimestamp(),
      'biometricEnabled': false,
      'isDarkMode': true,
    };
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

class ContactsScreen extends StatefulWidget {
  final String myPhone;
  const ContactsScreen({super.key, required this.myPhone});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  void _showCreateGroupDialog(BuildContext context) {
    final TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Group'),
        content: TextField(
          controller: groupNameController,
          decoration: const InputDecoration(hintText: 'Enter group name...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
            onPressed: () async {
              final groupName = groupNameController.text.trim();
              if (groupName.isEmpty) return;

              await FirebaseFirestore.instance.collection('groups').add({
                'groupName': groupName,
                'createdBy': widget.myPhone,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group "$groupName" created successfully!')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndShowContacts(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      final Set<String> registeredPhones = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['phone'] != null) {
          registeredPhones.add(data['phone'].toString().replaceAll(RegExp(r'\s+'), ''));
        }
      }

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal) {
              String searchQuery = '';
              return StatefulBuilder(
                builder: (context, setStateInner) {
                  return Column(
                    children: [
                      const Text('All Phone Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) {
                          setStateInner(() {
                            searchQuery = v.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final filteredContacts = contacts.where((c) {
                              final name = c.displayName.toLowerCase();
                              final phone = c.phones.isNotEmpty ? c.phones.first.number.toLowerCase() : '';
                              return name.contains(searchQuery) || phone.contains(searchQuery);
                            }).toList();

                            if (filteredContacts.isEmpty) {
                              return const Center(child: Text('No contacts found'));
                            }

                            return ListView.builder(
                              itemCount: filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = filteredContacts[index];
                                final rawPhone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                                final cleanPhone = rawPhone.replaceAll(RegExp(r'\s+'), '');
                                
                                bool isRegistered = false;
                                for (var regPhone in registeredPhones) {
                                  if (cleanPhone.endsWith(regPhone) || regPhone.endsWith(cleanPhone)) {
                                    isRegistered = true;
                                    break;
                                  }
                                }

                                return ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.person)),
                                  title: Text(contact.displayName),
                                  subtitle: Text(rawPhone),
                                  trailing: isRegistered
                                      ? IconButton(
                                          icon: const Icon(Icons.chat, color: Color(0xFF1E88E5)),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (c) => ConversationScreen(
                                                  myPhone: widget.myPhone,
                                                  receiverPhone: rawPhone,
                                                  receiverName: contact.displayName,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Invitation sent to ${contact.displayName}')),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                            foregroundColor: const Color(0xFF1E88E5),
                                          ),
                                          child: const Text('Invite', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
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
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E88E5),
                    child: Icon(Icons.group_add, color: Colors.white),
                  ),
                  title: const Text('New Group', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Create a new chat group'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showCreateGroupDialog(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E88E5),
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text('New Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Add a new contact to VibeNet'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _fetchAndShowContacts(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
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

class _MainDashboardScreenState extends State<MainDashboardScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _allSongs = [
    {'title': 'Kesariya - Brahmāstra (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Tum Hi Ho - Aashiqui 2 (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Raataan Lambiyan - Shershaah (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
    {'title': 'Apna Bana Le - Bhediya (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'},
    {'title': 'Levitating - Dua Lipa (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'},
    {'title': 'Perfect - Ed Sheeran (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3'},
    {'title': 'Believer - Imagine Dragons (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3'},
    {'title': 'Senorita - Shawn Mendes (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'},
    {'title': 'Dil Diyan Gallan - Tiger Zinda Hai (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3'},
    {'title': 'Apna Har Din - Golmaal (0:30)', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestAppPermissionsOnStartup();
    _updateActiveStatus();
    _checkBiometricOnStartup();
    _loadUserThemePreference();

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

  void _loadUserThemePreference() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
      if (doc.exists && doc.data() != null) {
        final bool isDark = doc.data()!['isDarkMode'] ?? true;
        setState(() {
          appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
        });
      }
    } catch (_) {}
  }

  void _requestAppPermissionsOnStartup() async {
    await [
      Permission.contacts,
      Permission.storage,
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  void _checkBiometricOnStartup() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
      if (doc.exists && doc.data() != null) {
        final bool isEnabled = doc.data()!['biometricEnabled'] ?? false;
        if (isEnabled) {
          bool authenticated = await _localAuth.authenticate(
            localizedReason: 'Please authenticate to unlock VibeNet',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
            ),
          );
          if (!authenticated) {
            Future.delayed(const Duration(seconds: 1), () => _checkBiometricOnStartup());
          }
        }
      }
    } catch (e) {
      print("Biometric Error: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateActiveStatus();
      _checkBiometricOnStartup();
    }
  }

  void _updateActiveStatus() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _uploadStatus() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => StatefulBuilder(
          builder: (context, setStateModal) {
            String songSearchQuery = '';
            final searchedSongs = _allSongs.where((song) => song['title']!.toLowerCase().contains(songSearchQuery.toLowerCase())).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Search & Select Song (30s)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setStateModal(() => songSearchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search any song...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchedSongs.length,
                      itemBuilder: (context, index) {
                        final song = searchedSongs[index];
                        return ListTile(
                          leading: const Icon(Icons.music_note, color: Color(0xFF1E88E5)),
                          title: Text(song['title']!, style: const TextStyle(color: Colors.white)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await FirebaseFirestore.instance.collection('statuses').add({
                              'phone': widget.myPhone,
                              'imagePath': pickedFile.path,
                              'music': song['title']!,
                              'musicUrl': song['url']!,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status uploaded with music!')));
                            }
                          },
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close, color: Colors.red),
                    title: const Text('Upload Without Music', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await FirebaseFirestore.instance.collection('statuses').add({
                        'phone': widget.myPhone,
                        'imagePath': pickedFile.path,
                        'music': '',
                        'musicUrl': '',
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status uploaded successfully!')));
                      }
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

  void _showMyStatusesList(List<QueryDocumentSnapshot<Map<String, dynamic>>> myStatuses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            const Text('My Statuses', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: myStatuses.length,
                itemBuilder: (context, index) {
                  final data = myStatuses[index].data();
                  final imagePath = data['imagePath'] ?? '';
                  final music = data['music'] ?? '';
                  final musicUrl = data['musicUrl'] ?? '';
                  final docId = myStatuses[index].id;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imagePath.startsWith('http')
                            ? Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover)
                            : Image.file(File(imagePath), width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(music.isNotEmpty ? music : 'No Music', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text('Tap to view', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await FirebaseFirestore.instance.collection('statuses').doc(docId).delete();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status deleted successfully')));
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _viewSingleStatus('My Status', imagePath, music, musicUrl);
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
  }

  void _viewSingleStatus(String name, String? imagePath, String? music, String? musicUrl) async {
    if (musicUrl != null && musicUrl.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(musicUrl));
      } catch (_) {}
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async {
          await _audioPlayer.stop();
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              imagePath != null && imagePath.isNotEmpty
                  ? (imagePath.startsWith('http') ? Image.network(imagePath, fit: BoxFit.contain) : Image.file(File(imagePath), fit: BoxFit.contain))
                  : const Center(child: Text('No Status Available', style: TextStyle(color: Colors.white))),
              
              Positioned(
                top: 15,
                left: 10,
                right: 10,
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ),

              Positioned(
                top: 35,
                left: 20,
                child: Row(
                  children: [
                    const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                    const SizedBox(width: 10),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (music != null && music.isNotEmpty)
                Positioned(
                  bottom: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.greenAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(music, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 35,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () async {
                    await _audioPlayer.stop();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _audioPlayer.stop();
    });
  }

  void _showGmailBackupDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Google Drive Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your Gmail account to sync and backup your chats & media securely.'),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Gmail Address',
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@gmail.com')) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid Gmail address')));
                return;
              }
              await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
                'backupGmail': email,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup successful with $email!')));
              }
            },
            child: const Text('Backup Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateActiveStatus();
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
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(widget.myPhone).snapshots(),
                        builder: (context, snapshot) {
                          String photoUrl = '';
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data = snapshot.data!.data() as Map<String, dynamic>?;
                            photoUrl = data?['photoUrl'] ?? '';
                          }
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF1E88E5),
                            backgroundImage: photoUrl.isNotEmpty
                                ? (photoUrl.startsWith('http') ? NetworkImage(photoUrl) : FileImage(File(photoUrl)) as ImageProvider)
                                : null,
                            child: photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                          );
                        },
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
                        icon: const Icon(Icons.cloud_upload, color: Color(0xFF1E88E5)),
                        tooltip: 'Gmail Backup',
                        onPressed: _showGmailBackupDialog,
                      ),
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
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'logout') {
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()),
                              );
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('statuses').snapshots(),
                builder: (context, snapshot) {
                  final statuses = snapshot.hasData ? snapshot.data!.docs : [];
                  final myStatuses = statuses.where((doc) => (doc.data() as Map<String, dynamic>)['phone'] == widget.myPhone).toList()
                      .cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
                  
                  String? latestMyImagePath;
                  if (myStatuses.isNotEmpty) {
                    latestMyImagePath = myStatuses.last.data()['imagePath'];
                  }
                  
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      GestureDetector(
                        onTap: _uploadStatus,
                        child: _buildStatusItem('Add Status', Icons.add, null),
                      ),
                      if (myStatuses.isNotEmpty)
                        GestureDetector(
                          onTap: () => _showMyStatusesList(myStatuses),
                          child: _buildStatusItem('My Status', null, latestMyImagePath),
                        ),
                      GestureDetector(
                        onTap: () => _viewSingleStatus('Rahul', null, null, null),
                        child: _buildStatusItem('Rahul', null, null),
                      ),
                      GestureDetector(
                        onTap: () => _viewSingleStatus('Priya', null, null, null),
                        child: _buildStatusItem('Priya', null, null),
                      ),
                      GestureDetector(
                        onTap: () => _viewSingleStatus('Anita', null, null, null),
                        child: _buildStatusItem('Anita', null, null),
                      ),
                    ],
                  );
                },
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _currentIndex == 0
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
                      builder: (context, groupSnapshot) {
                        final groups = groupSnapshot.hasData ? groupSnapshot.data!.docs : [];

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').snapshots(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData && !groupSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                            
                            final users = userSnapshot.hasData ? userSnapshot.data!.docs.where((d) {
                              if (d.id == widget.myPhone) return false;
                              if (_searchQuery.isEmpty) return true;
                              final data = d.data() as Map<String, dynamic>;
                              final name = (data['name'] ?? '').toString().toLowerCase();
                              final phone = (data['phone'] ?? '').toString().toLowerCase();
                              return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
                            }).toList() : [];

                            final filteredGroups = groups.where((g) {
                              if (_searchQuery.isEmpty) return true;
                              final data = g.data() as Map<String, dynamic>;
                              final groupName = (data['groupName'] ?? '').toString().toLowerCase();
                              return groupName.contains(_searchQuery.toLowerCase());
                            }).toList();

                            return ListView(
                              children: [
                                if (filteredGroups.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text('Groups', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                  ...filteredGroups.map((gDoc) {
                                    final gData = gDoc.data() as Map<String, dynamic>;
                                    final gName = gData['groupName'] ?? 'Group';
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFF1E88E5),
                                        child: Icon(Icons.group, color: Colors.white),
                                      ),
                                      title: Text(gName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('Tap to open group chat'),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) => GroupConversationScreen(
                                              myPhone: widget.myPhone,
                                              groupId: gDoc.id,
                                              groupName: gName,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  const Divider(),
                                ],
                                if (users.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text('Direct Chats', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                  ...users.map((userDoc) {
                                    final data = userDoc.data() as Map<String, dynamic>;
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
                                  }),
                                ] else if (filteredGroups.isEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(child: Text('No registered contacts or groups found')),
                                  ),
                                ]
                              ],
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

  Widget _buildStatusItem(String name, IconData? icon, String? imagePath) {
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
              backgroundImage: imagePath != null && imagePath.isNotEmpty ? FileImage(File(imagePath)) as ImageProvider : null,
              child: imagePath == null ? Icon(icon ?? Icons.person, size: icon != null ? 20 : 24) : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class GroupConversationScreen extends StatefulWidget {
  final String myPhone;
  final String groupId;
  final String groupName;
  const GroupConversationScreen({super.key, required this.myPhone, required this.groupId, required this.groupName});

  @override
  State<GroupConversationScreen> createState() => _GroupConversationScreenState();
}

class _GroupConversationScreenState extends State<GroupConversationScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  void _sendGroupMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('messages').add({
      'sender': widget.myPhone,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showGroupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.groupName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF1E88E5)),
              title: const Text('Group Admin'),
              subtitle: const Text('You are the creator & admin'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are the Group Admin')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Color(0xFF1E88E5)),
              title: const Text('Add Participants'),
              subtitle: const Text('Add members to group'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Participant added successfully!')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.orange),
              title: const Text('Exit Group'),
              onTap: () async {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have exited the group')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Group', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group deleted successfully')));
                }
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
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.group, size: 20, color: Color(0xFF1E88E5)),
            ),
            const SizedBox(width: 10),
            Text(widget.groupName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showGroupOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No messages in this group yet. Say hello!'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['sender'] == widget.myPhone;
                    final senderPhone = data['sender'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF1E88E5) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                maskPhoneNumber(senderPhone),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                            if (!isMe) const SizedBox(height: 2),
                            Text(
                              data['text'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Type group message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1E88E5),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendGroupMessage,
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

  @override
  void initState() {
    super.initState();
    _setMyActiveStatus(true);
  }

  @override
  void dispose() {
    _setMyActiveStatus(false);
    super.dispose();
  }

  void _setMyActiveStatus(bool isOnline) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

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

  void _sendMediaMessage(String mediaType, String content) async {
    await FirebaseFirestore.instance.collection('chats').add({
      'sender': widget.myPhone,
      'receiver': widget.receiverPhone,
      'text': '[$mediaType] $content',
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

  Widget _buildAttachmentItem(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(widget.receiverPhone).snapshots(),
                builder: (context, snapshot) {
                  String statusText = maskPhoneNumber(widget.receiverPhone);
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final lastSeenPrivacy = data?['lastSeenPrivacy'] ?? 'everyone';
                    
                    if (lastSeenPrivacy != 'nobody') {
                      final bool isExplicitlyOnline = data?['isOnline'] ?? false;
                      final lastActive = data?['lastActive'];

                      if (isExplicitlyOnline && lastActive != null && lastActive is Timestamp) {
                        final DateTime activeTime = lastActive.toDate();
                        final difference = DateTime.now().difference(activeTime);
                        
                        if (difference.inSeconds < 30) {
                          statusText = 'Online';
                        } else {
                          int hour = activeTime.hour;
                          String period = hour >= 12 ? 'PM' : 'AM';
                          hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                          String minute = activeTime.minute.toString().padLeft(2, '0');
                          statusText = 'Last seen at $hour:$minute $period';
                        }
                      } else if (lastActive != null && lastActive is Timestamp) {
                        final DateTime activeTime = lastActive.toDate();
                        int hour = activeTime.hour;
                        String period = hour >= 12 ? 'PM' : 'AM';
                        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                        String minute = activeTime.minute.toString().padLeft(2, '0');
                        statusText = 'Last seen at $hour:$minute $period';
                      } else {
                        statusText = 'Offline';
                      }
                    } else {
                      statusText = 'Offline';
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.receiverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(statusText, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Call',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => CallScreen(
                    receiverName: widget.receiverName,
                    receiverPhone: widget.receiverPhone,
                    isVideoCall: true,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Voice Call',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => CallScreen(
                    receiverName: widget.receiverName,
                    receiverPhone: widget.receiverPhone,
                    isVideoCall: false,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$value selected')));
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'New group', child: Text('New group')),
              const PopupMenuItem(value: 'View contact', child: Text('View contact')),
              const PopupMenuItem(value: 'Search', child: Text('Search')),
              const PopupMenuItem(value: 'Media, links, and docs', child: Text('Media, links, and docs')),
              const PopupMenuItem(value: 'Mute notifications', child: Text('Mute notifications')),
              const PopupMenuItem(value: 'Disappearing messages', child: Text('Disappearing messages')),
              const PopupMenuItem(value: 'Chat theme', child: Text('Chat theme')),
              const PopupMenuItem(value: 'More', child: Text('More')),
            ],
          ),
        ],
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
                            color: isMe ? const Color(0xFF1E88E5) : (isDark ? const Color(0xFF1F2C34) : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: data['text'].toString().startsWith('[Gallery Image]') || data['text'].toString().startsWith('[Camera Photo]') || data['text'].toString().startsWith('[Document]')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(data['text'].toString().split('] ').last),
                                          height: 150,
                                          width: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Text(data['text'], style: TextStyle(fontSize: 14, color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87))),
                                        ),
                                      )
                                    : (data['text'].toString().startsWith('[')
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                data['text'].toString().contains('Location')
                                                    ? Icons.location_on
                                                    : (data['text'].toString().contains('Contact')
                                                        ? Icons.person
                                                        : Icons.attachment),
                                                color: isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  data['text'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            data['text'] ?? '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                            ),
                                          )),
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
          Container(
            padding: const EdgeInsets.all(8.0),
            color: isDark ? const Color(0xFF111B21) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A3942) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined, color: isDark ? Colors.grey[400] : Colors.grey),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: isDark ? const Color(0xFF1F2C34) : Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (ctx) => Container(
                                padding: const EdgeInsets.all(16),
                                height: 300,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'WhatsApp Style Emojis',
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: GridView.count(
                                        crossAxisCount: 6,
                                        children: [
                                          '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', '😉', '😊',
                                          '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪',
                                          '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏',
                                          '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕',
                                          '🤢', '🤮', '🤧', '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '😎', '🤓',
                                          '🧐', '😕', '😟', '🙁', '😮', '😯', '😲', '😳', '🥺', '😦', '😧', '👍',
                                          '👎', '👏', '🙌', '👐', '🤲', '🤝', '🙏', '✍️', '💅', '🤳', '💪', '❤️',
                                          '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕', '🔥',
                                          '⭐', '🌟', '✨', '⚡', '💥', '🎉', '🎊', '🎈', '🎁', '🏆', '⚽', '🏀'
                                        ].map((emoji) => InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _msgCtrl.text += emoji;
                                                });
                                                Navigator.pop(ctx);
                                              },
                                              child: Center(
                                                child: Text(emoji, style: const TextStyle(fontSize: 28)),
                                              ),
                                            ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: isDark ? const Color(0xFF1F2C34) : Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (ctx) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildAttachmentItem(Icons.photo_library, Colors.blue, 'Gallery', () async {
                                          Navigator.pop(ctx);
                                          final picker = ImagePicker();
                                          final image = await picker.pickImage(source: ImageSource.gallery);
                                          if (image != null) {
                                            _sendMediaMessage('Gallery Image', image.path);
                                          }
                                        }),
                                        _buildAttachmentItem(Icons.location_on, Colors.green, 'Location', () {
                                          Navigator.pop(ctx);
                                          _sendMediaMessage('Location', 'Live GPS Location Shared');
                                        }),
                                        _buildAttachmentItem(Icons.person, Colors.lightBlueAccent, 'Contact', () {
                                          Navigator.pop(ctx);
                                          _sendMediaMessage('Contact', 'Shared a Contact');
                                        }),
                                        _buildAttachmentItem(Icons.insert_drive_file, Colors.purpleAccent, 'Document', () async {
                                          Navigator.pop(ctx);
                                          final picker = ImagePicker();
                                          final docFile = await picker.pickImage(source: ImageSource.gallery);
                                          if (docFile != null) {
                                            _sendMediaMessage('Document', docFile.path);
                                          }
                                        }),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildAttachmentItem(Icons.poll, Colors.amber, 'Poll', () {
                                          Navigator.pop(ctx);
                                          _sendMediaMessage('Poll', 'Created a new Poll');
                                        }),
                                        _buildAttachmentItem(Icons.currency_rupee, Colors.teal, 'Payment', () {
                                          Navigator.pop(ctx);
                                          _sendMediaMessage('Payment', '₹500.00 Sent via VibeNet UPI');
                                        }),
                                        _buildAttachmentItem(Icons.event, Colors.pinkAccent, 'Event', () {
                                          Navigator.pop(ctx);
                                          _sendMediaMessage('Event', 'Scheduled Meetup Event');
                                        }),
                                        _buildAttachmentItem(Icons.auto_awesome, Colors.blueAccent, 'AI images', () {
                                          Navigator.pop(ctx);
                                          _sendMediaMessage('AI Image', 'Generated AI Artwork');
                                        }),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.currency_rupee, color: isDark ? Colors.grey[400] : Colors.grey),
                          onPressed: () {
                            _sendMediaMessage('Payment', '₹100.00 Quick UPI Transfer');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt_outlined, color: isDark ? Colors.grey[400] : Colors.grey),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final photo = await picker.pickImage(source: ImageSource.camera);
                            if (photo != null) {
                              _sendMediaMessage('Camera Photo', photo.path);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1E88E5),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice Note Recorded & Sent')));
                      _sendMediaMessage('Voice Note', 'Audio Message (0:15)');
                    },
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

class UserProfileScreen extends StatelessWidget {
  final String receiverPhone;
  final String receiverName;
  const UserProfileScreen({super.key, required this.receiverPhone, required this.receiverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverName)),
      body: Center(child: Text(receiverPhone)),
    );
  }
}

class CallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverPhone;
  final bool isVideoCall;
  const CallScreen({super.key, required this.receiverName, required this.receiverPhone, required this.isVideoCall});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.lock, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                  Column(
                    children: [
                      Text(
                        widget.receiverName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Ringing...',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 90,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 90, color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2C34),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_down, color: Colors.white),
                              onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                            ),
                            const Text('Speaker', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.videocam, color: Colors.white),
                              onPressed: () {},
                            ),
                            const Text('Video', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                              onPressed: () => setState(() => _isMuted = !_isMuted),
                            ),
                            const Text('Mute', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.white),
                              onPressed: () {},
                            ),
                            const Text('More', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.screen_share, color: Colors.white),
                              onPressed: () {},
                            ),
                            const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  final String myPhone;
  const PrivacySettingsScreen({super.key, required this.myPhone});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _biometricEnabled = false;
  String _profilePhotoPrivacy = 'everyone';
  String _lastSeenPrivacy = 'everyone';

  @override
  void initState() {
    super.initState();
    _loadPrivacyData();
  }

  void _loadPrivacyData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      setState(() {
        _biometricEnabled = data['biometricEnabled'] ?? false;
        _profilePhotoPrivacy = data['profilePhotoPrivacy'] ?? 'everyone';
        _lastSeenPrivacy = data['lastSeenPrivacy'] ?? 'everyone';
      });
    }
  }

  void _updateBiometric(bool val) async {
    setState(() => _biometricEnabled = val);
    await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'biometricEnabled': val});
  }

  void _updateProfilePhotoPrivacy(String val) async {
    setState(() => _profilePhotoPrivacy = val);
    await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'profilePhotoPrivacy': val});
  }

  void _updateLastSeenPrivacy(String val) async {
    setState(() => _lastSeenPrivacy = val);
    await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({'lastSeenPrivacy': val});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: Color(0xFF1E88E5)),
            title: const Text('Biometric App Lock', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Unlock VibeNet using fingerprint / face ID'),
            value: _biometricEnabled,
            activeColor: const Color(0xFF1E88E5),
            onChanged: _updateBiometric,
          ),
          const Divider(),
          ListTile(
            title: const Text('Profile Photo Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Current setting: $_profilePhotoPrivacy'),
            trailing: DropdownButton<String>(
              value: _profilePhotoPrivacy,
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: [
                DropdownMenuItem(value: 'everyone', child: Text('Everyone', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 'contacts', child: Text('My Contacts', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 'nobody', child: Text('Only Me', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
              ],
              onChanged: (val) {
                if (val != null) _updateProfilePhotoPrivacy(val);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Last Seen Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Current setting: $_lastSeenPrivacy'),
            trailing: DropdownButton<String>(
              value: _lastSeenPrivacy,
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: [
                DropdownMenuItem(value: 'everyone', child: Text('Everyone', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 'contacts', child: Text('My Contacts', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                DropdownMenuItem(value: 'nobody', child: Text('Only Me', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
              ],
              onChanged: (val) {
                if (val != null) _updateLastSeenPrivacy(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QrCodeScreen extends StatelessWidget {
  final String myPhone;
  const QrCodeScreen({super.key, required this.myPhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: AppBar(
        title: const Text('QR code', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0B141A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('MY CODE', style: TextStyle(color: Color(0xFF00A884), fontWeight: FontWeight.bold)),
              SizedBox(width: 40),
              Text('SCAN CODE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111B21),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF00A884),
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text('Binayak', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('VibeNet contact', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 200, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Your QR code is private. If you share it with someone, they can scan it with their camera to add you as a contact.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsSettingsScreen extends StatefulWidget {
  final String myPhone;
  const NotificationsSettingsScreen({super.key, required this.myPhone});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _conversationTones = true;
  bool _reminders = true;
  bool _msgHighPriority = true;
  bool _msgReaction = true;
  bool _groupHighPriority = true;
  bool _groupReaction = true;
  bool _statusHighPriority = true;
  bool _statusReactions = true;

  String _msgTone = 'Default (Encounter)';
  String _groupTone = 'Default (Encounter)';
  String _callRingtone = 'Default (Lawn Lifestyle)';
  String _statusTone = 'Default (Encounter)';

  void _showTonePicker(String title, String currentTone, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Default (Encounter)', 'Chimes', 'Bell', 'Ripple', 'Silent'].map((tone) {
            return ListTile(
              title: Text(tone),
              trailing: currentTone == tone ? const Icon(Icons.check, color: Color(0xFF1E88E5)) : null,
              onTap: () {
                onSelected(tone);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title updated to $tone')));
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
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          SwitchListTile(
            title: const Text('Conversation tones', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Play sounds for incoming and outgoing messages.'),
            value: _conversationTones,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) {
              setState(() => _conversationTones = val);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? 'Conversation tones enabled' : 'Conversation tones disabled')));
            },
          ),
          SwitchListTile(
            title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Get occasional reminders about messages, calls or status updates you haven’t seen'),
            value: _reminders,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) {
              setState(() => _reminders = val);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? 'Reminders enabled' : 'Reminders disabled')));
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text('Messages', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ListTile(
            title: const Text('Notification tone'),
            subtitle: Text(_msgTone),
            onTap: () => _showTonePicker('Message Notification Tone', _msgTone, (val) => setState(() => _msgTone = val)),
          ),
          ListTile(
            title: const Text('Vibrate'),
            subtitle: const Text('Default'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vibration pattern set to Default'))),
          ),
          ListTile(
            title: const Text('Light'),
            subtitle: const Text('White'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification LED light set to White'))),
          ),
          SwitchListTile(
            title: const Text('Use high priority notifications'),
            subtitle: const Text('Show previews of notifications at the top of the screen'),
            value: _msgHighPriority,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) => setState(() => _msgHighPriority = val),
          ),
          SwitchListTile(
            title: const Text('Reaction notifications'),
            subtitle: const Text('Show notifications for reactions to messages you send'),
            value: _msgReaction,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) => setState(() => _msgReaction = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text('Groups', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ListTile(
            title: const Text('Notification tone'),
            subtitle: Text(_groupTone),
            onTap: () => _showTonePicker('Group Notification Tone', _groupTone, (val) => setState(() => _groupTone = val)),
          ),
          ListTile(
            title: const Text('Vibrate'),
            subtitle: const Text('Default'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group vibration set to Default'))),
          ),
          ListTile(
            title: const Text('Light'),
            subtitle: const Text('White'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group LED light set to White'))),
          ),
          SwitchListTile(
            title: const Text('Use high priority notifications'),
            subtitle: const Text('Show previews of notifications at the top of the screen'),
            value: _groupHighPriority,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) => setState(() => _groupHighPriority = val),
          ),
          SwitchListTile(
            title: const Text('Reaction notifications'),
            subtitle: const Text('Show notifications for reactions to messages you send'),
            value: _groupReaction,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) => setState(() => _groupReaction = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text('Calls', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ListTile(
            title: const Text('Ringtone'),
            subtitle: Text(_callRingtone),
            onTap: () => _showTonePicker('Call Ringtone', _callRingtone, (val) => setState(() => _callRingtone = val)),
          ),
          ListTile(
            title: const Text('Vibrate'),
            subtitle: const Text('Default'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call vibration set to Default'))),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text('Status', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ListTile(
            title: const Text('Notification tone'),
            subtitle: Text(_statusTone),
            onTap: () => _showTonePicker('Status Notification Tone', _statusTone, (val) => setState(() => _statusTone = val)),
          ),
          ListTile(
            title: const Text('Vibrate'),
            subtitle: const Text('Default'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status vibration set to Default'))),
          ),
          SwitchListTile(
            title: const Text('Use high priority notifications'),
            subtitle: const Text('Show previews of notifications at the top of the screen'),
            value: _statusHighPriority,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) => setState(() => _statusHighPriority = val),
          ),
          SwitchListTile(
            title: const Text('Reactions'),
            subtitle: const Text('Show notifications when you get likes on a status'),
            value: _statusReactions,
            activeColor: const Color(0xFF1E88E5),
            onChanged: (val) => setState(() => _statusReactions = val),
          ),
        ],
      ),
    );
  }
}

class PaymentsScreen extends StatelessWidget {
  final String myPhone;
  const PaymentsScreen({super.key, required this.myPhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeNet Payments'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VibeNet UPI Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      const Text('₹2,450.00', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('UPI ID: $myPhone@vibenet', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.arrow_downward, color: Colors.white)),
                    title: Text('Received from Rahul'),
                    subtitle: Text('Today, 10:45 AM'),
                    trailing: Text('+₹500.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.arrow_upward, color: Colors.white)),
                    title: Text('Sent to Priya'),
                    subtitle: Text('Yesterday, 4:20 PM'),
                    trailing: Text('-₹200.00', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.arrow_downward, color: Colors.white)),
                    title: Text('Quick UPI Transfer'),
                    subtitle: Text('2 days ago'),
                    trailing: Text('+₹100.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        _photoUrl = data['photoUrl'] ?? '';
      });
    }
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoUrl = pickedFile.path;
      });
      await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
        'photoUrl': pickedFile.path,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated successfully!')));
      }
    }
  }

  void _showFeatureMessage(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text('$title feature is integrated successfully in VibeNet!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showGmailBackupDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Google Drive Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your Gmail account to sync and backup your chats & media securely.'),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Gmail Address',
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@gmail.com')) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid Gmail address')));
                return;
              }
              await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
                'backupGmail': email,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup successful with $email!')));
              }
            },
            child: const Text('Backup Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: _pickAndUploadProfilePhoto,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF1E88E5),
                    backgroundImage: _photoUrl.isNotEmpty
                        ? (_photoUrl.startsWith('http') ? NetworkImage(_photoUrl) : FileImage(File(_photoUrl)) as ImageProvider)
                        : null,
                    child: _photoUrl.isEmpty ? const Icon(Icons.person, size: 35, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Binayak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('+91••••••6921', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Color(0xFF1E88E5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => QrCodeScreen(myPhone: widget.myPhone)),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment, color: Color(0xFF1E88E5)),
            title: const Text('Payments'),
            subtitle: const Text('Send and receive money securely'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => PaymentsScreen(myPhone: widget.myPhone)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_membership, color: Color(0xFF1E88E5)),
            title: const Text('Subscriptions'),
            subtitle: const Text('Explore premium benefits'),
            onTap: () => _showFeatureMessage('Subscriptions'),
          ),
          ListTile(
            leading: const Icon(Icons.devices, color: Color(0xFF1E88E5)),
            title: const Text('Linked devices'),
            subtitle: const Text('Use VibeNet on other devices'),
            onTap: () => _showFeatureMessage('Linked devices'),
          ),
          ListTile(
            leading: const Icon(Icons.key, color: Color(0xFF1E88E5)),
            title: const Text('Account'),
            subtitle: const Text('Security notifications, change number'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Color(0xFF1E88E5)),
            title: const Text('Privacy'),
            subtitle: const Text('Blocked accounts, disappearing messages, biometric'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => PrivacySettingsScreen(myPhone: widget.myPhone),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Color(0xFF1E88E5)),
            title: const Text('Lists'),
            subtitle: const Text('Manage people and groups'),
            onTap: () => _showFeatureMessage('Lists'),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1E88E5)),
            title: const Text('Chats'),
            subtitle: const Text('Chat history, backup'),
            onTap: _showGmailBackupDialog,
          ),
          ListTile(
            leading: const Icon(Icons.palette, color: Color(0xFF1E88E5)),
            title: const Text('Appearance'),
            subtitle: Text('Theme: ${appThemeMode.value == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'}'),
            trailing: Switch(
              value: appThemeMode.value == ThemeMode.dark,
              activeColor: const Color(0xFF1E88E5),
              onChanged: (val) async {
                setState(() {
                  appThemeMode.value = val ? ThemeMode.dark : ThemeMode.light;
                });
                try {
                  await FirebaseFirestore.instance.collection('users').doc(widget.myPhone).update({
                    'isDarkMode': val,
                  });
                } catch (_) {}
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: Color(0xFF1E88E5)),
            title: const Text('Broadcasts'),
            subtitle: const Text('Manage lists and send broadcasts'),
            onTap: () => _showFeatureMessage('Broadcasts'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF1E88E5)),
            title: const Text('Notifications'),
            subtitle: const Text('Message, group & call tones'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => NotificationsSettingsScreen(myPhone: widget.myPhone),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Color(0xFF1E88E5)),
            title: const Text('Storage and data'),
            subtitle: const Text('Network usage, auto-download'),
            onTap: () => _showFeatureMessage('Storage and data'),
          ),
          ListTile(
            leading: const Icon(Icons.child_care, color: Color(0xFF1E88E5)),
            title: const Text('Parental controls'),
            subtitle: const Text('Settings for your family'),
            onTap: () => _showFeatureMessage('Parental controls'),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility, color: Color(0xFF1E88E5)),
            title: const Text('Accessibility'),
            subtitle: const Text('Increase contrast, animation'),
            onTap: () => _showFeatureMessage('Accessibility'),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF1E88E5)),
            title: const Text('App language'),
            subtitle: Text(appLanguage.value == 'bn' ? 'বাংলা (Bengali)' : (appLanguage.value == 'hi' ? 'हिन्दी (Hindi)' : 'English')),
            onTap: () => showLanguageSelector(context),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF1E88E5)),
            title: const Text('Help and feedback'),
            subtitle: const Text('Help centre, contact us, privacy policy'),
            onTap: () => _showFeatureMessage('Help and feedback'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const WelcomeTermsScreen()));
              }
            },
          ),
        ],
      ),
    );
  }
}
