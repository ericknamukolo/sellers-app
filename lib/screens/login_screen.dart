// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/providers/auth.dart';
import 'package:sellers_app/screens/home_screen.dart';
import 'package:sellers_app/widgets/custom_button.dart';
import 'package:sellers_app/widgets/custom_input_field.dart';
import 'package:sellers_app/widgets/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final GlobalKey _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _loginSeller() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) =>
              const ErrorDialog(message: 'Enter both fields'));
    } else {
      //login
      _loginNow();
    }
  }

  Future<void> _loginNow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var currentUser = await firebaseAuth.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text.trim());

      if (currentUser != null) {
        //fetch and save data locally
        try {
          await fetchAndSetDataLocally(currentUser.user!);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } catch (err) {
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(message: err.toString()));
        }
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (context) => ErrorDialog(message: err.toString()));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchAndSetDataLocally(User currentUser) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(currentUser.uid)
        .get();

    //Save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString('uid', currentUser.uid);
    await sharedPreferences!.setString('email', currentUser.email.toString());
    await sharedPreferences!.setString('name', snapshot.data()!['sellerName']);
    await sharedPreferences!
        .setString('photoUrl', snapshot.data()!['sellerAvatar']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomInputField(
              hint: 'Email',
              icon: Icons.email,
              controller: _email,
            ),
            CustomInputField(
              hint: 'Password',
              icon: Icons.lock,
              controller: _password,
            ),
            CustomButton(
              isLoading: _isLoading,
              text: 'Log In',
              click: _loginSeller,
            ),
          ],
        ),
      ),
    );
  }
}
