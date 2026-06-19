import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notifications_service.dart';
// Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeNotifications(); 
  await FirebaseMessaging.instance.requestPermission();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Tester App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationTesterPage(),
    );
  }
}

class NotificationTesterPage extends StatefulWidget {
  const NotificationTesterPage({super.key});

  @override
  State<NotificationTesterPage> createState() => _NotificationTesterPageState();
}

class _NotificationTesterPageState extends State<NotificationTesterPage> {
  String fcmToken = 'Fetching token...';

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
  try {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();

    print("Permission: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      final token = await messaging.getToken();

      print("FCM TOKEN ");
      print(token);
      if (mounted) {
        setState(() {
          fcmToken = token ?? 'Failed to get token';
        });
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("Notification clicked: ${message.data}");
      });

    } else {
      if (mounted) {
        setState(() {
          fcmToken = 'Notification permission denied';
        });
      }
    }

  } catch (e) {
    print("FCM ERROR: $e");

    if (mounted) {
      setState(() {
        fcmToken = "Error getting token";
      });
    }
  }
}

  Future<void> _copyToken() async {
    await Clipboard.setData(ClipboardData(text: fcmToken));
    if (!mounted) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copied successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Tester App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(
                fcmToken,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _copyToken,
                child: const Text('Copy Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}