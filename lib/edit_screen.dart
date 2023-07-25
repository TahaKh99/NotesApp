import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/note.dart';

class EditScreen extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) =>  const EditScreen());

  final Note? note;
  final String mode;
  final String? userID;

  const EditScreen({Key? key,  this.note, this.mode = 'view', this.userID}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();


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
                // Perform save operation based on the mode (edit or add)
                // ...
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