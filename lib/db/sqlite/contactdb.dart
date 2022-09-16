import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:contact_app/models/contact.dart';
import 'dart:async';

class ContactDB {
  final String dbName;
  Database? _db;
  List<Contact> _contacts = [];
  final _streamController = StreamController<List<Contact>>.broadcast();

  ContactDB({required this.dbName});

  Future<List<Contact>> _fetchContact() async {
    final db = _db;
    if (db == null) {
      return [];
    }
    try {
      final read = await db.query('CONTACT',
          distinct: true,
          columns: ['ID', 'NAME', 'PHONE_NUMBER'],
          orderBy: 'ID');

      final contacts = read.map((row) => Contact.fromRow(row)).toList();
      return contacts;
    } catch (e) {
      print('Error fetching contact $e');
      return [];
    }
  }

  Future<bool> createContact(String name, int phoneNumber) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final id = await db.insert("CONTACT", {
        "NAME": name,
        "PHONE_NUMBER": phoneNumber,
      });

      final contact = Contact(id: id, name: name, phoneNumber: phoneNumber);
      _contacts.add(contact);
      _streamController.add(_contacts);
      return true;
    } catch (e) {
      print("Error creating contact => $e");
      return false;
    }
  }

  Future<bool> deleteContact(Contact contact) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final deleteCount =
          await db.delete("CONTACT", where: "ID = ?", whereArgs: [contact.id]);
      if (deleteCount == 0) {
        _contacts.remove(contact);
        _streamController.add(_contacts);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Unable to delete with error $e");
      return false;
    }
  }

  Future<bool> updateContact(Contact contact) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final updateCount = await db.update(
        'CONTACT',
        {
          'NAME': contact.name,
          'PHONE_NUMBER': contact.phoneNumber,
        },
        where: 'ID = ?',
        whereArgs: [contact.id],
      );
      if (updateCount == 1) {
        _contacts.removeWhere((other) => other.id == contact.id);
        _contacts.add(contact);
        _streamController.add(_contacts);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Failed to update contact with error $e");
      return false;
    }
  }

  Future<bool> close() async {
    final db = _db;
    if (db == null) {
      return false;
    }
    await db.close();
    return true;
  }

  Future<bool> open() async {
    if (_db != null) {
      return true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(dbPath);
      _db = db;

      // create table
      const create = '''CREATE TABLE IF NOT EXISTS CONTACT (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        NAME STRING NOT NULL,
        PHONE_NUMBER STRING NOT NULL
      )''';

      await db.execute(create);

      final allContact = await _fetchContact();
      _contacts = allContact;
      _streamController.add(_contacts);
      return true;
    } catch (e) {
      print('error => $e');
      return false;
    }
  }

  Stream<List<Contact>> all() =>
      _streamController.stream.map((contacts) => contacts..sort());
}
