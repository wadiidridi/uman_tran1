import 'package:flutter/material.dart';
import '../views/add_record.dart';
import '../views/meeting_List.dart';
import '../views/new_meeting.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.context,
  }) : super(key: key);

  void _onItemTapped(int index) {
    if (index == currentIndex) return; // Évite de recharger la même page

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = MeetingList();
        break;
      case 1:
        nextScreen = CreateMeetingScreen();
        break;
      case 2:
        nextScreen = addRecord();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.new_label_outlined), label: "new meeting"),
        BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Live Transcribe"),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.grey, // Couleur des onglets inactifs

      onTap: _onItemTapped,
    );
  }
}
