import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    return Container(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: profileForm(),
      ),
    );
  }

  Widget profileForm() {
    return Form(
      key: _formKey,
      child: Column(
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
                  !_passwordVisible ? Icons.visibility : Icons.visibility_off,
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
              performLogin(context);
            },
            child: Text(
              'Sign In',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          _isLoggingIn ? CircularProgressIndicator() : SizedBox(height: 32),
        ],
      ),
    );
  }

  void prefillForms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String e = prefs.getString('myemail');
    String p = prefs.getString('mypassword');

    setState(() {
      _emailController.text = e;
      _passwordController.text = p;
    });
  }

  void performLogin(BuildContext c) async {
    setState(() => _isLoggingIn = true);
    if (_formKey.currentState.validate()) {
      String e = _emailController.text.toLowerCase().trim();
      String p = _passwordController.text.trim();
      // Utils.makeToast('Logging in...\n$e\n$p', Colors.blue);

      CollectionReference usersCollec = _firestore.collection(USERS_COLLECTION);
      QuerySnapshot query =
          await usersCollec.where('email', isEqualTo: '$e').get();

      if (query.docs.length <= 0) {
        Utils.makeToast('No User under that Name', Colors.deepOrange);
        // DocumentReference newdoc =
        //     await usersCollec.add({'email': e, 'password': p});
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('myemail', e);
        // await prefs.setString('mypassword', p);
        // await prefs.setString('myfirebaseid', newdoc.id);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => HomeScreen()),
        // );
      } else if (query.docs.length > 0) {
        if (query.docs.first.get('password') == p) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('myemail', e);
          await prefs.setString('mypassword', p);
          await prefs.setString('myuid', query.docs.first.get('uid'));

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
