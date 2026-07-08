// import 'package:flutter/material.dart';
// import 'package:popbom/features/home/ui/screen/text_voice_video_screen.dart';
//
// class FreeTrialScreen extends StatelessWidget {
//   const FreeTrialScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title
//               const Text(
//                 "Start your FREE trials",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Bullet points
//               const Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "• ",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   Expanded(
//                     child: Text(
//                       "voice to video generator",
//                       style: TextStyle(color: Colors.white, fontSize: 17),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 10),
//
//               const Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "• ",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   Expanded(
//                     child: Text(
//                       "try first 5 free trial",
//                       style: TextStyle(color: Colors.white, fontSize: 17),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 120),
//
//               // Agree button
//               Center(
//                 child: SizedBox(
//                   width: 440,
//                   height: 44,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.greenAccent.shade400,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => TextVoiceVideoScreen(),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "Agree & Continue",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
