import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/activity_feed.dart';
import 'package:flutter_share/pages/create_account.dart';
import 'package:flutter_share/pages/profile.dart';
import 'package:flutter_share/pages/timeline.dart';
import 'package:flutter_share/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_share/pages/search.dart';
import 'package:firebase_storage/firebase_storage.dart';

final GoogleSignIn googleSignin = GoogleSignIn();
final CollectionReference users =
    FirebaseFirestore.instance.collection('users');
final CollectionReference posts =
    FirebaseFirestore.instance.collection('posts');
final CollectionReference comments =
    FirebaseFirestore.instance.collection('comments');
final CollectionReference feed = FirebaseFirestore.instance.collection('feed');
final CollectionReference followers =
    FirebaseFirestore.instance.collection('followers');
final CollectionReference following =
    FirebaseFirestore.instance.collection('following');
final CollectionReference timeline =
    FirebaseFirestore.instance.collection('timeline');

final DateTime timestamp = DateTime.now();
User currentUser = User();

final Reference postsRef = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  bool isAuth = false;
  PageController? pageController;
  int pageIndex = 0;
  User loggedInUser = User();
  DocumentSnapshot? document;
  String? userId;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignin.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      AlertDialog(
        title: const Text("Error"),
        content: Text(err),
      );
    });
    googleSignin
        .signInSilently(suppressErrors: false)
        .then((account) => {handleSignIn(account)})
        .catchError((err) {
      AlertDialog(
        title: const Text("Error"),
        content: Text(err),
      );
    });
  }

  dispose() {
    pageController?.dispose();
  }

  handleSignIn(GoogleSignInAccount? account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    final GoogleSignInAccount? user = googleSignin.currentUser;
    DocumentSnapshot doc = await users.doc(user?.id).get();
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      users.doc(user?.id).set({
        "id": user?.id,
        "username": username,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "bio": "",
        "timestamp": timestamp,
      });
    }
    doc = await users.doc(user?.id).get();
    document = doc;
    User currentUser = User.fromDocument(doc);
    setState(() {
      loggedInUser = currentUser;
    });
  }

  login() {
    googleSignin.signIn();
  }

  logout() {
    googleSignin.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) async {
    await pageController?.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Scaffold buildAuthScreen() {
    userId = currentUser.id;
    return Scaffold(
      body: PageView(
        children: [
          Timeline(
            logInUser: document,
          ),
          ActivityFeed(
            loginUser: document,
          ),
          Upload(
            loggedInUser: document,
          ),
          Search(
            userSnap: document,
            currentUser: document,
          ),
          Profile(
            user: document,
            currentinUser: document,
            userId: loggedInUser.id,
          ),
        ],
        controller: pageController!,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnauthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Flutter Share",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
                onTap: () => {login()},
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("assets/images/google_signin_button.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnauthScreen();
  }
}
