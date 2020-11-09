import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webrtc_test/string_constant.dart';

import '../utilityMan.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoggingIn = false;
  // BuildContext c;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => prefillForms());
  }

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    // c = context;
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: profileForm(),
      ),
    );
  }

  Widget profileForm() {
    return Form(
      key: _formKey,
      child: _isLoggingIn
          ? CircularProgressIndicator()
          : Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    value = value.trim();
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else if (!EmailValidator.validate(value)) {
                      return 'Not a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    // suffixIcon: Icon(
                    //   Icons.mail,
                    //   color: Theme.of(context).primaryColor,
                    // ),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty)
                      return 'Please enter your password';
                    else if (value.length < 6)
                      return 'The pasword must be at least 6 (six) characters long';
                    return null;
                  },
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        !_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 32),
                FlatButton(
                  color: Colors.blue,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    performLogin();
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }

  void prefillForms() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box b = await Hive.openBox('myprofile');
    String e = b.get('myemail', defaultValue: '');
    String p = b.get('mypassword', defaultValue: '');
    Hive.close();

    setState(() {
      _emailController.text = e;
      _passwordController.text = p;
    });

    if (e != '' && p != '') {
      performLogin();
    }
  }

  void performLogin() async {
    setState(() => _isLoggingIn = true);
    if (_formKey.currentState.validate()) {
      String e = _emailController.text.toLowerCase().trim();
      String p = _passwordController.text.trim();
      CollectionReference usersCollec = _firestore.collection(USERS_COLLECTION);
      QuerySnapshot query =
          await usersCollec.where('email', isEqualTo: '$e').get();

      if (query.docs.length <= 0) {
        Utils.makeToast('No User under that Name', Colors.deepOrange);
      } else if (query.docs.length > 0) {
        if (query.docs.first.get('password') == p) {
          Box b = await Hive.openBox('myprofile');
          b.put('myemail', e);
          b.put('mypassword', p);
          b.put('myuid', query.docs.first.get('uid'));
          Utils.makeToast('Signed in Successfully', Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Utils.makeToast('Wrong Password! Try again.', Colors.deepOrange);
        }
      }
    } else
      Utils.makeToast('Sign in credentials INVALID', Colors.deepOrange);
    setState(() => _isLoggingIn = false);
  }
}
