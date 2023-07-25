import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/note.dart';

import 'home_screen.dart';

class EditScreen extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) =>  const EditScreen());

  final Note? note;
  final String mode;

  const EditScreen({Key? key,  this.note, this.mode = 'view'}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String userID = FirebaseAuth.instance.currentUser!.uid;


  @override
  void initState() {
    super.initState();
    if (widget.mode != "add"){
      _titleController.text = widget.note!.title ?? '';
      _descriptionController.text = widget.note!.content ?? '';
    }

  }


  String get screenTitle {
    switch (widget.mode) {
      case 'view':
        return 'View Note';
      case 'edit':
        return 'Edit Note';
      case 'add':
        return 'Add New Note';
      default:
        return 'View Note';
    }
  }

  bool get canEdit {
    return widget.mode == 'edit' || widget.mode == 'add';
  }



  void _saveNote() {
    String title = _titleController.text;
    String content = _descriptionController.text;

    if (widget.mode == 'add') {
      // Check if the user document exists in Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get()
          .then((userDoc) {
        if (userDoc.exists) {
          // If the user document exists, add the note to the 'notes' collection
          FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .collection('notes')
              .add({
            'title': title,
            'content': content,
          }).then((_) {
            // After saving, navigate back to the previous screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          });
        } else {
          // If the user document doesn't exist, create the user document and add the note to the 'notes' collection
          FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .set({})
              .then((_) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userID)
                .collection('notes')
                .add({
              'title': title,
              'content': content,
            }).then((_) {
              // After saving, navigate back to the previous screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
              );
            });
          });
        }
      });
    } else if (widget.mode == 'edit') {
      // Update existing note in Firestore collection for notes
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('notes')
          .doc(widget.note!.id)
          .update({
        'title': title,
        'content': content,
      }).then((_) {
        // After saving, navigate back to the previous screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Text(screenTitle),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                size: 30,
              ),
              onPressed: () {
                _saveNote();

              },
            ),
          IconButton(
            icon: const Icon(
              Icons.cancel_sharp,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              initialValue: null,
              enabled: canEdit,
              decoration: const InputDecoration(
                hintText: 'Type the title here',
              ),
              onChanged: (value) {},
            ),
            const SizedBox(height: 5),
            Expanded(
              child: TextFormField(
                controller: _descriptionController,
                enabled: canEdit,
                initialValue: null,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Type the description',
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}