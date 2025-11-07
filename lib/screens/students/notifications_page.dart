import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class NotificationsPage extends StatefulWidget {
  final String role; // "admin" or "student"
  const NotificationsPage({required this.role, super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final filePath = widget.role == 'admin'
          ? 'assets/data/admin_notifications.json'
          : 'assets/data/student_notifications.json';

      final jsonString = await rootBundle.loadString(filePath);
      final List<dynamic> data = json.decode(jsonString);

      setState(() {
        notifications = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications updated')),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  // Admin: push notification dialog
  void _showPushNotificationDialog() {
    String title = '';
    String message = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Push Notification to Students'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (val) => title = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Message'),
                    maxLines: 3,
                    onChanged: (val) => message = val,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty && message.isNotEmpty) {
                  setState(() {
                    notifications.insert(0, {
                      'title': title,
                      'message': message,
                      'time': 'Just now',
                      'isRead': false,
                    });
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification pushed to students!'),
                    ),
                  );

                  Navigator.pop(ctx);

                  // In a real app, send the notification to backend here
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B1FA2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Push'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.role == 'admin'
          ? FloatingActionButton.extended(
        onPressed: _showPushNotificationDialog,
        icon: const Icon(Icons.send),
        label: const Text('Push Notification'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      )
          : null,
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
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDE7F6), // Light purple
              Color(0xFFF3E5F5), // Very light
              Color(0xFFF8BBD0), // pastel pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          color: Color(0xFF7B1FA2),
          backgroundColor: Colors.white,
          child: notifications.isEmpty
              ? ListView(
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
          )
              : ListView.builder(
            padding: const EdgeInsets.only(top: 100, bottom: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final isRead = item['isRead'] as bool;

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
                        horizontal: 16, vertical: 13),
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
                      item['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isRead
                            ? Colors.grey[600]
                            : Color(0xFF4A148C),
                        decoration:
                        isRead ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      item['message'] ?? '',
                      style: TextStyle(
                        color: isRead ? Colors.grey[700] : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isRead
                            ? Icons.done_all
                            : Icons.check_circle_outline,
                        color: isRead
                            ? Colors.grey
                            : Color(0xFF7B1FA2),
                      ),
                      tooltip: 'Mark as read',
                      onPressed:
                      isRead ? null : () => _markAsRead(index),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
