import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_list/screens/home.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // static Future<User?> loginUsingEmailPassword(
  //     String email, String password, BuildContext context) async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user;

  //   try {
  //     UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     user = userCredential.user;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == "user-not-found") {
  //       print("No user found");
  //     }
  //   }

  //   return user;
  // }

  // Future<User?> createAccount(
  //     String name, String email, String password, BuildContext context) async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;

  //   try {
  //     User? user = (await _auth.createUserWithEmailAndPassword(
  //             email: email, password: password))
  //         .user;

  //     if (user != null) {
  //       print("Account created");
  //       return user;
  //     } else {
  //       print("Failed task");
  //       return user;
  //     }
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  Future<User?> createAccount(
      String name, String email, String password, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCrendetial = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      print("Account created Succesfull");

      userCrendetial.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "uid": _auth.currentUser!.uid,
      });

      return userCrendetial.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Container(
                child: const CircularProgressIndicator(),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            "assets/Tasks.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Register Screen',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: "User Name",
                            prefixIcon:
                                Icon(Icons.account_box, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "User Email",
                            prefixIcon: Icon(Icons.mail, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "User Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Register()),
                            );
                          },
                          child: const Text(
                            "SignUp",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey,
                          child: MaterialButton(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {
                              //        createAccount(nameController.text, emailController.text, passwordController.text, context).then((user) {
                              // Navigator.push(
                              //     context, MaterialPageRoute(builder: (_) => Home()));
                              // print("Account Created Sucessfull");
                              //            }

                              if (nameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });

                                createAccount(
                                        nameController.text,
                                        emailController.text,
                                        passwordController.text,
                                        context)
                                    .then((user) {
                                  if (user != null) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const Home()));
                                    print("Account Created Sucessfull");
                                  } else {
                                    print("Login Failed");
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                });
                              } else {
                                print("Please enter Fields");
                              }
                            },
                            child: const Text(
                              "Login",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
