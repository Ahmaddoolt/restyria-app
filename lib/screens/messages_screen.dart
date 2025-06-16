import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _secureStorage = const FlutterSecureStorage();
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _secureStorage.read(key: 'email');
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> _deleteMessage(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(docId)
          .delete();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message deleted successfully!'.tr)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text('Messages'.tr),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('userEmail', isEqualTo: _userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No messages available.'.tr),
            );
          }

          // Convert messages to a list and sort manually
          final messages = snapshot.data!.docs.toList();
          messages.sort((a, b) {
            final timeA = (a['timestamp'] as Timestamp).toDate();
            final timeB = (b['timestamp'] as Timestamp).toDate();
            return timeB.compareTo(timeA); // Sorts in descending order
          });

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final messageId = message.id;
              final messageText = message['message'] ?? 'No message';
              final timestamp = (message['timestamp'] as Timestamp).toDate();

              return Card(
                color: mainColor2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    messageText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${timestamp.toLocal()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteMessage(messageId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
