import 'package:flutter/material.dart';
import 'package:sellers_app/screens/login_screen.dart';
import 'package:sellers_app/screens/register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Sellers app'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.lock), text: 'Log In'),
              Tab(icon: Icon(Icons.account_circle), text: 'Sign up'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginScreen(),
            RegisterScreen(),
          ],
        ),
      ),
    );
  }
}
