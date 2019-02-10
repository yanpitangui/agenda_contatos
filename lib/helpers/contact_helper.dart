import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ContactHelper {
    static final ContactHelper _instance = new ContactHelper.internal();
    
    factory ContactHelper() => _instance;

    ContactHelper.internal();

    Database _db;

    get db async {
        if(_db !=null){
            return _db;
        } else {
            _db = await initDb();
            return _db;
        }
    }

    Future <Database> initDb() async {
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, "contacts.db");
        return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
            await db.execute(
                "CREATE TABLE CONTACT(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME VARCHAR(30), EMAIL VARCHAR(20), PHONE VARCHAR(15), IMG VARCHAR(50))"
            );
        });
    }

    Future<Contact> saveContact(Contact contact) async {
        Database dbContact = await db;
        contact.id = await dbContact.insert("CONTACT", contact.toMap());
        return contact;
    }

    Future<int> deleteContact(int id) async {
        Database dbContact = await db;
        return await dbContact.delete("CONTACT",
        where: "ID = ?", whereArgs: [id]);
    }

    Future<int> updatecontact(Contact contact) async {
        Database dbContact = await db;
        return await dbContact.update("CONTACT", contact.toMap(),
            where: "ID = ?", whereArgs: [contact.id]);
    }

    Future <List<Contact>> getAllContacts() async {
        Database dbContact = await db;
        List listMap = await dbContact.query("CONTACT");
        List<Contact> listContact = new List();
        listMap.forEach((map){
            listContact.add(Contact.fromMap(map));
            print(map);
        });
        return listContact;
    }

    Future<int> getNumber() async {
        Database dbContact = await db;
        return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM CONTACT"));
    }

    close() async {
        Database dbContact = await db;
        dbContact.close();
    }
}

class Contact {
    int id;
    String name;
    String email;
    String phone;
    String img;

    Contact();

    Contact.fromMap(Map map) {
        id = map["id"];
        name = map["name"];
        email = map["email"];
        phone = map["phone"];
        img = map["img"];
    }

    Map toMap(){
        Map<String, dynamic> map = {
        "name": name,
        "email": email,
        "phone": phone,
        "img": img 
        };
        if(id!=null){
            map["id"] = id;
        }
        return map;
    }

    @override
    String toString() {
    return json.encode(this.toMap());
  }
}