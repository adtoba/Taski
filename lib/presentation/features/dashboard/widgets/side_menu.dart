import 'package:flutter/material.dart';
import 'package:taski/core/services/google_auth_service.dart';
import 'package:taski/core/utils/navigator.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/auth/screens/auth_screen.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return SafeArea(
      child: Container(
        width: 280,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: config.sw(20), vertical: config.sh(24)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person, color: Colors.blue.shade700),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "John Doe",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600, 
                          ),
                        ),
                        Text(
                          "john.doe@example.com",
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: isDark ? const Color(0xFF333333) : Colors.grey.shade200),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: config.sh(8)),
                children: [
                  _MenuItem(
                    icon: Icons.dashboard_outlined,
                    title: "Dashboard",
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: "Calendar",
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  _MenuItem(
                    icon: Icons.task_alt_outlined,
                    title: "Tasks",
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  _MenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: "Communication",
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: "Profile",
                    isSelected: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                  _MenuItem(
                    icon: Icons.contacts_outlined,
                    title: "Contacts",
                    isSelected: selectedIndex == 5,
                    onTap: () => onItemSelected(5),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: "Help",
                    isSelected: selectedIndex == 6,
                    onTap: () => onItemSelected(6),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    isSelected: selectedIndex == 7,
                    onTap: () => onItemSelected(7),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: Colors.grey.shade200),
            
            // Logout Button
            Padding(
              padding: EdgeInsets.all(config.sw(20)),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle logout
                    GoogleAuthService.signOut();
                    push(AuthScreen());
                  },
                  icon: Icon(Icons.logout, size: 20),
                  label: Text("Logout"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: config.sw(20),
            vertical: config.sh(12),
          ),
          decoration: BoxDecoration(
            color: isSelected ? isDark ? const Color(0xFF2A2A2A) : Colors.blue.shade50 : Colors.transparent,
            border: Border(
              right: BorderSide(
                color: isSelected ? Colors.blue.shade500 : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue.shade600 : isDark ? Colors.white : Colors.grey.shade600,
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.blue.shade600 : isDark ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 