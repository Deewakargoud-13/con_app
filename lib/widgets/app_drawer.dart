import 'package:flutter/material.dart';
import '../screens/monthly_report_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.account_circle,
                      size: 40, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome!',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('Yogendra Goud',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.people_outline, color: Colors.blue.shade700),
            title: const Text('Workers',
                style: TextStyle(fontWeight: FontWeight.w500)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading:
                Icon(Icons.bar_chart_rounded, color: Colors.orange.shade700),
            title: const Text('Monthly Report',
                style: TextStyle(fontWeight: FontWeight.w500)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
