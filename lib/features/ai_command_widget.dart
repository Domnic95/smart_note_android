// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// class AICommandWidget extends StatefulWidget {
//   final Function(String) onResult;

//   const AICommandWidget({super.key, required this.onResult});

//   @override
//   _AICommandWidgetState createState() => _AICommandWidgetState();
// }

// class _AICommandWidgetState extends State<AICommandWidget> {
//   final TextEditingController _promptController = TextEditingController();
//   bool _isLoading = false;
//   String? _response;

//   Future<void> _submitPrompt() async {
//     if (_promptController.text.isEmpty) {
//       setState(() {
//         _response = 'Please enter a command.';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _response = null;
//     });

//     const apiKey =
//         'sk-proj-0D0RpdNDM3sxUtfQji2IT3BlbkFJzsJmMJNRUvl2SB9Nbg4w'; // Add your API key here
//     const apiUrl = 'https://api.openai.com/v1/chat/completions';
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $apiKey',
//     };
//     final body = json.encode({
//       'model': 'gpt-3.5-turbo',
//       'messages': [
//         {'role': 'system', 'content': 'You are a helpful assistant.'},
//         {'role': 'user', 'content': _promptController.text},
//       ],
//     });

//     try {
//       final response = await _sendRequestWithRetry(apiUrl, headers, body);
//       if (response != null && response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _response = data['choices'][0]['message']['content'];
//         });
//         widget.onResult(_response!);
//         Navigator.of(context).pop(); // Close the dialog
//       } else {
//         setState(() {
//           _response = 'Failed to generate text: ${response?.reasonPhrase}';
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _response = 'Failed to generate text: $error';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<http.Response?> _sendRequestWithRetry(
//       String url, Map<String, String> headers, String body,
//       {int retries = 3, int delaySeconds = 2}) async {
//     for (int attempt = 0; attempt < retries; attempt++) {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);
//       if (response.statusCode != 429) {
//         return response;
//       }
//       await Future.delayed(Duration(seconds: delaySeconds));
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('AI Command'),
//       content: SizedBox(
//         width: 500,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             TextField(
//               controller: _promptController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your command',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _submitPrompt,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Generate'),
//             ),
//             const SizedBox(height: 16.0),
//             _response != null
//                 ? Expanded(
//                     child: SingleChildScrollView(
//                       child: Text(_response!),
//                     ),
//                   )
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }
// }
