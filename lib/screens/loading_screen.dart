import 'package:flutter/material.dart';
import 'package:sellers_app/providers/auth.dart';
import 'package:sellers_app/screens/auth_screen.dart';
import 'package:sellers_app/screens/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  void checkIfLoggedIn() {
    firebaseAuth.currentUser == null
        ? Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AuthScreen()))
        : Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      checkIfLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('loading...'),
      ),
    );
  }
}
