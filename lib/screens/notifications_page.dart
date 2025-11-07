import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

class NotificationsPage extends StatefulWidget {
  final String role; // "admin" or "student"
  const NotificationsPage({required this.role, super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final filePath = widget.role == 'admin'
          ? 'assets/data/admin_notifications.json'
          : 'assets/data/student_notifications.json';

      final jsonString = await rootBundle.loadString(filePath);
      final List<dynamic> data = json.decode(jsonString);

      // defensive cast & normalization: ensure each item is a map and contains keys expected
      final parsed = <Map<String, dynamic>>[];
      for (var raw in data) {
        if (raw is Map<String, dynamic>) {
          final entry = Map<String, dynamic>.from(raw);
          // normalize presence of isRead and simple defaults
          if (!entry.containsKey('isRead')) entry['isRead'] = false;
          if (!entry.containsKey('title')) entry['title'] = '(No title)';
          if (!entry.containsKey('message')) entry['message'] = '';
          if (!entry.containsKey('timestamp')) entry['timestamp'] = null;
          parsed.add(entry);
        }
      }

      // Sort unread first then by timestamp (if available)
      parsed.sort((a, b) {
        final aRead = (a['isRead'] == true) ? 1 : 0;
        final bRead = (b['isRead'] == true) ? 1 : 0;
        if (aRead != bRead) return aRead - bRead; // unread first
        // if timestamps exist try to sort descending
        final aTs = a['timestamp'];
        final bTs = b['timestamp'];
        if (aTs is String && bTs is String) {
          return bTs.compareTo(aTs);
        }
        return 0;
      });

      if (!mounted) return;
      setState(() {
        notifications = parsed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load notifications';
      });
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications updated')),
      );
    }
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

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  int get _unreadCount =>
      notifications.where((n) => n['isRead'] != true).length;

  String _friendlyTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final d = DateTime.tryParse(ts.toString());
      if (d == null) return ts.toString();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return ts.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // theme colors
    const Color p1 = Color(0xFF7B1FA2);
    const Color p2 = Color(0xFF9C27B0);
    const Color p3 = Color(0xFFBA68C8);

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
          // unread badge + mark all read
          IconButton(
            onPressed: _unreadCount > 0 ? _markAllAsRead : null,
            tooltip: 'Mark all as read',
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.mark_email_read, color: Colors.white),
                if (_unreadCount > 0)
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
                        '$_unreadCount',
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [p1, p2, p3], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            onRefresh: _refreshNotifications,
            color: Colors.white,
            backgroundColor: p2.withOpacity(0.95),
            // Use CustomScrollView with Sliver so pull-to-refresh works well with collapsing header look
            child: _loading
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: CircularProgressIndicator(color: Colors.white)),
              ],
            )
                : _error != null
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 56, color: Colors.white70),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _loadNotifications,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : notifications.isEmpty
                ? ListView(
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
            )
                : ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 18),
              itemCount: notifications.length + 1, // +1 spacer at top for visual breathing room
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  // top summary card
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: _TopSummaryCard(unread: _unreadCount),
                  );
                }
                final index = idx - 1;
                final item = notifications[index];
                final isRead = item['isRead'] == true;

                // Use Dismissible for swipe actions
                return Dismissible(
                  key: ValueKey(item.hashCode ^ index),
                  direction: DismissDirection.horizontal,
                  background: _buildDismissBackground(start: true),
                  secondaryBackground: _buildDismissBackground(start: false),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // swipe right -> delete
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
                        _removeNotification(index);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification deleted')));
                      }
                      return confirm ?? false;
                    } else {
                      // Swipe left -> mark read
                      if (!isRead) {
                        _markAsRead(index);
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
                          item['title']?.toString() ?? '',
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
                              item['message']?.toString() ?? '',
                              style: TextStyle(color: isRead ? Colors.grey[700] : Colors.black87, height: 1.3),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (item['timestamp'] != null)
                                  Text(
                                    _friendlyTime(item['timestamp']),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                const Spacer(),
                                ],
                            )
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(isRead ? Icons.done_all : Icons.check_circle_outline, color: isRead ? Colors.grey : const Color(0xFF7B1FA2)),
                          tooltip: isRead ? 'Already read' : 'Mark as read',
                          onPressed: isRead ? null : () => _markAsRead(index),
                        ),
                        onTap: () {
                          // Optionally show details or mark as read
                          if (!isRead) _markAsRead(index);
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(item['title']?.toString() ?? ''),
                              content: Text(item['message']?.toString() ?? ''),
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
                  // scroll-to-top or other quick action if desired
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pull down to refresh')));
                },
                child: const Text('Refresh', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
