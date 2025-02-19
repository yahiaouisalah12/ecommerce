import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  final String productId;
  final String productOwner;

  const Chatscreen({
    super.key,
    required this.productId,
    required this.productOwner,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  late User _currentUser;
  String? _messageText;
  String? _chatId;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
        // Initialize chat after getting current user
        await _initializeChat();
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى تسجيل الدخول للدردشة مع البائع")),
        );
      }
    } catch (e) {
      print("Error getting current user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في الحصول على بيانات المستخدم: $e")),
      );
    }
  }

  Future<void> _initializeChat() async {
    if (_currentUser.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ: لا يوجد بريد إلكتروني للمستخدم")),
      );
      return;
    }

    if (widget.productOwner.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ: معلومات صاحب المنتج غير متوفرة")),
      );
      return;
    }

    try {
      // We need to get or create the user IDs for the participants
      // For the current user, we already have the UID
      String currentUserId = _currentUser.uid;
      String ownerUserId = "";

      // Try to find the owner's user ID from their email
      final ownerQuery = await _firestore
          .collection("users")
          .where('email', isEqualTo: widget.productOwner)
          .limit(1)
          .get();

      if (ownerQuery.docs.isNotEmpty) {
        ownerUserId = ownerQuery.docs.first.id;
      } else {
        // If we can't find the owner's ID, we'll use their email as a fallback
        // This isn't ideal but allows the chat to work while rules are being updated
        ownerUserId = widget.productOwner;
      }

      // Create participants array with user IDs, not emails
      List<String> participants = [currentUserId, ownerUserId]..sort();

      // Create a unique chat ID based on product and participants
      String chatIdBase = '${widget.productId}_${participants.join('_')}';

      // First check if chat exists
      final querySnapshot = await _firestore
          .collection("Chats")
          .where('chat_id', isEqualTo: chatIdBase)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _chatId = querySnapshot.docs.first.id;
          _initialized = true;
        });
        print("Existing chat found: $_chatId");
      } else {
        // Create new chat
        final docRef = await _firestore.collection("Chats").add({
          'chat_id': chatIdBase,
          'product_id': widget.productId,
          'participants': participants,
          'created_at': FieldValue.serverTimestamp(),
          'last_message': null,
          'last_message_time': null,
          'unread_count': 0,
        });

        setState(() {
          _chatId = docRef.id;
          _initialized = true;
        });
        print("New chat created: $_chatId");
      }
    } catch (e) {
      print("Error initializing chat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تهيئة المحادثة: $e")),
      );
    }
  }

  Stream<QuerySnapshot> _getMessages() {
    if (_chatId == null) return const Stream.empty();

    return _firestore
        .collection("Chats")
        .doc(_chatId)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    if (_messageText == null ||
        _messageText!.isEmpty ||
        _chatId == null ||
        _currentUser.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("خطأ: تأكد من كتابة الرسالة وتسجيل الدخول")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get receiver's user ID
      String receiverUserId = "";
      final receiverQuery = await _firestore
          .collection("users")
          .where('email', isEqualTo: widget.productOwner)
          .limit(1)
          .get();

      if (receiverQuery.docs.isNotEmpty) {
        receiverUserId = receiverQuery.docs.first.id;
      } else {
        receiverUserId = widget.productOwner; // fallback
      }

      final message = {
        'text': _messageText,
        'sender': _currentUser.email,
        'sender_name': _currentUser.displayName ?? _currentUser.email,
        'receiver': widget.productOwner,
        'senderId': _currentUser.uid, // Add this line to match rules
        'receiverId': receiverUserId, // Add receiver ID
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      // Add message to subcollection
      await _firestore
          .collection("Chats")
          .doc(_chatId)
          .collection("messages")
          .add(message);

      // Update main chat document
      await _firestore.collection("Chats").doc(_chatId).update({
        'last_message': _messageText,
        'last_message_time': FieldValue.serverTimestamp(),
        'last_sender': _currentUser.email,
        'last_sender_id': _currentUser.uid,
        'unread_count': FieldValue.increment(1),
      });

      _messageController.clear();
      setState(() {
        _messageText = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في إرسال الرسالة: $e")),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    if (_chatId == null) return;

    try {
      await _firestore
          .collection("Chats")
          .doc(_chatId)
          .collection("messages")
          .doc(messageId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حذف الرسالة بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في حذف الرسالة: $e")),
      );
    }
  }

  void _showDeleteConfirmationDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف الرسالة"),
        content: const Text("هل أنت متأكد من حذف هذه الرسالة؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              _deleteMessage(messageId);
              Navigator.of(context).pop();
            },
            child: const Text(
              "حذف",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("الدردشة مع ${widget.productOwner}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('خطأ: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("ابدأ الدردشة مع البائع"),
                        );
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final messageData =
                              message.data() as Map<String, dynamic>;
                          final messageText =
                              messageData['text'] ?? "لا يوجد نص";
                          final messageSender =
                              messageData['sender'] ?? "مرسل غير معروف";
                          final isMe = _currentUser.email == messageSender;
                          final timestamp = messageData['timestamp'] != null
                              ? (messageData['timestamp'] as Timestamp).toDate()
                              : DateTime.now();

                          // Mark message as read if you're the receiver
                          if (!isMe && messageData['read'] == false) {
                            _firestore
                                .collection("Chats")
                                .doc(_chatId)
                                .collection("messages")
                                .doc(message.id)
                                .update({'read': true});
                          }

                          return MessageBubble(
                            sender: messageSender.toString().split('@').first,
                            text: messageText,
                            isMe: isMe,
                            timestamp: timestamp,
                            onLongPress: () {
                              if (isMe) {
                                _showDeleteConfirmationDialog(message.id);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onChanged: (value) => _messageText = value,
                          decoration: InputDecoration(
                            hintText: "اكتب رسالتك هنا...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(color: Colors.orange),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Colors.orange, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final VoidCallback onLongPress;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.onLongPress,
  });

  String _formatTimestamp() {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  CircleAvatar(
                    backgroundColor: Colors.orange[200],
                    child: Text(
                      sender[0].toUpperCase(),
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.orange : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isMe)
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: const Text(
                      'أنا',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
