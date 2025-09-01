# Supabase Flutter Setup Instructions

1. Go to https://app.supabase.com/ and create a free account.
2. Create a new project and note your Project URL and anon/public API key.
3. Add the following to your pubspec.yaml dependencies:

supabase_flutter: ^2.5.2

4. Run `flutter pub get` to install the package.
5. In your `main.dart`, initialize Supabase before running the app:

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Supabase.initialize(
url: 'YOUR_SUPABASE_URL',
anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
runApp(MyApp());
}

Replace 'YOUR_SUPABASE_URL' and 'YOUR_SUPABASE_ANON_KEY' with your actual values from the Supabase dashboard.

6. You can now use Supabase to store and retrieve data. Example usage:

final supabase = Supabase.instance.client;
final response = await supabase.from('your_table').insert({'key': 'value'});

---

Let me know when you have your Supabase URL and anon key, and I can add the initialization code directly to your app.
