import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Login%20Signup/screen/login_screen.dart';
import 'package:untitled/Login%20Signup/widgets/snack_bar.dart';
import 'package:untitled/screens/student/student_home_screen.dart';
import 'package:untitled/screens/admin/admin_home_screen.dart';
import 'package:untitled/services/authentication.dart';

import '../widgets/button.dart';
import '../widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regnoController = TextEditingController();
  String selectedRole = "Student"; // Default role
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    regnoController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    String res = await AuthService().signUpUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      regno: regnoController.text,
      role: selectedRole,
    );

    if (res == "success") {
      setState(() {
        isLoading = true;
      });

      // Redirect based on user role
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userRole = await AuthService().getUserRole(user.uid);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return userRole == "Admin"
                  ? AdminHomeScreen()
                  : StudentHomeScreen();
            },
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: height / 2.7,
                  child: Image.asset("assets/signup.png"),
                ),
                TextfieldInput(
                  textEditingController: nameController,
                  hintText: "Enter your name",
                  icon: Icons.person,
                ),
                TextfieldInput(
                  textEditingController: regnoController,
                  hintText: "Enter your Reg No",
                  icon: Icons.app_registration,
                ),
                TextfieldInput(
                  textEditingController: emailController,
                  hintText: "Enter your Email",
                  icon: Icons.email,
                ),
                TextfieldInput(
                  textEditingController: passwordController,
                  isPass: true,
                  hintText: "Enter your password",
                  icon: Icons.lock,
                ),
                // Role Selection Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 35.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select Role: "),
                      DropdownButton<String>(
                        value: selectedRole,
                        items: <String>['Student', 'Admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                MyButton(onTab: signUpUser, text: "Sign Up"),
                SizedBox(height: height / 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an Account? ", style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// import "package:flutter/material.dart";
// import "package:untitled/Login%20Signup/screen/login_screen.dart";
// import "package:untitled/Login%20Signup/widgets/snack_bar.dart";
// import "package:untitled/screens/role_selection_screen.dart";
// import "package:untitled/services/authentication.dart";
//
// import "../widgets/button.dart";
// import "../widgets/text_field.dart";
//
// class SignUpScreen extends StatefulWidget{
//   const SignUpScreen({super.key});
//
//
//
//
//
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _SignupScreenState ();
//   }}
//
// class _SignupScreenState extends State<SignUpScreen>{
//
//
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController= TextEditingController();
//   final TextEditingController regnoController= TextEditingController();
//   bool isLoading =false;
//
//
//   void despose(){
//     super.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     nameController.dispose();
//   }
//
//
//
//
//   void signUpUser() async {
//     String res = await AuthService().signUpUser(
//         email: emailController.text,
//         password: passwordController.text,
//         name: nameController.text,
//         regno: regnoController.text, role: ''
//     );
// //if signup is success  user has been created navigate to the next page
// //   otherwise show the error messAGE
//     if (res == "success") {
//       setState(() {
//       isLoading=true;
//
//       });
//       //   navigate to the next screen
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const RoleSelection()
//           )
//       );
//
//     } else {
//       setState(() {
//       isLoading=false;
//       });
// // show the error message
//     showSnackBar(context, res);
//     }
//   }
//
//
//     @override
//     Widget build(BuildContext context) {
//       double height = MediaQuery
//           .of(context)
//           .size
//           .height;
//       // TODO: implement build
//       return Scaffold(
//           backgroundColor: Colors.white,
//           body: SingleChildScrollView(
//             child: SafeArea(
//                 child: SizedBox(
//                   child: Column(
//                       children: [
//                         SizedBox(width: double.infinity, height: height / 2.7,
//                             child: Image.asset("assets/signup.png")),
//                         TextfieldInput(
//                           textEditingController: nameController,
//                           hintText: "Enter your name",
//                           icon: Icons.person,
//
//
//                         ),
//                         TextfieldInput(
//                           textEditingController: regnoController,
//                           hintText: "Enter your Reg No",
//                           icon: Icons.app_registration,
//
//
//                         ),
//                         TextfieldInput(
//                           textEditingController: emailController,
//                           hintText: "Enter your Email",
//                           icon: Icons.email,
//                         ),
//                         TextfieldInput(
//                           textEditingController: passwordController,
//                           isPass: true,
//                           hintText: "Enter your password",
//                           icon: Icons.lock,
//                         ),
//                         // Padding(
//                         //   padding: const EdgeInsets.symmetric(horizontal: 35.0),
//                         //   child: Align(alignment: Alignment.center,
//                         //     child: Text("Already have an account? ", style: TextStyle(
//                         //         fontWeight: FontWeight.bold,
//                         //         fontSize: 16,
//                         //         color: Colors.lightGreen),),
//                         //   ),
//                         // ),
//                         MyButton(onTab: () {
//                           signUpUser();
//                         }, text: "Sign Up"),
//                         SizedBox(height: height / 80,),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Already have an Account? ",
//                               style: TextStyle(fontSize: 16),),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(context, MaterialPageRoute(
//                                   builder: (context) => LoginScreen(),
//                                 ),
//                                 );
//                               },
//                               child: const Text("Login", style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),),
//
//                             )
//                           ],
//
//                         )
//                       ]
//                   )
//                   ,
//                 )
//             ),
//           )
//       );
//     }
//   }
//
//
