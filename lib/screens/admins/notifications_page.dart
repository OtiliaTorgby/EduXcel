import 'dart:convert';
import 'package:flutter/material.dart';
// Removed unused: import 'package:flutter/services.dart' show rootBundle;
// Removed unused: import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // Needed to get the current user ID
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Firestore
import '/screens/admins/push_notifications.dart';

class NotificationsPage extends StatefulWidget {
  final String role; // "admin" or "student"
  const NotificationsPage({required this.role, super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // Firestore reference for the user's inbox
  CollectionReference? _inboxCollection;

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      // Set up the collection reference to the user's specific inbox subcollection
      _inboxCollection = FirebaseFirestore.instance
          .collection('artifacts')
          .doc('eduxcel')
          .collection('users')
          .doc(_userId)
          .collection('inbox');
    }
  }

  // ------------------------------------------------------------------
  // Firestore Operations (Batch Writes for Read Status)
  // ------------------------------------------------------------------

  Future<void> _markAllAsRead(List<QueryDocumentSnapshot> unreadDocs) async {
    if (unreadDocs.isEmpty || _inboxCollection == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // Only update documents where 'isRead' is currently false
    for (var doc in unreadDocs) {
      // Ensure we are only adding the update for documents that need it
      if (doc['isRead'] == false) {
        batch.update(doc.reference, {'isRead': true});
      }
    }

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void _markAsRead(DocumentReference docRef) {
    if (docRef == null) return;
    try {
      // Direct update to Firestore
      docRef.update({'isRead': true});
      // The StreamBuilder handles the UI refresh automatically
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  // NOTE: _loadNotifications and _refreshNotifications logic is now handled by StreamBuilder

  @override
  Widget build(BuildContext context) {
    if (_userId == null || _inboxCollection == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in or ID is missing.'),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.role == 'admin'
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PushNotificationPage(),
            ),
          );
        },
        icon: const Icon(Icons.send),
        label: const Text('Push Notification'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      )
          : null,

      // ------------------------------------------------------------------
      // 🎯 StreamBuilder for Real-time Notifications
      // ------------------------------------------------------------------
      body: StreamBuilder<QuerySnapshot>(
        stream: _inboxCollection!.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          // 1. Connection State (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7B1FA2)));
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data?.docs ?? [];
          final unreadDocs = notifications.where((doc) => doc['isRead'] == false).toList();

          // Update AppBar actions to use the unreadDocs list
          // This requires placing the AppBar inside the StreamBuilder, or extracting
          // the AppBar/Scaffold logic. For simplicity, we update the main AppBar.

          // We can force a rebuild or handle the button state externally, but since
          // the AppBar is outside the StreamBuilder, let's keep the logic simple
          // and rely on the UI update/user interaction.

          // We will update the Scaffold actions logic to use the fetched list
          final Widget actionButton = TextButton(
            onPressed: () => _markAllAsRead(unreadDocs),
            child: Text(
              'Mark all as read (${unreadDocs.length})',
              style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
            ),
          );

          // 3. Empty State
          if (notifications.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 250),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded,
                          color: Color(0xFF7B1FA2), size: 60),
                      SizedBox(height: 14),
                      Text(
                        'You’re all caught up!',
                        style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // 4. Data State (ListView)
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEDE7F6),
                  Color(0xFFF3E5F5),
                  Color(0xFFF8BBD0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            // RefreshIndicator is not strictly needed with StreamBuilder, but harmless
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 16), // Adjusted padding
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final doc = notifications[index];
                final isRead = doc['isRead'] as bool? ?? false; // Safer access

                // Safely format timestamp
                final Timestamp timestamp = doc['timestamp'] as Timestamp;
                final dateTime = timestamp.toDate();
                final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: isRead ? 1 : 4,
                    shadowColor: Colors.deepPurple,
                    color: isRead
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFFF3E5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: isRead
                            ? Colors.purple[200]
                            : const Color(0xFF7B1FA2),
                        child: Icon(
                          isRead
                              ? Icons.mark_email_read
                              : Icons.notifications_active,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        doc['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isRead
                              ? Colors.grey[600]
                              : const Color(0xFF4A148C),
                          decoration:
                          isRead ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['message'] ?? 'No message content.',
                            style: TextStyle(
                              color: isRead ? Colors.grey[700] : Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Display time and sender/program
                          Text(
                            '${doc['sender'] ?? 'System'} | ${doc['program'] ?? 'General'} | $timeString',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isRead
                              ? Icons.done_all
                              : Icons.check_circle_outline,
                          color: isRead
                              ? Colors.grey
                              : const Color(0xFF7B1FA2),
                        ),
                        tooltip: 'Mark as read',
                        // Pass the document reference for the update
                        onPressed: isRead ? null : () => _markAsRead(doc.reference),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // We must define the AppBar outside the StreamBuilder but use logic derived from it.
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFFEDE7F6),
        title: Text(
          widget.role == 'admin'
              ? 'Notifications Admin'
              : 'Notifications Student',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF4A148C),
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // This will be static, but it will trigger the StreamBuilder to update the list.
          // The actual marking logic is inside the StreamBuilder's builder.
          // Since we can't easily pass the list out, we'll create a simple button here
          // and let the user interact to trigger the final commit.
          // ⭐ Since we can't pass the unreadDocs list out, we rely on the StreamBuilder
          // to provide the UI count, and we will place a simplified button here.
          TextButton(
            onPressed: () {
              // A simplified way to trigger a full read batch: fetch the docs again and commit
              _inboxCollection?.where('isRead', isEqualTo: false).get().then((snapshot) {
                _markAllAsRead(snapshot.docs);
              });
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}