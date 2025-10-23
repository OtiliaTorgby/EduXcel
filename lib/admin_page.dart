import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem(Icons.dashboard, 'Dashboard'),
            _buildMenuItem(Icons.school, 'Programs'),
            _buildMenuItem(Icons.people, 'Learners'),
            _buildMenuItem(Icons.announcement, 'Announcements'),
            _buildMenuItem(Icons.settings, 'Settings'),
          ],
        ),
      ),

      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      //  Main Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EduXcel Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Row 1: Active Learners + Engagement
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _DashboardCard(title: 'Active Learners', icon: Icons.pie_chart),
                _DashboardCard(title: 'Engagement', icon: Icons.bar_chart),
              ],
            ),
            const SizedBox(height: 16),

            // Row 2: Active Programs + Rate of Completion
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _DashboardCard(
                  title: 'Active Programs',
                  icon: Icons.insert_chart,
                ),
                _DashboardCard(
                  title: 'Rate of Completion',
                  icon: Icons.show_chart,
                ),
              ],
            ),
            const SizedBox(height: 25),

            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Create New Programs'),
              ),
            ),
          ],
        ),
      ),

      //  Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
        ],
      ),
    );
  }

  //  Drawer Menu Item
  ListTile _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // You can add route navigation here later
      },
    );
  }
}

//  Dashboard Card Widget
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DashboardCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
