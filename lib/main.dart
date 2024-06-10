import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';
import 'homescreen_page.dart'; 
import 'package:provider/provider.dart';
import 'state_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreenPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _loadItemsFromDatabase();
  }

  Future<void> _loadItemsFromDatabase() async {
    final loadedItems = await DatabaseHelper.getItems();
    // Menggunakan Provider untuk memperbarui state
    Provider.of<NoteProvider>(context, listen: false).latestNotes = loadedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'ReminderIt!',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Hero(
                tag: 'imageHero',
                child: Image.asset('assets/main.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            if (Provider.of<NoteProvider>(context).latestNotes.isNotEmpty)
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Latest Note',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      for (final note
                          in Provider.of<NoteProvider>(context).latestNotes)
                        Text(
                          note['title'] ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              )
            else
              const Text(
                'No notes available.',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddPage();
                })).then((_) {
                  _loadItemsFromDatabase(); // Refresh data after returning from AddPage
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SeePage();
                })).then((_) {
                  _loadItemsFromDatabase(); // Refresh data after returning from SeePage
                });
              },
              child: const Text('See'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddPage();
          })).then((_) {
            _loadItemsFromDatabase(); // Refresh data after returning from AddPage
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveNote();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() async {
  final title = _titleController.text;
  final description = _descriptionController.text;

  if (title.isNotEmpty || description.isNotEmpty) {
    await DatabaseHelper.createItem(title, description);

    // Menggunakan Provider untuk memperbarui state
    Provider.of<NoteProvider>(context, listen: false).latestNotes = await DatabaseHelper.getItems();

    Navigator.pop(context); // Menutup AddPage setelah menyimpan
  } else {
    // Menampilkan snackbar atau alert bahwa judul atau deskripsi diperlukan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Title or description cannot be empty!'),
      ),
    );
  }
}


}

class SeePage extends StatefulWidget {
  const SeePage({Key? key}) : super(key: key);

  @override
  _SeePageState createState() => _SeePageState();
}

class _SeePageState extends State<SeePage> {
  DateTime today = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    today = day;
    _loadAllNotes();
  }

  Future<void> _loadAllNotes() async {
    final loadedNotes = await DatabaseHelper.getItems();
    Provider.of<NoteProvider>(context, listen: false).latestNotes = loadedNotes;
  }

  void _editNote(int index) {
  titleController.text = Provider.of<NoteProvider>(context, listen: false)
          .latestNotes[index]['title'] ??
      '';
  descriptionController.text = Provider.of<NoteProvider>(context, listen: false)
          .latestNotes[index]['description'] ??
      '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                Navigator.of(context).pop();
                // Ambil ID catatan yang akan diupdate
                final idToUpdate = Provider.of<NoteProvider>(context, listen: false)
                    .latestNotes[index]['id'];

                // Perbarui catatan di database
                await DatabaseHelper.updateItem(idToUpdate, titleController.text, descriptionController.text);

                // Perbarui state menggunakan Provider setelah update database
                Provider.of<NoteProvider>(context, listen: false).latestNotes =
                    await DatabaseHelper.getItems();
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}



  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDelete(index);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performDelete(int index) async {
  final allNotes = Provider.of<NoteProvider>(context, listen: false).latestNotes;
  
  if (index >= 0 && index < allNotes.length) {
    final idToDelete = allNotes[index]['id'];
    
    await DatabaseHelper.deleteItem(idToDelete);

    // Menggunakan Provider untuk memperbarui state
    Provider.of<NoteProvider>(context, listen: false).latestNotes = await DatabaseHelper.getItems();
  }
}



  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> allNotes =
        Provider.of<NoteProvider>(context).latestNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome To Your Daily Task. Always ReminderIt!"),
      ),
      body: content(allNotes),
    );
  }

  Widget content(List<Map<String, dynamic>> allNotes) {
    return Column(
      children: [
        Text('Selected Day = ' + today.toString().split(" ")[0]),
        Container(
          child: TableCalendar(
            locale: "en_US",
            rowHeight: 43,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2000, 01, 01),
            lastDay: DateTime.utc(2030, 12, 31),
            onDaySelected: _onDaySelected,
          ),
        ),
        const SizedBox(height: 16),
        if (allNotes.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(allNotes[index]['title'] ?? ''),
                    subtitle: Text(allNotes[index]['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editNote(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteNote(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          const Text(
            'No notes available for the selected day.',
            style: TextStyle(fontSize: 16),
          ),
      ],
    );
  }
}

