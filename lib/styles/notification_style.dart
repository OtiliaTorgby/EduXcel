import 'package:flutter/material.dart';

class NotificationStyles {
  // Prevent instantiation
  NotificationStyles._();

  // Typography
  static const double appBarFontSize = 22.0;
  static const double appBarLetterSpacing = 0.5;
  static const double emptyStateFontSize = 16.0;

  // Spacing & Sizing
  static const double emptyStateIconSize = 60.0;
  static const double emptyStateTopPadding = 250.0;
  static const double listTopPadding = 100.0;
  static const double listBottomPadding = 16.0;
  static const double cardHorizontalPadding = 16.0;
  static const double cardVerticalPadding = 8.0;
  static const double cardBorderRadius = 16.0;
  static const double avatarRadius = 25.0;

  // Colors
  static const List<Color> gradientColors = [
    Color(0xFF7B1FA2),
    Color(0xFF9C27B0),
    Color(0xFFBA68C8),
  ];

  static const Color primaryPurple = Color(0xFF8E24AA);
  static const Color darkPurple = Color(0xFF4A148C);
  static const Color accentPurple = Color(0xFF7B1FA2);

  // Text Styles
  static const TextStyle appBarTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: appBarFontSize,
    color: Colors.white,
    letterSpacing: appBarLetterSpacing,
  );

  static const TextStyle emptyStateTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: emptyStateFontSize,
  );

  static TextStyle notificationTitleStyle(bool isRead) => TextStyle(
    fontWeight: FontWeight.w600,
    color: isRead ? Colors.grey[600] : darkPurple,
    decoration: isRead ? TextDecoration.lineThrough : null,
  );

  static TextStyle notificationSubtitleStyle(bool isRead) => TextStyle(
    color: isRead ? Colors.grey[700] : Colors.black87,
    height: 1.3,
  );

  // Decorations
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: gradientColors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static ShapeBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardBorderRadius),
  );

  // Card styling
  static Color cardColor(bool isRead) => isRead
      ? Colors.white.withOpacity(0.7)
      : Colors.white.withOpacity(0.95);

  static double cardElevation(bool isRead) => isRead ? 1.0 : 4.0;

  // Avatar styling
  static Color avatarBackgroundColor(bool isRead) => isRead
      ? Colors.purple[200]!
      : primaryPurple;

  static IconData avatarIcon(bool isRead) => isRead
      ? Icons.mark_email_read
      : Icons.notifications_active;

  // Trailing button styling
  static IconData trailingIcon(bool isRead) => isRead
      ? Icons.done_all
      : Icons.check_circle_outline;

  static Color trailingIconColor(bool isRead) => isRead
      ? Colors.grey
      : accentPurple;
}