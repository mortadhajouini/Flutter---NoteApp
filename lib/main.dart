// main.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';

void main() {
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        hintColor: Colors.orangeAccent,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ),

      home: NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final dbHelper = DatabaseHelper();
    final noteMaps = await dbHelper.getNotes();
    setState(() {
      notes = noteMaps.map((map) => Note.fromMap(map)).toList();
    });
  }

  Future<void> _addOrEditNoteDialog({Note? note}) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final dbHelper = DatabaseHelper();
              if (note == null) {
                await dbHelper.insertNote({
                  'title': titleController.text,
                  'content': contentController.text,
                });
              } else {
                await dbHelper.updateNote({
                  'id': note.id,
                  'title': titleController.text,
                  'content': contentController.text,
                });
              }
              await _loadNotes();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteNoteDialog(int noteId) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteNote(noteId);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurple,
      ),
      body: notes.isEmpty
          ? Center(child: Text("No notes yet. Tap + to add a note."))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(
                note.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () => _addOrEditNoteDialog(note: note),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteNoteDialog(note.id!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _addOrEditNoteDialog(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
