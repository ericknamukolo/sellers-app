import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/providers/auth.dart';
import 'package:sellers_app/widgets/custom_button.dart';
import 'package:sellers_app/widgets/custom_input_field.dart';
import 'package:sellers_app/widgets/error_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  Position? _position;
  List<Placemark>? _placeMarks;
  String? _sellerImageUrl;
  bool _isLoading = false;

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> _getCurrentPosition() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    _position = newPosition;
    _placeMarks = await placemarkFromCoordinates(
        _position!.latitude, _position!.longitude);

    String completeAddress =
        '${_placeMarks![0].locality}, ${_placeMarks![0].administrativeArea}';
    _location.text = completeAddress;
  }

  Future<void> _formValidation() async {
    if (imageXFile == null) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(message: 'Select an image'),
      );
    } else {
      if (_password.text == _confirmPassword.text) {
        if (_name.text.isNotEmpty &&
            _phoneNumber.text.isNotEmpty &&
            _email.text.isNotEmpty &&
            _location.text.isNotEmpty) {
          //upload image
          //show loading
          setState(() {
            _isLoading = true;
          });
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fs.Reference reference = fs.FirebaseStorage.instance
              .ref()
              .child('sellers')
              .child(fileName);
          fs.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          fs.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            _sellerImageUrl = url;
            //authenticateSeller
            authenticateSellerAndSignUp();
          });
        } else {
          showDialog(
            context: context,
            builder: (context) =>
                const ErrorDialog(message: 'Please enter all fields'),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) =>
              const ErrorDialog(message: 'Passwords do not match'),
        );
      }
    }
  }

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _location = TextEditingController();

  Future<void> authenticateSellerAndSignUp() async {
    try {
      User? _currentUser;

      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: _email.text.trim(), password: _password.text.trim())
          .then((auth) {
        _currentUser = auth.user;
      });

      if (_currentUser != null) {
        await registerSeller(_currentUser!);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
          context: context,
          builder: (context) => ErrorDialog(message: err.toString()));
    }
  }

  Future<void> registerSeller(User currentUser) async {
    var firestore = FirebaseFirestore.instance;
    firestore.collection('sellers').doc(currentUser.uid).set({
      'sellerUID': currentUser.uid,
      'sellerEmail': currentUser.email,
      'sellerName': _name.text.trim(),
      'sellerAvatar': _sellerImageUrl,
      'phone': _phoneNumber.text.trim(),
      'address': _location.text.trim(),
      'status': true,
      'earnings': 0.0,
      'lat': _position!.latitude,
      'long': _position!.longitude,
    });
    //Save data locally
    sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences!.setString('uid', currentUser.uid);
    await sharedPreferences!.setString('email', currentUser.email.toString());
    await sharedPreferences!.setString('name', _name.text);
    await sharedPreferences!.setString('photoUrl', _sellerImageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: _getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageXFile == null
                    ? null
                    : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? const Icon(
                        Icons.add_a_photo_rounded,
                      )
                    : null,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CustomInputField(
                      hint: 'Name',
                      icon: Icons.account_circle_rounded,
                      controller: _name),
                  CustomInputField(
                      hint: 'Phone Number',
                      icon: Icons.phone,
                      controller: _phoneNumber),
                  CustomInputField(
                      hint: 'Email', icon: Icons.email, controller: _email),
                  CustomInputField(
                    hint: 'Restaurant Location',
                    icon: Icons.my_location_rounded,
                    controller: _location,
                    enabled: true,
                    trailingIcon: Icons.location_pin,
                    trailingFunc: _getCurrentPosition,
                  ),
                  CustomInputField(
                      hint: 'Password',
                      icon: Icons.lock,
                      controller: _password),
                  CustomInputField(
                      hint: 'Confirm Password',
                      icon: Icons.lock,
                      controller: _confirmPassword),
                  CustomButton(
                    isLoading: _isLoading,
                    text: 'Sign Up',
                    click: _formValidation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
