import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helpers.dart';
import 'package:agenda_de_contatos/ui/contactPage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOpions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOpions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOpions>>[
              const PopupMenuItem<OrderOpions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOpions.orderaz,
              ),
              const PopupMenuItem<OrderOpions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOpions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactcard(context, index);
          }),
    );
  }

  Widget _contactcard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/person.png"))),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          contacts[index].name ?? "",
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          contacts[index].email ?? "",
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text(
                          contacts[index].phone ?? "",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updeteContact(recContact);
        _getAllContacts();
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showOptions(BuildContext context, int index) {
    showBottomSheet(
        context: context,
        builder: (contex) {
          return BottomSheet(onClosing: () {
            Navigator.pop(context);
          }, builder: (context) {
            return Container(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  heightFactor: 1.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                            onPressed: () {
                              launch("tel:${contacts[index].phone}");
                              Navigator.pop(context);
                            },
                            child: Text("Ligar",
                                style: TextStyle(
                                    color: Colors.red, fontSize: 20.0))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                            onPressed: () {
                              _showContactPage(contact: contacts[index]);
                            },
                            child: Text("Editar",
                                style: TextStyle(
                                    color: Colors.red, fontSize: 20.0))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                            onPressed: () {
                              helper.deleteContact(contacts[index].id);
                              setState(() {
                                contacts.removeAt(index);
                                Navigator.pop(context);
                              });
                            },
                            child: Text("Excluir",
                                style: TextStyle(
                                    color: Colors.red, fontSize: 20.0))),
                      ),
                    ],
                  ),
                ));
          });
        });
  }

  void _orderList(OrderOpions result) {
    switch (result) {
      case OrderOpions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOpions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
