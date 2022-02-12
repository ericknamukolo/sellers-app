import 'package:flutter/material.dart';
import 'package:sellers_app/providers/auth.dart';
import 'package:sellers_app/screens/auth_screen.dart';
import 'package:sellers_app/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(sharedPreferences!.getString('name')!),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButton(
            text: 'sign out',
            click: () async {
              await firebaseAuth.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthScreen()));
            },
          ),
        ],
      ),
    );
  }
}
