import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/worker_list_screen.dart';
import 'models/worker.dart';
import 'models/attendance.dart';
import 'models/payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase (replace with your actual values)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // TODO: Replace with your Supabase project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZmFsaXJjeWpjc2ptaHlldmlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5NzQ0OTQsImV4cCI6MjA3MTU1MDQ5NH0.FJGsZaDFj7LgBbBVY0d7vBUU3kAjdoEzKxWhB7BjPB8', // TODO: Replace with your Supabase anon/public key
  );
  await Hive.initFlutter();
  Hive.registerAdapter(AttendanceTypeAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(PaymentRecordAdapter());
  Hive.registerAdapter(WorkerAdapter());
  Hive.registerAdapter(AdvanceRecordAdapter());
  final workerListModel = WorkerListModel();
  await workerListModel.loadFromHive();
  runApp(ConApp(workerListModel: workerListModel));
}

class ConApp extends StatefulWidget {
  final WorkerListModel workerListModel;
  const ConApp({Key? key, required this.workerListModel}) : super(key: key);

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Save data when app is paused or detached
      widget.workerListModel.saveToHive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.workerListModel,
      child: MaterialApp(
        title: 'Contractor Worker App',
        theme: AppTheme.lightTheme,
        home: const WorkerListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
