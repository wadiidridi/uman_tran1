import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import '../services/meeting_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'new_meeting.dart';

class MeetingList extends StatefulWidget {
  @override
  _MeetingListState createState() => _MeetingListState();
}

class _MeetingListState extends State<MeetingList> {
  final MeetingService _meetingService = MeetingService();
  late Future<List<Meeting>> _meetings;

  @override
  void initState() {
    super.initState();
    _reloadMeetings();
  }

  void _reloadMeetings() {
    setState(() {
      _meetings = _meetingService.fetchMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Decifer',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Action pour se déconnecter
            },
            child: Text(
              'Sign out',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                IconButton(
                  icon: Icon(Icons.add, color: Colors.black, size: 36),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateMeetingScreen()),
                    ).then((_) => _reloadMeetings());
                  },
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Transcriptions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Meeting>>(
                future: _meetings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucune réunion trouvée.'));
                  } else {
                    final meetings = snapshot.data!;
                    return ListView.builder(
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return buildTranscriptionCard(
                          title: meeting.sujetReunion ?? 'Sans titre',
                          description: 'Date : ${meeting.date ?? 'N/A'}',
                        );
                      },
                    );
                  }
                },
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Onglet actif : History
        context: context,
      ),
    );
  }

  Widget buildTranscriptionCard({required String title, required String description}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.black26),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
