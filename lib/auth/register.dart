import 'package:chef_palette/auth/set_details.dart';
import 'package:chef_palette/component/custom_button.dart';
import 'package:chef_palette/component/steps_bar.dart';
import 'package:chef_palette/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

//mark as incomplete
  void createUser(String password, String email) async {


  await FirebaseFirestore.instance.collection('incomplete_mark').doc(_emailController.text).set({
    'email' : email,
    'creationTime': Timestamp.now(),
    'status' : 'incomplete',
    'password': password,
  });
}

  Future<void> _registerUser() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _reenterPasswordController.text.isEmpty) {
    setState(() {
      _errorMessage = "Name cannot be the empty.";
    });
    return;
  }

  if (_passwordController.text != _reenterPasswordController.text) {
    setState(() {
      _errorMessage = "Passwords do not match!";
    });
    return;
  }

  //trigger loading screen
  setState(() {
    _isLoading = true;
  });

  try {
    setState(() {
    
    //clear previous error message
      _errorMessage = null; 
    });
    
    // Create the user and get the UserCredential
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

 

    // Retrieve the UID from the UserCredential
    String? uid = userCredential.user?.uid;

    if (uid != null) { 
      
    createUser(_passwordController.text, _emailController.text);
      // Pass the UID to RegisterStep2
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterStep2(uid: uid, email: _emailController.text,)),
      );
    } else {
      setState(() {
        _errorMessage = "Failed to retrieve UID.";
      });
    }
    //stop loading state


  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = e.message;
    });
  }

  setState(() {
      _isLoading = false;
    });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
       children: [
        SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 100),
          color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Welcome,", style: CustomStyle.lightLargeHeading),
              Text("Delicacy Ahead", style: CustomStyle.lightLargeHeading),
              Container(
                width: MediaQuery.sizeOf(context).width,
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.fromLTRB(40, 50, 40, 100),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const StepsBar(index: 0, len: 3), // Step 0 indicator
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        label: Text("Email"),
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: Text("Password"),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _reenterPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: Text("Reenter Password"),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 50),
                    RectButton(
                      bg: const Color.fromARGB(255, 51, 64, 129),
                      fg: const Color.fromARGB(255, 255, 255, 255),
                      text: "Next",
                      func: _registerUser, 
                      rad: 10,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage ?? '',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
       ),
       if (_isLoading)
            Container(
              color: Colors.black54, // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
       ],
    ),
    );
  }
}

