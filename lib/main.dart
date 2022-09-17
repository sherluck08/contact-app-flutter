import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:contact_app/models/contact.dart';
import './db/sqlite/contactdb.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.pink[700],
          secondary: Colors.pink[700],
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context, String contactName) {
  bool shouldDelete = false;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Are you sure you want to delete $contactName?'),
          actions: [
            TextButton(
              onPressed: () {
                shouldDelete = false;
                Navigator.of(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                shouldDelete = true;
                Navigator.of(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      }).then((value) {
    return shouldDelete;
  });
}

final _nameController = TextEditingController();
final _phoneNumberController = TextEditingController();

Future<Contact?> showUpdateDialog(BuildContext context, Contact contact) {
  _nameController.text = contact.name;
  _phoneNumberController.text = contact.phoneNumber.toString();
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your updated contact details'),
              TextField(
                controller: _nameController,
              ),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final editedContact = Contact(
                  id: contact.id,
                  name: _nameController.text,
                  phoneNumber: int.parse(_phoneNumberController.text),
                );
                Navigator.of(context).pop(editedContact);
                _nameController.clear();
                _phoneNumberController.clear();
              },
              child: const Text('Update'),
            ),
          ],
        );
      }).then((value) {
    if (value is Contact) {
      return value;
    } else {
      return null;
    }
  });
}

// Future<bool> createContactDialog(BuildContext context) {}
class ContactTile extends StatelessWidget {
  final Contact contact;
  final ContactDB crudStorage;
  const ContactTile(
      {Key? key, required this.contact, required this.crudStorage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onLongPress: () async {
          final editedContact = await showUpdateDialog(context, contact);
          if (editedContact != null) {
            await crudStorage.updateContact(editedContact);
          }
        },
        title: Text(contact.name),
        subtitle: Text(contact.phoneNumber.toString()),
        leading: const Icon(
          Icons.person,
          size: 40,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ContactDB _crudStorage;
  late final TextEditingController _nameTextEditingController;
  late final TextEditingController _phoneNumberTextEditingController;
  String name = "";
  int phoneNumber = 0;

  @override
  void initState() {
    _crudStorage = ContactDB(dbName: 'db.sqlite');
    _crudStorage.open();
    _nameTextEditingController = TextEditingController();
    _phoneNumberTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _phoneNumberTextEditingController.dispose();
    _crudStorage.close();
    super.dispose();
  }

  void addNewContact(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add New Contact'),
                TextField(
                  decoration: const InputDecoration(hintText: 'Full Name'),
                  controller: _nameController,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Phone Number'),
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    name = _nameController.text;
                    phoneNumber = int.parse(_phoneNumberController.text);
                  });
                  _nameController.clear();
                  _phoneNumberController.clear();
                  _crudStorage.createContact(name, phoneNumber);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name added to the contact list'),
                    ),
                  );
                },
                child: const Text('Add Contact'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "COM 326 Simple Contact App",
        ),
        elevation: 0.0,
        actions: [
          PopupMenuButton(
            onSelected: (value) => {
              if (value == 'About')
                {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('COM 326 Simple Contact App v0.2'),
                          content: Text(
                              'This is an app built by HND1 Computer Students (Group 8)\n\nFor an assignment on building a mini mobile, this simple app utilizes all the database CRUD functionality'),
                        );
                      })
                }
              else if (value == 'Help')
                {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('Help'),
                          content: Text(
                              'Press the + button to add a contact\n\nSwipe to the left or right on any contact to delete contact\n\nLong press on any contact to update'),
                        );
                      })
                }
            },
            icon: const Icon(Icons.more_vert_sharp),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Help',
                child: Text('Help'),
              ),
              const PopupMenuItem(
                value: 'About',
                child: Text('About'),
              ),
            ],
          )
        ],
      ),
      body: StreamBuilder(
          stream: _crudStorage.all(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.waiting:
                if (snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final contacts = snapshot.data as List<Contact>;
                if (contacts.isNotEmpty) {
                  return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Dismissible(
                          key: Key(contact.toString()),
                          background: Container(
                            color: Colors.red,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            String contactName = contact.name;
                            bool shouldDelete = false;
                            if (direction == DismissDirection.startToEnd) {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                          'Are you sure you want to delete $contactName?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            shouldDelete = false;
                                            Navigator.of(context).pop(null);
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            shouldDelete = true;
                                            Navigator.of(context).pop(true);
                                            await _crudStorage
                                                .deleteContact(contact);
                                            setState(() {
                                              contacts.removeAt(index);
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '$contactName removed from contact list'),
                                              ),
                                            );
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  });
                            }
                            return shouldDelete;
                          },
                          child: ContactTile(
                            contact: contact,
                            crudStorage: _crudStorage,
                          ),
                        );
                      });
                } else {
                  return const Center(
                    child: Text(
                      'No Contact Saved Yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewContact(context);
        },
        child: const Text(
          "+",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
