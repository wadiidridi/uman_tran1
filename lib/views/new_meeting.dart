import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:meeting/views/playback.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';
import '../services/meeting_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'add_record.dart';
import 'audio_upload.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({Key? key}) : super(key: key);

  @override
  _CreateMeetingScreenState createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sujetController = TextEditingController();
  final _heureController = TextEditingController();
  final _dateController = TextEditingController();
  final MeetingService _meetingService = MeetingService();

  String? _userId;
  int?
      _selectedParticipants; // Valeur sélectionnée pour le nombre de participants

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  void _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null) {
      _showErrorDialog(context, "User ID not found");
      return;
    }

    if (_selectedParticipants == null) {
      _showErrorDialog(context, "Please select the number of participants");
      return;
    }

    if (_selectedDepartements.isEmpty) {
      _showErrorDialog(context, "Please select at least one department");
      return;
    }

    final meeting = Meeting(
      id: "",
      sujetReunion: _sujetController.text,
      heure: _heureController.text,
      nombreParticipants: _selectedParticipants!,
      date: _dateController.text,
      userId: _userId!,
      audio: "",
      transcriptionLocuteur: "",
      resume: "",
      departements: _selectedDepartements,
    );

    try {
      await _meetingService.createMeeting(meeting);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meeting created successfully!")),
      );

      // 🔥 Afficher la popup
      _showAudioOptionsDialog();
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }
  List<String> _selectedDepartements = [];
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      final selectedFilePath = result.files.single.path!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaybackScreen(audioFilePath: selectedFilePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun fichier sélectionné.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a New Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _sujetController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Champ de sélection de la date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today), // Icône de calendrier
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    setState(() {
                      _dateController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Champ de sélection de l'heure avec une icône
              TextFormField(
                controller: _heureController,
                readOnly: true, // Empêche la saisie manuelle
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: const OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time), // Icône d'horloge
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    // Formate l'heure sélectionnée
                    String formattedTime =
                        "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                    setState(() {
                      _heureController.text = formattedTime;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Liste déroulante pour le nombre de participants
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Number of Participants',
                  border: OutlineInputBorder(),
                ),
                value: _selectedParticipants,
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} Participants'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedParticipants = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select the number of participants';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              MultiSelectDialogField(
                items: ["RH", "Finance", "Digital", "Marketing"]
                    .map((category) =>
                        MultiSelectItem<String>(category, category))
                    .toList(),
                title: const Text("Select Categories"),
                selectedColor: Colors.black,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                buttonText: const Text("Categories"),
                dialogHeight: 250,
                onConfirm: (values) {
                  setState(() {
                    _selectedDepartements = values.cast<String>();
                  });
                },
                chipDisplay: MultiSelectChipDisplay(
                  chipColor: Colors.grey[300],
                  textStyle: const TextStyle(color: Colors.black),
                  onTap: (value) {
                    setState(() {
                      _selectedDepartements.remove(value);
                    });
                  },
                ),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _createMeeting,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  'Confirmer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Onglet actif : History
        context: context,
      ),
    );
  }
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  void _showAudioOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Meeting Created!"),
        content: const Text(
          "Would you like to record a new audio or upload an existing one?",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.28, // Réduit un peu la largeur
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload, size: 18, color: Colors.white),
                  onPressed: _pickAudioFile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  label: const Text('Upload', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.28,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.mic_none_rounded, size: 18, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddRecord()),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  label: const Text('Record', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
