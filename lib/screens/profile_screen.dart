import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya")),
      body: Center(
        child: auth.isAuthenticated
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah Login!"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => auth.logout(),
                    child: const Text("Logout"),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, SignInScreen.routeName),
                child: const Text("Login / Register"),
              ),
      ),
    );
  }
}
