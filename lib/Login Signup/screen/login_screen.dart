import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:untitled/Login%20Signup/widgets/text_field.dart';
import 'package:untitled/Login%20Signup/screen/sign_up.dart';
import 'package:untitled/Login%20Signup/widgets/button.dart';
import 'package:untitled/services/authentication.dart';
import '../widgets/snack_bar.dart';


import 'package:untitled/screens/student/student_home_screen.dart';
import 'package:untitled/screens/admin/admin_home_screen.dart';
import 'package:untitled/services/authentication.dart';
import 'package:untitled/Login%20Signup/widgets/text_field.dart';
import 'package:untitled/Login%20Signup/widgets/button.dart';
import '../widgets/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = "Student";
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthService().loginUser(
      email: emailController.text,
      password: passwordController.text,
      selectedRole: selectedRole,
    );

    if (res == "success") {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userRole = await AuthService().getUserRole(user.uid);

        if (userRole == selectedRole) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return userRole == "Admin"
                    ? AdminHomeScreen()
                    : StudentHomeScreen();
              },
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          showSnackBar(context, "Role mismatch. Please select the correct role.");
        }
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
                  child: Image.asset("assets/login2.png"),
                ),
                TextfieldInput(
                  textEditingController: emailController,
                  hintText: "Enter your email",
                  icon: Icons.email,
                ),
                TextfieldInput(
                  textEditingController: passwordController,
                  hintText: "Enter your password",
                  isPass: true,
                  icon: Icons.key,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                ),
                Row(
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
                MyButton(onTab: loginUser, text: "Log In"),
                SizedBox(height: height / 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an Account? ", style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: const Text("SignUp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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





// import 'package:firebase_auth/firebase_auth.dart';
// import "package:flutter/material.dart";
//
// import 'package:untitled/Login Signup/widgets/text_field.dart';
// import 'package:untitled/Login%20Signup/screen/sign_up.dart';
// import 'package:untitled/Login%20Signup/widgets/button.dart';
// import 'package:untitled/services/authentication.dart';
//
// import '../../screens/role_selection_screen.dart';
// import '../widgets/snack_bar.dart';
//
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _LoginScreenState();
//   }
//
//
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   // for controller
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   String selectedRole = "Student";
//
//   bool isLoading=false;
//
//   void despose(){
//     super.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//
//   }
//
//   void loginUser() async {
//     setState(() {
//       isLoading = true;
//     });
//     String res = await AuthService().loginUser(
//         email: emailController.text,
//         password: passwordController.text,
//       role: selectedRole
//
//
//     );
// //if login is success  user has been created navigate to the next page
// //   otherwise show the error messAGE
//     if (res == "success") {
//       setState(() {
//         isLoading=true;
//         // Fetch user role from Firestore
//         User? user = FirebaseAuth.instance.currentUser;
//         String userRole = await AuthService().getUserRole(user!.uid);
//
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
//         isLoading=false;
//       });
// // show the error message
//       showSnackBar(context, res);
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery
//         .of(context)
//         .size
//         .height;
//
//     // TODO: implement build
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: SafeArea(
//           child: SizedBox(
//           child: Column(
//           children: [
//           SizedBox(width: double.infinity, height: height / 2.7,
//           child: Image.asset("assets/login2.png")),
//               TextfieldInput(
//               textEditingController: emailController,
//               hintText: "Enter your email",
//               icon: Icons.email,
//
//
//               ),
//               TextfieldInput(
//               textEditingController: passwordController,
//               hintText: "Enter your password",
//               isPass: true,
//               icon: Icons.lock,
//               ),
//               Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 35.0),
//               child: Align(alignment: Alignment.center,
//               child: Text("Forgot Password?", style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: Colors.lightGreen),),
//               ),
//               ),
//               MyButton(onTab:loginUser, text:"Log In"),
//               SizedBox(height: height/15,),
//               Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//               const Text("Don't have an Account? ",style: TextStyle(fontSize: 16),),
//               GestureDetector(
//               onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen(),
//               ),
//                 );
//               },
//
//               child: const Text("SignUp",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
//
//               )
//               ],
//
//               )]
//               )
//               ,
//               )
//               ),
//         )
//     );
//     }
//   }