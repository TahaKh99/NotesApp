import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:map_exam/edit_screen.dart';
import 'package:map_exam/helpers/utils.dart';
import 'package:map_exam/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userID = FirebaseAuth.instance.currentUser!.uid;
  int? selectedNoteIndex;
  bool showDetails = true;
  String? noteID;




  Future<List<Note>> fetchNotes() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection("notes")
        .get();

    List<Note> notes = snapshot.docs.map((doc) {
      var note = Note.fromJson(doc.data());
      note.id = doc.id;
      return note;
    }).toList();

    return notes;
  }

  void _openEditScreen(BuildContext context, {Note? note, String mode = 'view'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditScreen(note: note, mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          _buildNoteCount(context),
        ],
      ),
      body: ListView(

        children: [
          _buildNoteList(),
        ],
      ),
      drawer: Utils.buildDrawer(context),
      floatingActionButton: _buildFloatingActionButtons(context),
    );
  }

  Widget _buildNoteCount(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userID).collection("notes").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        final noteCount = snapshot.data?.docs.length ?? 0;
        return Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade200,
            child: Text(
              '$noteCount',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
            ),
          ),
        );
      },
    );
  }



  Widget _buildNoteList() {
    return FutureBuilder<List<Note>>(
      future: fetchNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data;
        if (notes == null || notes.isEmpty) {
          return const Center(child: Text('No notes available.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            var note = notes[index];
            noteID = note.id;
            bool isLongPressed = selectedNoteIndex == index;
            bool isLastNote = index == notes.length - 1;

            return Column(
              children: [
                ListTile(
                  trailing: SizedBox(
                    width: isLongPressed? 110.0:20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        Visibility(
                          visible: isLongPressed,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _openEditScreen(context, note: notes[index], mode: 'edit');
                            },
                          ),
                        ),

                        Visibility(
                          visible: isLongPressed,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.blue),
                            onPressed: () {
                              // Delete the selected note from Firestore
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userID)
                                  .collection("notes").doc(note.id).delete();
                              setState(() {

                              });

                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(note.title ?? ''),
                  subtitle: showDetails? Text(note.content ?? ''):
                  null,

                  onTap: () {
                    _openEditScreen(context, note: notes[index], mode: 'view');

                  },
                  onLongPress: () {
                    setState(() {
                      selectedNoteIndex = isLongPressed ? null : index;
                    });
                  },
                ),
                if (!isLastNote)
                  const Divider( // Add a divider after each ListTile except for the last one
                    thickness: 1,
                  ),
              ],
            );
          },
        );
      },
    );
  }



  Widget _buildFloatingActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "showDetails",
          key: UniqueKey(), // Unique key for the first FloatingActionButton
          child: showDetails? const Icon(Icons.close_fullscreen): const Icon(Icons.menu),
          tooltip: 'Show less. Hide notes content',
          onPressed: () {
            setState(() {
              showDetails = !showDetails;
            });
          },
        ),
        const SizedBox(width: 16), // Add some space between the FloatingActionButtons
        FloatingActionButton(
          heroTag: "Edit",
          key: UniqueKey(), // Unique key for the second FloatingActionButton
          child: const Icon(Icons.add),
          tooltip: 'Add a new note',
          onPressed: () {
            // Navigate to the EditScreen to add a new note
            _openEditScreen(context, mode: 'add');
            },
        ),
      ],
    );
  }
}