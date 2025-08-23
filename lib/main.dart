import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_theme.dart';
import 'screens/worker_list_screen.dart';
import 'package:provider/provider.dart';
import 'providers/worker_list_provider.dart'; // Ensure this file exists and exports WorkerListProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ConApp());
}

class ConApp extends StatefulWidget {
  const ConApp({Key? key}) : super(key: key);

  @override
  State<ConApp> createState() => _ConAppState();
}

class _ConAppState extends State<ConApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contractor Worker App',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthGate will handle login/signup and route to main app if authenticated
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          // Provide WorkerListProvider for this user
          return ChangeNotifierProvider(
            create: (_) {
              final provider = WorkerListProvider();
              provider.setUser(snapshot.data!.uid);
              return provider;
            },
            child: const WorkerListScreen(),
          );
        }
        // Not signed in
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final pin = _pinController.text.trim();
    final email = '${phone.replaceAll('+', '').replaceAll(' ', '')}@conapp.com';
    try {
      if (_isLogin) {
        // Login: sign in with email/password
        final cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        // Check master pin in Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .get();
        if (!doc.exists || doc['masterPin'] != pin) {
          await FirebaseAuth.instance.signOut();
          throw Exception('Invalid master PIN');
        }
      } else {
        // Signup: create user, store master pin
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
          'phone': phone,
          'masterPin': pin,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Phone Number (+91...)'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Master PIN'),
                  validator: (v) =>
                      v == null || v.length < 4 ? 'Min 4 digits' : null,
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) _submit();
                        },
                        child: Text(_isLogin ? 'Login' : 'Sign Up'),
                      ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                      _isLogin ? 'No account? Sign Up' : 'Have account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// (Removed duplicate AuthGate and LoginScreen classes)
