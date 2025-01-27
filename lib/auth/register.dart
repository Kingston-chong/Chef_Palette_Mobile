import 'package:chef_palette/auth/set_details.dart';
import 'package:chef_palette/component/custom_button.dart';
import 'package:chef_palette/component/steps_bar.dart';
import 'package:chef_palette/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:password_strength_indicator_plus/password_strength_indicator_plus.dart';

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
  bool _isPasswordVisible = false;

//create incomplete_mark record
//to allow deletion for incomplete account (exists in auth but not in db)



  Future<void> _registerUser() async {

    setState(() {
      _errorMessage = null;
    });

try {
   RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
   
      if (!regex.hasMatch(_passwordController.text)) {
       setState(() { _errorMessage = 'Please make a stronger password.';});
    return;
  }
  //might be achieve by just using firebase settings, extra here

 final bool emailValid = 
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(_emailController.text);

if(!emailValid){
  setState(() {
    _errorMessage = "Invalid email format";
  });
  return;
}

  if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _reenterPasswordController.text.isEmpty) {
    setState(() {
      _errorMessage = "Please fill in all fields.";
    });
    return;
  }

  if (_passwordController.text != _reenterPasswordController.text) {
    setState(() {
      _errorMessage = "Passwords do not match!";
    });
    return;
  } 
  QuerySnapshot query =  
  await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: _emailController.text).get();
 
  if (query.docs.isNotEmpty) {
    setState(() {
      _errorMessage = "Account already exist";
    });
    return;
  }

  setState(() {
    _isLoading = true;
  });

      // Pass the UID to RegisterStep2
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterStep2(password: _passwordController.text, email: _emailController.text,)),
      );
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
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        label: const Text("Password"),
                         prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle state
                            });
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _reenterPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        label: const Text("Reenter Password"),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle state
                            });
                          },
                        ),
                      ),
                    ),

                    PasswordStrengthIndicatorPlus(
                                textController: _passwordController,   
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

