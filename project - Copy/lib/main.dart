import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//-----------------FIREBASE CONNECTION--------------------------
class FirestoreApi {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference _getStudentsCollection() {
    return _firestore.collection('students');
  }

  static Future<void> addStudent(Student student) async {
    await _getStudentsCollection().add({
      'name': student.name,
      'id': student.id,
      'classSection': student.classSection,
      'email': student.email,
    });
  }

  static Future<List<Student>> getStudents() async {
    QuerySnapshot querySnapshot = await _getStudentsCollection().get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Student(
        name: data['name'],
        id: data['id'],
        classSection: data['classSection'],
        email: data['email'],
        firestoreId: doc.id,
      );
    }).toList();
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBZQKA3Uy3NrUJvXadwW236vMZArRBV2rc",
      appId: "1:599919108685:android:9f4934ab1eea7d47403204",
      messagingSenderId: "599919108685",
      projectId: "teamfirebase-c6320",
    ),
  );
  runApp(const StudentInfoApp());
}

class StudentInfoApp extends StatelessWidget {
  const StudentInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Info',
      theme: lightTheme, // Set initial theme to light
      darkTheme: darkTheme,
      home: const LoginPage(),
    );
  }
}

class AuthApi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> signup(String email, String password, String displayName) async {
    try {
    } catch (e) {
    }
  }
}

//-----------------LOGIN PAGE--------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();

  void _login(BuildContext context) async {
    bool success = await AuthApi.login(
      _loginEmailController.text,
      _loginPasswordController.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentListScreen(),
        ),
      );
    } else {
      // Error message for invalid credentials
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _signup(BuildContext context) async {
    String newEmail = _signupEmailController.text;
    String newPassword = _signupPasswordController.text;

    // Display Name Dialogue
    String? displayName = await _getDisplayName(context);

    if (displayName != null) {
      await AuthApi.signup(newEmail, newPassword, displayName);
      Navigator.of(context).pop(); // Close the SignUp dialog
    }
  }

  Future<String?> _getDisplayName(BuildContext context) async {
    TextEditingController displayNameController = TextEditingController();

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Display Name'),
          content: TextField(
            controller: displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(displayNameController.text);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loginEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Sign Up'),
                      content: Column(
                        children: [
                          TextField(
                            controller: _signupEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Username or Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _signupPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Sign Up'),
                          onPressed: () => _signup(context),
                        ),
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------STUDENT LIST--------------------------
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({Key? key}) : super(key: key);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];
  List<Student> filteredStudents = []; // Newly added to hold filtered students
  bool isLoading = false;
  int pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialStudents();
  }

  Future<void> _loadInitialStudents() async {
    await _loadStudents(isPagination: false);
  }

  Future<void> _loadStudents({bool isPagination = false}) async {
    if (!isPagination) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      QuerySnapshot querySnapshot;

      if (isPagination) {
        querySnapshot = await FirestoreApi._getStudentsCollection()
            .startAfterDocument(students.last.firestoreId as DocumentSnapshot<Object?>)
            .limit(pageSize)
            .get();
      } else {
        querySnapshot = await FirestoreApi._getStudentsCollection()
            .limit(pageSize)
            .get();
      }

      List<Student> fetchedStudents = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        fetchedStudents.add(Student(
          id: data['id'],
          firestoreId: doc.id,
          name: data['name'],
          classSection: data['classSection'],
          email: data['email'],
        ));
      }

      setState(() {
        if (isPagination) {
          students.addAll(fetchedStudents);
        } else {
          students = fetchedStudents;
        }
        filteredStudents = List.from(students); // Initialize filteredStudents with all students initially
      });
    } catch (e) {
      print('Error loading students: $e');
      // Handle the error appropriately, e.g., show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
//-----------------FEATURE FUNCTIONS--------------------------
  // adding student in Firestore
  void addStudent(Student newStudent) async {
    await FirestoreApi.addStudent(newStudent);
    _loadStudents();
  }

  // update student data in Firestore
  void editStudent(int index, Student newStudent) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(students[index].id)
        .update({
      'name': newStudent.name,
      'id': newStudent.id,
      'classSection': newStudent.classSection,
      'email': newStudent.email,
    });
    setState(() {
      students[index] = newStudent;
    });
  }

  void navigateToPage2(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return StudentDetailScreen(
            student: student,
            onStudentUpdated: (updatedStudent) {
              // Update the student list with the edited student
              editStudentInList(students.indexOf(student), updatedStudent);
            },
          );
        },
      ),
    );
  }
  void editStudents(int index, Student newStudent) async {
    if (newStudent.firestoreId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(newStudent.firestoreId) // Use firestoreId instead of student id
            .update({
          'name': newStudent.name,
          'id': newStudent.id,
          'classSection': newStudent.classSection,
          'email': newStudent.email,
        });

        // If the update is successful, update the local list
        setState(() {
          students[index] = newStudent;
        });
      } catch (e) {
        // Handle errors if needed
        print('Error updating student: $e');
      }
    }
  }

  void editStudentInList(int index, Student updatedStudent) {
    setState(() {
      students[index] = updatedStudent;
    });
  }
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
  // Deleting data from Firestore and local list
  void _deleteStudent(int index) async {
    String firestoreId = students[index].firestoreId;

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('students')
        .doc(firestoreId)
        .delete();

    // Delete from local list
    setState(() async {
      students.removeAt(index);
    });
  }

  Future<void> showAddEditStudentDialog({
    required bool isEditing,
    int? index,
    Student? initialStudent,
  }) async {
    // Prepare the student data
    Student newStudent = initialStudent ?? Student();
    TextEditingController nameController = TextEditingController(text: initialStudent?.name);
    TextEditingController idController = TextEditingController(text: initialStudent?.id);
    TextEditingController classSectionController = TextEditingController(text: initialStudent?.classSection);
    TextEditingController emailController = TextEditingController(text: initialStudent?.email);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Student' : 'Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                onChanged: (value) {
                  newStudent.name = value;
                },
                decoration: const InputDecoration(labelText: 'Enter student name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idController,
                onChanged: (value) {
                  newStudent.id = value;
                },
                decoration: const InputDecoration(labelText: 'Enter student ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: classSectionController,
                onChanged: (value) {
                  newStudent.classSection = value;
                },
                decoration: const InputDecoration(labelText: 'Enter student class section'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                onChanged: (value) {
                  newStudent.email = value;
                },
                decoration: const InputDecoration(labelText: 'Enter student email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(isEditing ? 'Save' : 'Add'),
              onPressed: () {
                if (isEditing) {
                  // Update the local list without querying Firestore
                  editStudentInList(index!, newStudent);
                } else {
                  if (newStudent.name.isNotEmpty && newStudent.id.isNotEmpty) {
                    // Add the student to the local list and Firestore
                    addStudent(newStudent);
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all students
        filteredStudents = List.from(students);
      } else {
        // Filter students based on the search query
        filteredStudents = students.where((student) {
          return student.name.toLowerCase().contains(query.toLowerCase()) ||
              student.id.toLowerCase().contains(query.toLowerCase()) ||
              student.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }
//-----------------STUDENT LIST UI--------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings), // Add settings icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(filteredStudents[index].name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${filteredStudents[index].id}'),
                        Text('Class Section: ${filteredStudents[index].classSection}'),
                        Text('Email: ${filteredStudents[index].email}'),
                      ],
                    ),
                    onTap: () {
                      navigateToPage2(filteredStudents[index]);
                    },
                    onLongPress: () {
                      showAddEditStudentDialog(
                        isEditing: true,
                        index: students.indexOf(filteredStudents[index]),
                        initialStudent: filteredStudents[index],
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Student'),
                              content: const Text('Are you sure you want to delete this student?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () {
                                    _deleteStudent(students.indexOf(filteredStudents[index]));
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddEditStudentDialog(isEditing: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
//-----------------STUDENT DETAILS--------------------------
class StudentDetailScreen extends StatefulWidget {
  Student student;
  final Function(Student) onStudentUpdated;

  StudentDetailScreen({super.key, required this.student, required this.onStudentUpdated});

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              var updatedStudent = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStudentScreen(student: widget.student),
                ),
              );

              if (updatedStudent != null) {
                // Update the student list after editing
                widget.onStudentUpdated(updatedStudent);
                setState(() {
                  widget.student = updatedStudent;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _getImage,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(_imageFile!),
            )
                : Container(),
            const Text(
              'Student Name:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.student.name,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'ID:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.student.id,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Class Section:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.student.classSection,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.student.email,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------STUDENTS' MAP OF VALUES--------------------------
class Student {
  String name;
  String id;
  String classSection;
  String email;
  String firestoreId;

  Student({
    this.name = '',
    this.id = '',
    this.classSection = '',
    this.email = '',
    this.firestoreId = '',
  });
}
//-----------------STUDENT EDIT FUNCTION--------------------------
class EditStudentScreen extends StatefulWidget {
  final Student student;

  EditStudentScreen({super.key, required this.student});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _classSectionController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _idController = TextEditingController(text: widget.student.id);
    _classSectionController = TextEditingController(text: widget.student.classSection);
    _emailController = TextEditingController(text: widget.student.email);
  }

  void editStudentInFirestore(String studentId, String name, String id, String classSection, String email) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .update({
      'name': name,
      'id': id,
      'classSection': classSection,
      'email': email,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              onChanged: (value) {
                widget.student.name = value;
              },
              decoration: const InputDecoration(labelText: 'Enter student name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _idController,
              onChanged: (value) {
                widget.student.id = value;
              },
              decoration: const InputDecoration(labelText: 'Enter student ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _classSectionController,
              onChanged: (value) {
                widget.student.classSection = value;
              },
              decoration: const InputDecoration(labelText: 'Enter student class section'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              onChanged: (value) {
                widget.student.email = value;
              },
              decoration: const InputDecoration(labelText: 'Enter student email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Update the student in Firestore
                editStudentInFirestore(
                  widget.student.firestoreId, // Use firestoreId instead of id
                  _nameController.text,
                  _idController.text,
                  _classSectionController.text,
                  _emailController.text,
                );
                // Return the updated student to the calling screen
                Navigator.pop(context, widget.student);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------SETTINGS THEME TO DARK OR LIGHT-------------------
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  // Add more theme properties as needed
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  // Add more theme properties as needed
);
class ThemeSelector extends StatefulWidget {
  @override
  _ThemeSelectorState createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  late ThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = lightTheme; // Set default theme
  }

  void _toggleTheme() {
    setState(() {
      _currentTheme =
      _currentTheme == lightTheme ? darkTheme : lightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Theme'),
      trailing: Switch(
        value: _currentTheme == darkTheme,
        onChanged: (_) => _toggleTheme(),
      ),
    );
  }
}
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) {
                if (Theme.of(context).brightness == Brightness.light) {
                  // Switch to dark theme
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
                  ThemeMode.dark;
                } else {
                  // Switch to light theme
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
                  ThemeMode.light;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


