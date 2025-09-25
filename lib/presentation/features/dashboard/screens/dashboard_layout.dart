import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taski/core/utils/navigator.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/chat/screens/chat_history_screen.dart';
import 'package:taski/presentation/features/contacts/screens/contacts_screen.dart';
import 'package:taski/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:taski/presentation/features/dashboard/widgets/side_menu.dart';
import 'package:taski/presentation/features/notifications/screens/notifications_screen.dart';
import 'package:taski/presentation/features/profile/screens/profile_screen.dart';
import 'package:taski/presentation/features/tasks/screens/tasks_screen.dart';
import 'package:taski/presentation/features/calendar/screens/calendar_screen.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final PageController _pageController = PageController(
    keepPage: true,
    initialPage: 0
  );
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Calendar";
      case 2:
        return "Tasks";
      case 3:
        return "Communication";
      case 4:
        return "Profile";
      case 5:
        return "Contacts";
      case 6:
        return "Help";
      case 7:
        return "Settings";
      default:
        return "Dashboard";
    }
  }

  @override
  void initState() {
    Permission.microphone.request();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FirebaseAuth.instance.currentUser?.getIdToken().then((val) {
        logger.i("User Token: $val");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _getPageTitle(_selectedIndex),
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: config.sp(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              push(NotificationScreen());
            },
          ),
          IconButton(
            icon: Icon(Icons.history_outlined),
            onPressed: () {
              push(ChatHistoryScreen());
            },
          ),
        ],
      ),
      drawer: SideMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          Navigator.pop(context); // Close drawer
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          DashboardScreen(
            onPageChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          CalendarScreen(),
          TasksScreen(),
          Container(
            child: Center(
              child: Text(
                "Communication",
                style: textTheme.headlineMedium,
              ),
            ),
          ),
          ProfileScreen(),
          ContactsScreen(),
          Container(
            child: Center(
              child: Text(
                "Help",
                style: textTheme.headlineMedium,
              ),
            ),
          ),
          Container(
            child: Center(
              child: Text(
                "Settings",
                style: textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}