import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationPage extends StatefulWidget {
  const PushNotificationPage({super.key});

  @override
  State<PushNotificationPage> createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  final TextEditingController _messageController = TextEditingController();

  String? _selectedTemplateId;
  String? _selectedProgram;
  String? _selectedType = "Student";

  List<Map<String, dynamic>> _templates = [];
  bool _loadingTemplates = true;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  /// Fetch default templates from Firestore (notifications collection)
  Future<void> _fetchTemplates() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('eduxcel')
          .collection('notifications')
          .get();

      setState(() {
        _templates = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id,
            "title": data["title"] ?? "Untitled",
            "message": data["message"] ?? "",
            "type": data["type"] ?? "Student", // Default to Student if not set
          };
        }).toList();
        _loadingTemplates = false;
      });

      debugPrint("✅ Loaded ${_templates.length} templates");
      for (var template in _templates) {
        debugPrint("Template: ${template['id']} - ${template['title']}");
      }
    } catch (e) {
      debugPrint("❌ Error loading notification templates: $e");
      setState(() => _loadingTemplates = false);

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    }
  }

  /// Fetch all programs from artifacts/eduxcel/courses
  Future<List<String>> _fetchPrograms() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('eduxcel')
          .collection('courses')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint("❌ Error loading programs: $e");
      return [];
    }
  }

  /// Send a new notification to all users matching criteria
  Future<void> _sendNotification() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    try {
      final usersQuery = FirebaseFirestore.instance
          .collection('artifacts')
          .doc('eduxcel')
          .collection('users');
      Query filteredQuery = usersQuery.where('role', isEqualTo: _selectedType);

      // If a specific program is selected, filter users by program
      if (_selectedProgram != null && _selectedProgram!.isNotEmpty) {
        filteredQuery =
            filteredQuery.where('program', isEqualTo: _selectedProgram);
      }

      final usersSnapshot = await filteredQuery.get();

      if (usersSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No users found matching criteria')),
        );
        return;
      }

      final batch = FirebaseFirestore.instance.batch();

      // Get template title safely
      String notificationTitle = "General Notification";
      if (_selectedTemplateId != null) {
        try {
          final selectedTemplate = _templates.firstWhere(
                (t) => t["id"] == _selectedTemplateId,
            orElse: () => {"title": "General Notification"},
          );
          notificationTitle = selectedTemplate["title"] ?? "General Notification";
        } catch (e) {
          debugPrint("⚠️ Error finding template: $e");
        }
      }

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        final notifRef = FirebaseFirestore.instance
            .collection('artifacts')
            .doc('eduxcel')
            .collection('users')
            .doc(userId)
            .collection('inbox')
            .doc();

        batch.set(notifRef, {
          'title': notificationTitle,
          'message': message,
          'program': _selectedProgram ?? '',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'sender': 'Admin',
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification sent to ${usersSnapshot.docs.length} users'),
        ),
      );

      _messageController.clear();
      setState(() {
        _selectedProgram = null;
        _selectedTemplateId = null;
      });
    } catch (e) {
      debugPrint("❌ Error sending notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE7F6),
        title: const Text(
          'Push Notifications',
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFF8BBD0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 Notification Templates
              const Text(
                "Select Default Notification",
                style: TextStyle(
                    color: Color(0xFF4A148C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              _loadingTemplates
                  ? const Center(child: CircularProgressIndicator())
                  : _templates.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "No templates found in Firestore",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : DropdownButtonFormField<String>(
                value: _selectedTemplateId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _templates.map((template) {
                  return DropdownMenuItem<String>(
                    value: template["id"],
                    child: Text(template["title"] ?? "Untitled"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTemplateId = value;
                    try {
                      final selected = _templates.firstWhere(
                            (t) => t["id"] == value,
                        orElse: () => {
                          "message": "",
                          "type": "Student"
                        },
                      );
                      _messageController.text =
                          selected["message"] ?? "";
                      _selectedType =
                          selected["type"] ?? "Student";
                    } catch (e) {
                      debugPrint("⚠️ Error selecting template: $e");
                    }
                  });
                },
                hint: const Text("Choose template"),
              ),

              const SizedBox(height: 20),

              // 🔹 Program Dropdown
              const Text(
                "Select Program (optional)",
                style: TextStyle(
                    color: Color(0xFF4A148C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<String>>(
                future: _fetchPrograms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text("Error loading programs",
                        style: TextStyle(color: Colors.red));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No programs found");
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedProgram,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: snapshot.data!
                        .map((program) => DropdownMenuItem<String>(
                      value: program,
                      child: Text(program),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedProgram = value);
                    },
                    hint: const Text("Select Program"),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Custom Message
              const Text(
                "Message",
                style: TextStyle(
                    color: Color(0xFF4A148C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Type or edit your message...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Send To
              const Text(
                "Send To",
                style: TextStyle(
                    color: Color(0xFF4A148C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "Student", child: Text("Students")),
                  DropdownMenuItem(value: "Admin", child: Text("Admins")),
                ],
                onChanged: (value) => setState(() => _selectedType = value),
              ),

              const SizedBox(height: 30),

              // 🔹 Send Button
              ElevatedButton.icon(
                onPressed: _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Send Notification",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}