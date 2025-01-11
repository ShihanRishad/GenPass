import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:shared_preferences/shared_preferences.dart';
// import './saved_passwords_screen.dart';
import 'package:flutter/services.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const PasswordGeneratorScreen(
      {Key? key, required this.themeMode, required this.onToggleTheme})
      : super(key: key);

  // List<String> get savedPasswords => PasswordGeneratorScreenState._savedPasswords;

  @override
  PasswordGeneratorScreenState createState() => PasswordGeneratorScreenState();
}

List<String> savedPasswords = [];

class PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final _passwordController = TextEditingController();
  int _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSpecialCharacters = true;

  void _generatePassword() {
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialCharacters = '!@#\$%^&*()-_=+[]{}<>?';

    String chars = '';
    if (_includeUppercase) chars += uppercase;
    if (_includeLowercase) chars += lowercase;
    if (_includeNumbers) chars += numbers;
    if (_includeSpecialCharacters) chars += specialCharacters;

    if (chars.isEmpty) {
      _passwordController.text = 'Select at least one option';
      return;
    }

    final random = Random();
    String password = List.generate(
      _passwordLength,
      (index) => chars[random.nextInt(chars.length)],
    ).join();

    setState(() {
      _passwordController.text = password;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _passwordController.text));
    _showCustomSnackbar(context, 'Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GenPass',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPasswordBox(),
                  SizedBox(height: 20),
                  _buildSettings(),
                ],
              ),
            ),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordBox() {
    return Container(
      padding: EdgeInsets.only(right: 16, left: 20, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _passwordController,
              readOnly: true,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Generated password will appear here',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy_rounded),
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: Icon(Icons.save_rounded),
            onPressed: _savePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.45, // Limit height to 50% of the screen
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Length: $_passwordLength',
                style: const TextStyle(fontSize: 16),
              ),
              Slider(
                value: _passwordLength.toDouble(),
                min: 6,
                max: 32,
                divisions: 26,
                label: _passwordLength.toString(),
                thumbColor: const Color.fromARGB(255, 8, 5, 211),
                activeColor: const Color.fromARGB(255, 8, 5, 211),
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _passwordLength = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildCheckbox(
                'Include Uppercase Letters',
                _includeUppercase,
                (value) => setState(() => _includeUppercase = value ?? false),
              ),
              _buildCheckbox(
                'Include Lowercase Letters',
                _includeLowercase,
                (value) => setState(() => _includeLowercase = value ?? false),
              ),
              _buildCheckbox(
                'Include Numbers',
                _includeNumbers,
                (value) => setState(() => _includeNumbers = value ?? false),
              ),
              _buildCheckbox(
                'Include Special Characters',
                _includeSpecialCharacters,
                (value) =>
                    setState(() => _includeSpecialCharacters = value ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String title, bool value, void Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool? newValue) => onChanged(newValue),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _savePassword() {
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != 'Select at least one option') {
      setState(() {
        savedPasswords.add(_passwordController.text);
        print(_passwordController.text);
        print(savedPasswords);
      });

      // Show custom floating notification
      _showCustomSnackbar(context, 'Password saved!');
    } else {
      _showCustomSnackbar(context, 'Generate a valid password first!',
          isError: true);
    }
  }

  void _showCustomSnackbar(BuildContext context, String message,
      {bool isError = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    final opacityController =
        ValueNotifier<double>(0.0);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.top + 30,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: ValueListenableBuilder<double>(
            valueListenable: opacityController,
            builder: (context, opacity, child) => AnimatedOpacity(
              opacity: opacity,
              duration: Duration(milliseconds: 300), // Fade-in/out duration
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.redAccent
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry
    overlay.insert(overlayEntry);

    // Delay fade-in by one frame to ensure the widget is visible before starting animation
    Future.delayed(Duration.zero, () {
      opacityController.value = 1.0; // Trigger fade-in
    });

    // Wait for display duration, then fade-out and remove
    Future.delayed(Duration(seconds: 2)).then((_) {
      opacityController.value = 0.0; // Start fade-out
      Future.delayed(Duration(milliseconds: 300)).then((_) {
        overlayEntry.remove(); // Remove after fade-out completes
      });
    });
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
        onPressed: _generatePassword,
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            //   padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50)),
        child: Text('Generate Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
  }
}
