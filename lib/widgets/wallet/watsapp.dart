// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class WhatsAppChatButton extends StatelessWidget {
//   final String phoneNumber = "+1234567890"; // Enter your WhatsApp phone number with country code
//   final String message = "Hello, I would like to chat with you"; // Pre-filled message
//
//   // Function to open WhatsApp
//   void openWhatsApp(BuildContext context) async {
//     final whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
//
//     // Check if WhatsApp can be launched
//     if (await canLaunch(whatsappUrl)) {
//       await launch(whatsappUrl);
//     } else {
//       // If WhatsApp is not installed or can't be launched, show an error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("WhatsApp is not installed or can't be launched")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Open WhatsApp Chat'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => openWhatsApp(context), // Call the WhatsApp function on button press
//           child: Text('Chat on WhatsApp'),
//         ),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: WhatsAppChatButton(),
//   ));
// }
