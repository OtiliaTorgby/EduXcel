import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class NotificationsPage extends StatefulWidget {
  final String role; // “admin” or “student”
  const NotificationsPage({required this.role, Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notifications (${widget.role})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFBA68C8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          color: Colors.white,
          backgroundColor: Colors.purpleAccent,
          child: notifications.isEmpty
              ? ListView(
            children: const [
              SizedBox(height: 250),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        color: Colors.white70, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'You’re all caught up!',
                      style:
                      TextStyle(color: Colors.white70, fontSize: 16),
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
                  shadowColor: Colors.black26,
                  color: isRead
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: isRead
                          ? Colors.purple[200]
                          : const Color(0xFF8E24AA),
                      child: Icon(
                        isRead
                            ? Icons.mark_email_read
                            : Icons.notifications_active,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      item['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isRead
                            ? Colors.grey[600]
                            : const Color(0xFF4A148C),
                        decoration: isRead
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      item['message']!,
                      style: TextStyle(
                        color:
                        isRead ? Colors.grey[700] : Colors.black87,
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
                            : const Color(0xFF7B1FA2),
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
