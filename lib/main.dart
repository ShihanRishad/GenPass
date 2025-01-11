// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
// import 'dart:math';
// import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/generate_password_screen.dart';
import 'screens/saved_passwords_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkTheme =
      prefs.getBool('isDarkTheme') ?? true; // Default to dark theme
  runApp(PasswordGeneratorApp(isDarkTheme: isDarkTheme));
}

class PasswordGeneratorApp extends StatefulWidget {
  final bool isDarkTheme;

  const PasswordGeneratorApp({Key? key, required this.isDarkTheme})
      : super(key: key);

  @override
  _PasswordGeneratorAppState createState() => _PasswordGeneratorAppState();
}

class _PasswordGeneratorAppState extends State<PasswordGeneratorApp> {
  late ThemeMode _themeMode;
  int _selectedIndex = 0;
  late PasswordGeneratorScreen passwordGeneratorScreen;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
  }

  final _passwordGeneratorScreenKey =
      GlobalKey<PasswordGeneratorScreenState>();

  List<Widget> _getScreens() => [
        PasswordGeneratorScreen(key: _passwordGeneratorScreenKey, themeMode: _themeMode, onToggleTheme: _toggleTheme),
        SavedPasswordsScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GenPass',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 184, 88, 223)),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color.fromARGB(255, 214, 201, 226),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color.fromARGB(255, 44, 22, 44),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
body: LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      // Use NavigationBar for smaller screens
      return Scaffold(
        body: screens[_selectedIndex], // Screen content
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.vpn_key_rounded),
              label: 'Generate',
            ),
            NavigationDestination(
              icon: Icon(Icons.save_rounded),
              label: 'Saved',
            ),
          ],
        ),
      );
    } else {
      // Use NavigationRail for larger screens
      return Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.vpn_key_rounded),
                label: Text('Generate'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.save_rounded),
                label: Text('Saved'),
              ),
            ],
          ),
          Expanded(child: screens[_selectedIndex]),
        ],
      );
    }
  },
),

      ),
    );
  }
}

// class PasswordGeneratorScreen extends StatefulWidget {
//   final ThemeMode themeMode;
//   final VoidCallback onToggleTheme;

//   const PasswordGeneratorScreen({
//     Key? key,
//     required this.themeMode,
//     required this.onToggleTheme,
//   }) : super(key: key);

//   @override
//   _PasswordGeneratorScreenState createState() =>
//       _PasswordGeneratorScreenState();
// }

// class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
//   final _passwordController = TextEditingController();
//   int _passwordLength = 12;
//   bool _includeUppercase = true;
//   bool _includeLowercase = true;
//   bool _includeNumbers = true;
//   bool _includeSpecialCharacters = true;

//   void _generatePassword() {
//     const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//     const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
//     const String numbers = '0123456789';
//     const String specialCharacters = '!@#\$%^&*()-_=+[]{}<>?';

//     String chars = '';
//     if (_includeUppercase) chars += uppercase;
//     if (_includeLowercase) chars += lowercase;
//     if (_includeNumbers) chars += numbers;
//     if (_includeSpecialCharacters) chars += specialCharacters;

//     if (chars.isEmpty) {
//       _passwordController.text = 'Select at least one option';
//       return;
//     }

//     final random = Random();
//     String password = List.generate(
//       _passwordLength,
//       (index) => chars[random.nextInt(chars.length)],
//     ).join();

//     setState(() {
//       _passwordController.text = password;
//     });
//   }

//   void _copyToClipboard() {
//     Clipboard.setData(ClipboardData(text: _passwordController.text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Password copied to clipboard!'),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkTheme = widget.themeMode == ThemeMode.dark;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'GenPass',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
//             onPressed: widget.onToggleTheme,
//           ),
//         ],
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildPasswordBox(),
//             SizedBox(height: 20),
//             _buildSettings(),
//             Spacer(),
//             _buildGenerateButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPasswordBox() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).brightness == Brightness.dark
//             ? Colors.white.withOpacity(0.1)
//             : Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(100),
//         border: Border.all(
//           color: Theme.of(context).primaryColor.withOpacity(0.5),
//           width: 1.5,
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _passwordController,
//               readOnly: true,
//               style: TextStyle(fontSize: 18),
//               decoration: InputDecoration(
//                 hintText: 'Generated password will appear here',
//                 hintStyle: TextStyle(
//                   color: Theme.of(context).brightness == Brightness.dark
//                       ? Colors.white60
//                       : Colors.black54,
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.copy),
//             onPressed: _copyToClipboard,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettings() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Password Length: $_passwordLength',
//           style: TextStyle(fontSize: 16),
//         ),
//         Slider(
//           value: _passwordLength.toDouble(),
//           min: 6,
//           max: 32,
//           divisions: 26,
//           label: _passwordLength.toString(),
//           thumbColor: Color.fromARGB(255, 8, 5, 211),
//           overlayColor: WidgetStateProperty.all(
//               Color.fromARGB(136, 40, 55, 134).withOpacity(0.2)),

//           // activeColor: Theme.of(context).primaryColor.withGreen(1),
//           activeColor: Color.fromARGB(255, 8, 5, 211),
//           inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
//           onChanged: (value) {
//             setState(() {
//               _passwordLength = value.toInt();
//             });
//           },
//         ),
//         SizedBox(height: 10),
//         _buildCheckbox(
//           'Include Uppercase Letters',
//           _includeUppercase,
//           (value) => setState(() => _includeUppercase = value ?? false),
//         ),
//         _buildCheckbox(
//           'Include Lowercase Letters',
//           _includeLowercase,
//           (value) => setState(() => _includeLowercase = value ?? false),
//         ),
//         _buildCheckbox(
//           'Include Numbers',
//           _includeNumbers,
//           (value) => setState(() => _includeNumbers = value ?? false),
//         ),
//         _buildCheckbox(
//           'Include Special Characters',
//           _includeSpecialCharacters,
//           (value) => setState(() => _includeSpecialCharacters = value ?? false),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckbox(
//       String title, bool value, void Function(bool?) onChanged) {
//     return CheckboxListTile(
//       title: Text(title),
//       value: value,
//       activeColor: Theme.of(context).primaryColor,
//       onChanged: (bool? newValue) => onChanged(newValue),
//       contentPadding: EdgeInsets.zero,
//     );
//   }

//   Widget _buildGenerateButton() {
//     return ElevatedButton(
//       onPressed: _generatePassword,
//       style: ElevatedButton.styleFrom(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//         padding: EdgeInsets.symmetric(vertical: 16),
//         minimumSize: Size(double.infinity, 50),
//       ),
//       child: Text(
//         'Generate Password',
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
