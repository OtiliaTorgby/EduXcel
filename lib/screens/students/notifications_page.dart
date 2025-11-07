import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/admins/push_notifications.dart'; // Assuming this path is correct

class NotificationsPage extends StatefulWidget {
  final String role; // "admin" or "student"
  const NotificationsPage({required this.role, super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  Stream<QuerySnapshot>? _inboxStream;

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      // Set up the collection reference to the user's specific inbox subcollection
      _inboxStream = FirebaseFirestore.instance
          .collection('artifacts')
          .doc('eduxcel')
          .collection('users')
          .doc(_userId)
          .collection('inbox')
      // Order by timestamp descending (newest first)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  // ------------------------------------------------------------------
  // Firestore Interaction Methods
  // ------------------------------------------------------------------

  int _getUnreadCount(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) => (doc['isRead'] == false)).length;
  }

  /// Updates a specific document in Firestore to set isRead = true.
  void _markAsRead(DocumentReference docRef) {
    if (docRef == null) return;
    try {
      docRef.update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  /// Commits a batch write to mark all currently unread documents as read.
  Future<void> _markAllAsRead(List<QueryDocumentSnapshot> unreadDocs) async {
    if (unreadDocs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in unreadDocs) {
      batch.update(doc.reference, {'isRead': true});
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

  /// Deletes a specific document from Firestore.
  void _removeNotification(DocumentReference docRef) {
    if (docRef == null) return;
    try {
      docRef.delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete notification.')),
        );
      }
    }
  }

  /// Converts Firestore Timestamp to a friendly relative time string.
  String _friendlyTime(dynamic ts) {
    if (ts == null) return '';
    if (ts is Timestamp) {
      final d = ts.toDate();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${d.day}/${d.month}/${d.year}';
    }
    return ts.toString();
  }

  @override
  Widget build(BuildContext context) {
    const Color p1 = Color(0xFF7B1FA2);
    const Color p2 = Color(0xFF9C27B0);
    const Color p3 = Color(0xFFBA68C8);

    // Handle unauthenticated user state outside the stream
    if (_userId == null || _inboxStream == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your notifications.')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Notifications (${widget.role})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.25,
          ),
        ),
        actions: [
          // StreamBuilder for the badge and mark-all-read action state
          StreamBuilder<QuerySnapshot>(
              stream: _inboxStream,
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final unreadCount = _getUnreadCount(docs);
                final unreadDocs = docs.where((d) => d['isRead'] == false).toList();

                return IconButton(
                  onPressed: unreadCount > 0 ? () => _markAllAsRead(unreadDocs) : null,
                  tooltip: 'Mark all as read',
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.mark_email_read, color: Colors.white),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
          ),
        ],
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
      ),
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
        backgroundColor: p1,
        foregroundColor: Colors.white,
      )
          : null,

      // ------------------------------------------------------------------
      // 🎯 Main StreamBuilder for List View
      // ------------------------------------------------------------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [p1, p2, p3], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          bottom: true,
          child: StreamBuilder<QuerySnapshot>(
            stream: _inboxStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator(color: Colors.white)),
                  ],
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 56, color: Colors.white70),
                          const SizedBox(height: 12),
                          Text('Error loading notifications: ${snapshot.error}', style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              final notifications = snapshot.data?.docs ?? [];

              if (notifications.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.inbox_rounded, color: Colors.white70, size: 64),
                          SizedBox(height: 14),
                          Text("You're all caught up!", style: TextStyle(color: Colors.white70, fontSize: 18)),
                          SizedBox(height: 6),
                          Text("Pull down to refresh.", style: TextStyle(color: Colors.white60)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: () async { /* Stream handles refresh */ },
                color: Colors.white,
                backgroundColor: p2.withOpacity(0.95),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 18),
                  itemCount: notifications.length + 1, // +1 spacer at top
                  itemBuilder: (context, idx) {
                    if (idx == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: _TopSummaryCard(unread: _getUnreadCount(notifications)),
                      );
                    }
                    final index = idx - 1;
                    final doc = notifications[index];

                    final isRead = doc['isRead'] as bool? ?? false;
                    final title = doc['title']?.toString() ?? '(No title)';
                    final message = doc['message']?.toString() ?? '';
                    final timestamp = doc['timestamp'];

                    final program = doc['program']?.toString() ?? 'General';
                    final sender = doc['sender']?.toString() ?? 'System';


                    // Use Dismissible for swipe actions
                    return Dismissible(
                      key: ValueKey(doc.id), // Use Firestore Document ID as key
                      direction: DismissDirection.horizontal,
                      background: _buildDismissBackground(start: true),
                      secondaryBackground: _buildDismissBackground(start: false),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Swipe right -> delete
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Delete notification?'),
                              content: const Text('This will remove the notification.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            _removeNotification(doc.reference); // Firestore Delete
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification deleted')));
                          }
                          return confirm ?? false;
                        } else {
                          // Swipe left -> mark read
                          if (!isRead) {
                            _markAsRead(doc.reference); // Firestore Mark Read
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as read')));
                          }
                          return false; // don't dismiss (we only mark read)
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isRead ? 0.05 : 0.12),
                              blurRadius: isRead ? 6 : 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          color: isRead ? Colors.white.withOpacity(0.85) : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: isRead ? Colors.purple[100] : const Color(0xFF8E24AA),
                              child: Icon(isRead ? Icons.mark_email_read : Icons.notifications_active, color: Colors.white),
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isRead ? Colors.grey[700] : const Color(0xFF4A148C),
                                decoration: isRead ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  message,
                                  style: TextStyle(color: isRead ? Colors.grey[700] : Colors.black87, height: 1.3),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Display Sender and Program/Course
                                    Text(
                                      'From: $sender | Course: $program',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    if (timestamp != null)
                                      Text(
                                        _friendlyTime(timestamp),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                  ],
                                )
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(isRead ? Icons.done_all : Icons.check_circle_outline, color: isRead ? Colors.grey : const Color(0xFF7B1FA2)),
                              tooltip: isRead ? 'Already read' : 'Mark as read',
                              onPressed: isRead ? null : () => _markAsRead(doc.reference),
                            ),
                            onTap: () {
                              if (!isRead) _markAsRead(doc.reference);
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(title),
                                  content: Text(message),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground({required bool start}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: start ? Alignment.centerLeft : Alignment.centerRight,
      decoration: BoxDecoration(
        color: start ? Colors.redAccent.withOpacity(0.98) : Colors.green.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: start ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (start) const Icon(Icons.delete, color: Colors.white),
          if (!start) const Icon(Icons.mark_email_read, color: Colors.white),
          const SizedBox(width: 8),
          Text(start ? 'Delete' : 'Mark as read', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _TopSummaryCard extends StatelessWidget {
  final int unread;
  const _TopSummaryCard({required this.unread});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = math.min(width - 24, 760.0);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  unread > 0 ? 'You have $unread unread notification${unread > 1 ? 's' : ''}' : 'No unread notifications',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pull down to refresh')));
                },
                child: const Text('Refresh', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}