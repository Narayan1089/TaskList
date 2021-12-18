// ignore_for_file: unnecessary_null_comparison

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list/screens/login.dart';
import 'package:task_list/screens/taskDescription.dart';

// User? loggedInUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final auth = FirebaseAuth.instance;
  List todos = List.empty();
  String title = "Testing";
  String description = "Data";
  String uid = '';
  String formatted = '';
  // bool istaskCompleted = false;

  DateTime date = DateTime.now();
  final dayOnly = DateFormat("dd-MM-yyyy").format(DateTime.now());
  // DateTime format = DateFormat.yMd().format(date) as DateTime;

  // String? email = '';
  // String? id = '';
  // String? name = '';

  // Future<void> getCurrentUser() async {
  //   try {
  //     final user = auth.currentUser;

  //     if (user != null) {
  //       loggedInUser = user;
  //       if (loggedInUser != null) {
  //         email = loggedInUser?.email;
  //         id = loggedInUser?.uid;
  //         name = loggedInUser?.displayName;
  //       }
  //     }
  //     print(user);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void initState() {
    final user = auth.currentUser;
    setState(() {
      uid = user!.uid;
    });
    super.initState();
    todos = ["Hello", "Hey There"];

    // getCurrentUser();
  }

  Future logOut(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.signOut().then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
      });
    } catch (e) {
      print("error");
    }
  }

  createToDo() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Tasks")
        .doc(uid)
        .collection('MyTasks')
        .doc(title);

    Map<String, String> todoList = {
      "todoTitle": title,
      "todoDesc": description,
      "todoDate": formatted
      // date.toString()
    };

    documentReference
        .set(todoList)
        .whenComplete(() => print("Data stored successfully"));
  }

  deleteTodo(item) {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Tasks")
        .doc(uid)
        .collection('MyTasks')
        .doc(item);

    documentReference
        .delete()
        .whenComplete(() => print("deleted successfully"));
  }

  //   updateThoughts({required User? user, required String thought}) async {
  //   _firestore
  //       .collection('users')
  //       .doc(user!.uid)
  //       .set({'thoughts': thought}, SetOptions(merge: true))
  //       // .update({'thoughts': thought})
  //       .then((value) => print('Thoughts updated'))
  //       .catchError((error) => print("Failed to update user: $error"));
  // }

  updateTodo(item) {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Tasks")
        .doc(uid)
        .collection('MyTasks')
        .doc(item);

    Map<String, String> todoList = {
      "todoTitle": title,
      "todoDesc": description,
      "todoDate": formatted
      // date.toString()
    };

    documentReference
        .set(todoList, SetOptions(merge: true))
        .then((value) => print('Tasks updated'))
        .catchError((error) => print("Failed to update user: $error"));
  }

  //datepicker

  datepicker() async {
    final today = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime(today.year + 10, today.month, today.day),
    );

    if (selectedDate != null && selectedDate != date) {
      setState(() {
        date = selectedDate;
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        formatted = formatter.format(date);
        // DateFormat.yMd().format(date);
        print(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () => logOut(context),
            ),
            //  Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Task completed color: ',
              ),
              Text(
                'Red',
                style: TextStyle(
                  color: Colors.red[200],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Task incomplete color: ',
              ),
              Text(
                'Grey',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Tasks')
                .doc(uid)
                .collection('MyTasks')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              } else if (snapshot.hasData || snapshot.data != null) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      QueryDocumentSnapshot<Object?>? documentSnapshot =
                          snapshot.data?.docs[index];
                      // DateTime time =
                      //     (documentSnapshot!['todoDate'] as Timestamp).toDate();
// final color = (documentSnapshot!['todoDate']) == DateTime.now();

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Description(
                                title: documentSnapshot!['todoTitle'],
                                description: documentSnapshot['todoDesc'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                // color: const Color(0xff121211),
                                color:
                                    (documentSnapshot!['todoDate']) != dayOnly
                                        ? Colors.grey
                                        : Colors.red[200],
                                borderRadius: BorderRadius.circular(10)),
                            height: 90,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      child: Text(
                                        (documentSnapshot != null)
                                            ? (documentSnapshot["todoTitle"])
                                            : "",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      child: Text((documentSnapshot != null)
                                          ? ('Completion date: ' +
                                              documentSnapshot["todoDate"])
                                          : ""),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    description = documentSnapshot["todoDesc"];
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            title: const Text("Add Todo"),
                                            content: Container(
                                              width: 400,
                                              height: 145,
                                              child: Column(
                                                children: [
                                                  // TextField(
                                                  //   onChanged: (String value) {
                                                  //     title = value;
                                                  //   },
                                                  // ),
                                                  TextField(
                                                    onChanged: (String value) {
                                                      description = value;
                                                    },
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                          'Completion Date:'),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            datepicker();
                                                          });
                                                        },
                                                        child: const Icon(
                                                            Icons.date_range),
                                                        //  Text(
                                                        //   DateFormat("dd/MM/yyyy")
                                                        //       .format(date)
                                                        //       .toString(),
                                                        // ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      updateTodo(title);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Add"))
                                            ],
                                          );
                                        });

                                    // setState(() {
                                    //   //todos.removeAt(index);
                                    //   updateTodo((documentSnapshot != null)
                                    //       ? (documentSnapshot["todoTitle"])
                                    //       : "");

                                    //   print(dayOnly);
                                    // });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Container(
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        //todos.removeAt(index);
                                        deleteTodo((documentSnapshot != null)
                                            ? (documentSnapshot["todoTitle"])
                                            : "");
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      // Card(
                      //  elevation: 4,
                      //  child: ListTile(
                      //    // leading: Text(DateFormat.yMd().format(date)),
                      //    leading: Text((documentSnapshot != null)
                      //        ? (documentSnapshot["todoDate"])
                      //        : ""),
                      //    title: Text((documentSnapshot != null)
                      //        ? (documentSnapshot["todoTitle"])
                      //        : ""),
                      //    subtitle: Text((documentSnapshot != null)
                      //        ? ((documentSnapshot["todoDesc"] != null)
                      //            ? documentSnapshot["todoDesc"]
                      //            : "")
                      //        : ""),
                      //    trailing: IconButton(
                      //      icon: const Icon(Icons.delete),
                      //      color: Colors.red,
                      //      onPressed: () {
                      //        setState(() {
                      //          //todos.removeAt(index);
                      //          deleteTodo((documentSnapshot != null)
                      //              ? (documentSnapshot["todoTitle"])
                      //              : "");
                      //        });
                      //      },
                      //    ),
                      //  ),
                      //   );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.red,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Text("Add Todo"),
                  content: Container(
                    width: 400,
                    height: 145,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (String value) {
                            title = value;
                          },
                        ),
                        TextField(
                          onChanged: (String value) {
                            description = value;
                          },
                        ),
                        Row(
                          children: [
                            const Text('Completion Date:'),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  datepicker();
                                });
                              },
                              child: const Icon(Icons.date_range),
                              //  Text(
                              //   DateFormat("dd/MM/yyyy")
                              //       .format(date)
                              //       .toString(),
                              // ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          setState(() {
                            //todos.add(title);
                            createToDo();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add"))
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}




// Dismissible(
//                     key: Key(index.toString()),
//                     child:
                    
//                      Card(
//                       elevation: 4,
//                       child: ListTile(
//                         // leading: Text(DateFormat.yMd().format(date)),
//                         leading: Text((documentSnapshot != null)
//                             ? (documentSnapshot["todoDate"])
//                             : ""),
//                         title: Text((documentSnapshot != null)
//                             ? (documentSnapshot["todoTitle"])
//                             : ""),
//                         subtitle: Text((documentSnapshot != null)
//                             ? ((documentSnapshot["todoDesc"] != null)
//                                 ? documentSnapshot["todoDesc"]
//                                 : "")
//                             : ""),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete),
//                           color: Colors.red,
//                           onPressed: () {
//                             setState(() {
//                               //todos.removeAt(index);
//                               deleteTodo((documentSnapshot != null)
//                                   ? (documentSnapshot["todoTitle"])
//                                   : "");
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   );