import 'package:masa_chat_firebase/helper/helper_function.dart';
import 'package:masa_chat_firebase/pages/auth/login_page.dart';
import 'package:masa_chat_firebase/pages/auth/search_page.dart';
import 'package:masa_chat_firebase/pages/group_info.dart';
import 'package:masa_chat_firebase/pages/profile_page.dart';
import 'package:masa_chat_firebase/service/auth_service.dart';
import 'package:masa_chat_firebase/service/database_service.dart';
import 'package:masa_chat_firebase/widgets/group_tile.dart';
import 'package:masa_chat_firebase/widgets/widgetsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final classId = groupId;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class classPage extends StatefulWidget {
  const classPage({super.key});

  @override
  State<classPage> createState() => _classPageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? classes;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingClassData();
  }

  //string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingClassData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    //getting the list of snapshot in our list
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getClassGroups()
        .then((snapshot) {
      setState(() {
        classes = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(Icons.search))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          "Groups",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selectedColor: Colors.green,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                    context,
                    ProfilePage(
                      userName: userName,
                      email: email,
                    ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content:
                            const Text("Are you sure you want to logout ?"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    });
                await authService.signOut().whenComplete(() {
                  nextScreenReplace(context, const LoginPage());
                });
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: classesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Create a group",
              textAlign: TextAlign.left,
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              _isLoading == true
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.green),
                    )
                  : TextField(
                      onChanged: (val) {
                        setState(() {
                          groupName = val;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green),
                              borderRadius: BorderRadius.circular(22)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(22)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green),
                              borderRadius: BorderRadius.circular(22))),
                    ),
            ]),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupName != "") {
                    setState(() {
                      _isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                        .createClass(userName,
                            FirebaseAuth.instance.currentUser!.uid, groupName)
                        .whenComplete(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                    showSnackBar(
                        context, Colors.green, "Group created succesfully");
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: const Text("CREATE"),
              ),
            ],
          );
        });
  }

  classesList() {
    return StreamBuilder(
      stream: classes,
      builder: (context, AsyncSnapshot snapshot) {
        //make some checks
        if (snapshot.hasData) {
          if (snapshot.data['classes'] != null) {
            print(snapshot.data['classes']);
            if (snapshot.data['classes'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['classes'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['classes'].length - index - 1;
                  return ClassTile(
                      classId: getId(snapshot.data['classes'][reverseIndex]),
                      className: getName(snapshot.data['classes'][reverseIndex]),
                      userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          print('Error: ${snapshot.error}');
          return Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You have not joined any class,tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _classPageState extends State<classPage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? classes;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingClassData();
  }

  //string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingClassData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    //getting the list of snapshot in our list
    classes = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .
        getClassGroupsList(groupId);
        //.then((snapshot) {
      //setState(() {
        //classes = snapshot;
      //});
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          "Groups",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      
      body: groupsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Create a group",
              textAlign: TextAlign.left,
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              _isLoading == true
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.green),
                    )
                  : TextField(
                      onChanged: (val) {
                        setState(() {
                          groupName = val;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green),
                              borderRadius: BorderRadius.circular(22)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(22)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green),
                              borderRadius: BorderRadius.circular(22))),
                    ),
            ]),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupName != "") {
                    setState(() {
                      _isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                        .createGroup(userName,
                            FirebaseAuth.instance.currentUser!.uid, groupName,classId)
                        .whenComplete(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                    showSnackBar(
                        context, Colors.green, "Group created succesfully");
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: const Text("CREATE"),
              ),
            ],
          );
        });
  }

  groupsList() {
    return StreamBuilder(
      stream: classes,
      builder: (context, AsyncSnapshot snapshot) {
        //make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            print(snapshot.data['groups']);
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(

                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName: userName);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          print('Error: ${snapshot.error}');
          return Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You have not joined any class,tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

