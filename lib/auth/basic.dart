// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SignInPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => SignInPageState();
// }

// class SignInPageState extends State<SignInPage> {
//   final TextEditingController _emailController = TextEditingController(
//     text: '',
//   );
//   final TextEditingController _passwordController = TextEditingController(
//     text: '',
//   );

//   Widget getSignInForm(BuildContext ctx) {
//     return ElevatedButton(
//       onPressed: () async {
//         final email = _emailController.text.trim();
//         final password = _passwordController.text.trim();
//         final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         Navigator.pop(ctx, Prov)
//       },
//       child: Text("Sign In with email+password"),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final signInForm = getSignInForm(context);
//   }
// }
