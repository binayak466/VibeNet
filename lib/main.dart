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
          if (currentUser != null && currentUser.phoneNumber != null) {
            return ChatListScreen(myPhone: currentUser.phoneNumber!);
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

// --- Terms & Conditions Screen ---
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
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF075E54).withOpacity(0.08),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 100,
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
                    'from\nVibeNet Team',
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

// --- Phone Input Screen ---
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
    if (phone.length < 10) {
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

      await FirebaseFirestore.instance.collection('users').doc(_fullPhoneNumber).set({
        'phone': _fullPhoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
                  width: 60,
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

// --- আসল সক্রিয় চ্যাট লিস্ট স্ক্রিন ---
class ChatListScreen extends StatefulWidget {
  final String myPhone;
  const ChatListScreen({super.key, required this.myPhone});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  void _startNewChat() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Chat'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Enter 10-digit number',
            prefixText: '+91 ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF075E54), foregroundColor: Colors.white),
            onPressed: () {
              final target = controller.text.trim();
              if (target.length >= 10) {
                Navigator.pop(ctx);
                final fullTarget = target.startsWith('+') ? target : '+91$target';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationScreen(
                      myPhone: widget.myPhone,
                      receiverPhone: fullTarget,
                    ),
                  ),
                );
              }
            },
            child: const Text('Chat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeNet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final Set<String> chatPartners = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final sender = data['sender'] as String?;
            final receiver = data['receiver'] as String?;
            if (sender == widget.myPhone && receiver != null) {
              chatPartners.add(receiver);
            } else if (receiver == widget.myPhone && sender != null) {
              chatPartners.add(sender);
            }
          }

          final partnersList = chatPartners.toList();

          if (partnersList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('কোনো চ্যাট নেই', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('নিচের বাটনে চাপ দিয়ে চ্যাট শুরু করুন', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: partnersList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final partner = partnersList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF128C7E),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.person),
                ),
                title: Text(partner, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap to open conversation'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                        myPhone: widget.myPhone,
                        receiverPhone: partner,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        child: const Icon(Icons.message),
      ),
    );
  }
}

// --- মেসেজিং স্ক্রিন (প্লাস আইকন ও টিক মার্ক সহ) ---
class ConversationScreen extends StatefulWidget {
  final String myPhone;
  final String receiverPhone;

  const ConversationScreen({
    super.key,
    required this.myPhone,
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

  // WhatsApp-এর মতো প্লাস (+) আইকনে চাপলে নিচের মেনু খোলা
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
        CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 70,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back),
              SizedBox(width: 4),
              CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFF128C7E),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
        title: Text(widget.receiverPhone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
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
                    final timeText = _formatTime(data['timestamp'] as Timestamp?);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0, bottom: 2.0),
                              child: Text(
                                data['text'] ?? '',
                                style: const TextStyle(color: Colors.black87, fontSize: 15),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeText,
                                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 3),
                                  // WhatsApp ব্লু ডাবল টিক মার্ক
                                  const Icon(Icons.done_all, size: 15, color: Color(0xFF34B7F1)),
                                ],
                              ],
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

          // চ্যাট ইনপুট বার (প্লাস আইকন সহ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            color: Colors.transparent,
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
                        // WhatsApp স্টাইল প্লাস (+) আইকন
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF007AFF), size: 26),
                          onPressed: _showAttachmentOptions,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF075E54),
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
