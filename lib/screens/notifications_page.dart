import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/notifications_style.dart';
import '../screens/feedback_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

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
      final String response =
      await rootBundle.loadString('assets/data/notifications.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        notifications =
            data.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } catch (e) {
      debugPrint("Failed to load notifications: $e");
    }
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(seconds: 1));

    // Reload existing notifications
    await _loadNotifications();

    // Add simulated new notification at the top
    setState(() {
      notifications.insert(0, {
        'title': 'New Announcement',
        'message': '“UI/UX Design Workshop” is happening tomorrow!',
        'time': 'Just now',
        'isRead': false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications refreshed!')),
    );
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFeedbackButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        'Notifications',
        style: NotificationStyles.appBarTextStyle,
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
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: NotificationStyles.backgroundGradient,
      child: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: Colors.white,
        backgroundColor: Colors.purpleAccent,
        child: notifications.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: NotificationStyles.emptyStateTopPadding),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.inbox_rounded,
                    color: Colors.white70,
                    size: NotificationStyles.emptyStateIconSize,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You're all caught up!",
                    style: NotificationStyles.emptyStateTextStyle,
                  ),
                ],
              ),
            ),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: NotificationStyles.listTopPadding,
            bottom: NotificationStyles.listBottomPadding,
          ),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return NotificationCard(
              notification: notifications[index],
              onMarkAsRead: () => _markAsRead(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeedbackPage()),
        );
      },
      backgroundColor: NotificationStyles.primaryPurple,
      icon: const Icon(Icons.feedback, color: Colors.white),
      label: const Text(
        'Give Feedback',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

// Notification Card Widget
class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  bool get isRead => notification['isRead'] as bool;
  String get title => notification['title'] as String;
  String get message => notification['message'] as String;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotificationStyles.cardHorizontalPadding,
        vertical: NotificationStyles.cardVerticalPadding,
      ),
      child: Card(
        elevation: NotificationStyles.cardElevation(isRead),
        shadowColor: Colors.black26,
        color: NotificationStyles.cardColor(isRead),
        shape: NotificationStyles.cardShape,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: NotificationStyles.avatarRadius,
            backgroundColor:
            NotificationStyles.avatarBackgroundColor(isRead),
            child: Icon(
              NotificationStyles.avatarIcon(isRead),
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: NotificationStyles.notificationTitleStyle(isRead),
          ),
          subtitle: Text(
            message,
            style: NotificationStyles.notificationSubtitleStyle(isRead),
          ),
          trailing: IconButton(
            icon: Icon(
              NotificationStyles.trailingIcon(isRead),
              color: NotificationStyles.trailingIconColor(isRead),
            ),
            tooltip: 'Mark as read',
            onPressed: isRead ? null : onMarkAsRead,
          ),
        ),
      ),
    );
  }
}
