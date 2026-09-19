import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'config.dart';

// A StatefulWidget because the screen changes: the password can be
// shown/hidden and an error message can appear.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    // Always clean up controllers when the screen is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Looks for a matching user in the allowedUsers list (see config.dart).
  DemoUser? _findUser(String email, String password) {
    for (final user in allowedUsers) {
      if (user.email == email.trim().toLowerCase() &&
          user.password == password) {
        return user;
      }
    }
    return null; // no match
  }

  void _login() {
    setState(() => _errorMessage = null);

    // Run the validators of the two text fields.
    if (!_formKey.currentState!.validate()) return;

    final user = _findUser(_emailController.text, _passwordController.text);
    if (user == null) {
      setState(() => _errorMessage = 'Wrong email or password.');
      return;
    }

    // Success: open the chat screen and remove the login screen,
    // so the back button does not return here.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChatScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64, color: colors.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Gemini Chat',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log in to start chatting with AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null; // null means "no error"
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _login,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Log in'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildDemoAccounts(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper card that lists the demo accounts so people can tap to fill them in.
  // You can delete this whole method (and the call above) for a stricter demo.
  Widget _buildDemoAccounts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Demo accounts (tap one to fill)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final user in allowedUsers)
              ListTile(
                dense: true,
                leading: const Icon(Icons.person_outline),
                title: Text(user.email),
                subtitle: Text('Password: ${user.password}'),
                onTap: () {
                  _emailController.text = user.email;
                  _passwordController.text = user.password;
                  setState(() => _errorMessage = null);
                },
              ),
          ],
        ),
      ),
    );
  }
}
