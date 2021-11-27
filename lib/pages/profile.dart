import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/edit_profile.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/post_tile.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:flutter_share/widgets/post.dart';
import 'package:flutter_svg/svg.dart';

class Profile extends StatefulWidget {
  final DocumentSnapshot? user;
  final DocumentSnapshot? currentinUser;
  final String? userId;
  Profile({this.user, this.currentinUser, this.userId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //final currentUserId = loggedInUser.id;
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  List<Post> ProfilePosts = [];
  int followerCount = 0;
  int followingCount = 0;
  String postOrientation = "list";
  @override
  void initState() {
    super.initState();
    getProfilePost();
    getFollowing();
    getFollowers();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    User currentInUser = User.fromDocument(widget.currentinUser);
    DocumentSnapshot doc = await followers
        .doc(widget.userId)
        .collection('userFollowers')
        .doc(currentInUser.id)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowing() async {
    User currentInUser = User.fromDocument(widget.currentinUser);
    QuerySnapshot snap =
        await following.doc(widget.userId).collection('userFollowing').get();
    setState(() {
      followingCount = snap.docs.length;
    });
  }

  getFollowers() async {
    QuerySnapshot snap =
        await followers.doc(widget.userId).collection('userFollowers').get();
    setState(() {
      followerCount = snap.docs.length;
    });
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    //User profileUser = User.fromDocument(widget.user);
    QuerySnapshot? snapshot = await posts
        .doc(widget.userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      ProfilePosts = snapshot.docs
          .map((doc) => Post.fromDocument(doc, widget.currentinUser))
          .toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(user: widget.currentinUser)));
  }

  handleUnfollowUser() {
    User currentInUser = User.fromDocument(widget.currentinUser);
    setState(() {
      isFollowing = true;
    });
    followers
        .doc(widget.userId)
        .collection('userFollowers')
        .doc(currentInUser.id)
        .get()
        .then((doc) => {
              if (doc.exists) {doc.reference.delete()}
            });
    following
        .doc(currentInUser.id)
        .collection('userFollowing')
        .doc(widget.userId)
        .get()
        .then((doc) => {
              if (doc.exists) {doc.reference.delete()}
            });
    feed
        .doc(widget.userId)
        .collection('feedItems')
        .doc(currentInUser.id)
        .get()
        .then((doc) => {
              if (doc.exists) {doc.reference.delete()}
            });
  }

  handleFollowUser() {
    User currentInUser = User.fromDocument(widget.currentinUser);
    setState(() {
      isFollowing = true;
    });
    followers
        .doc(widget.userId)
        .collection('userFollowers')
        .doc(currentInUser.id)
        .set({});
    following
        .doc(currentInUser.id)
        .collection('userFollowing')
        .doc(widget.userId)
        .set({});
    feed.doc(widget.userId).collection('feedItems').doc(currentInUser.id).set({
      'type': 'follow',
      "ownerId": widget.userId,
      'username': currentInUser.username,
      'userId': currentInUser.id,
      'userProfileImg': currentInUser.photoUrl,
      'timestamp': timestamp,
    });
  }

  Container buildButton(String text) {
    if (text == "Edit Profile") {
      return Container(
        padding: EdgeInsets.only(top: 2.0),
        child: TextButton(
          onPressed: editProfile,
          child: Container(
            width: 250.0,
            height: 25.0,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      );
    } else if (text == "Unfollow") {
      return Container(
        padding: EdgeInsets.only(top: 2.0),
        child: TextButton(
          onPressed: handleUnfollowUser,
          child: Container(
            width: 250.0,
            height: 25.0,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: handleFollowUser,
        child: Container(
          width: 250.0,
          height: 25.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    print("From profile Button");
    print(widget.userId);
    User currentLoggedinUser = User.fromDocument(widget.currentinUser);
    //User lookUser = User.fromDocument(widget.user);
    bool isProfileOWner = widget.userId == currentLoggedinUser.id;
    if (isProfileOWner) {
      return buildButton("Edit Profile");
    } else if (isFollowing) {
      return buildButton("Unfollow");
    } else if (!isFollowing) {
      return buildButton("Follow");
    }
  }

  buildProfileHeader() {
    print("From profile header");
    print(widget.userId);
    return FutureBuilder<DocumentSnapshot?>(
      future: users.doc(widget.userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        print("From builder in Profile Header");
        User profileUser = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        CachedNetworkImageProvider(profileUser.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildCountColumn("Posts", postCount),
                            buildCountColumn("Followers", followerCount),
                            buildCountColumn("Following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  profileUser.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  profileUser.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  profileUser.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    } else if (ProfilePosts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 260.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      ProfilePosts.forEach((post) {
        gridTiles.add(GridTile(
          child: PostTile(widget.currentinUser, post),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: ProfilePosts,
      );
    }
  }

  setPostOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == "grid"
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(
            Icons.list,
            color: postOrientation == "list"
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          //Divider(height: 0),
          buildProfilePost(),
        ],
      ),
    );
  }
}
