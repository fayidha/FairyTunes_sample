// import 'package:dupepro/bottomBar.dart';
// import 'package:dupepro/login.dart';
// import 'package:dupepro/register.dart';
// import 'package:flutter/material.dart';
//
// class Open extends StatefulWidget {
//   const Open({super.key});
//
//   @override
//   State<Open> createState() => _OpenState();
// }
//
// class _OpenState extends State<Open> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('𝐹𝒶𝒾𝓇𝓎𝒯𝓊𝓃𝑒𝓈',
//
//           style: TextStyle(color: Colors.white,fontSize: 30),
//         ),
//         backgroundColor: Color(0xFF380230), // Changed AppBar color
//       ),
//       body: Container(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RegisterPage()),
//                   );
//                 },
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(Color(0xFF380230)), // Changed button color
//                   foregroundColor: MaterialStateProperty.all(Colors.white),
//                 ),
//                 child: const Text("SignUp"),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginForm()),
//                 );
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Color(0xFF380230)), // Changed button color
//                 foregroundColor: MaterialStateProperty.all(Colors.white),
//               ),
//               child: const Text("Login"),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
