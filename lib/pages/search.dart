import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_share/pages/profile.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Search extends StatefulWidget {
  final DocumentSnapshot? userSnap;
  final DocumentSnapshot? currentUser;

  Search({this.userSnap, this.currentUser});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResult = users.get();
  handleSearch(String query) async {
    Future<QuerySnapshot> search =
        users.where("displayName", isGreaterThan: query).get();
    setState(() {
      searchResult = search;
    });
  }

  AppBar buildSearchScreen() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(Icons.account_box, size: 20.0),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  clearSearch() {
    searchController.clear();
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          SvgPicture.asset(
            'assets/images/search.svg',
            height: orientation == Orientation.portrait ? 300.0 : 200.0,
          ),
          Text(
            "Find Users",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60.0,
            ),
          ),
        ],
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder<QuerySnapshot>(
      future: searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> results = [];
        snapshot.data?.docs.forEach((doc) {
          User user = User.fromDocument(doc);
          results.add(UserResult(widget.userSnap, widget.currentUser, user));
        });
        return ListView(
          children: results,
        );
      },
    );
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      appBar: buildSearchScreen(),
      body: searchResult == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final DocumentSnapshot? userSnap;
  final DocumentSnapshot? currentUser;
  final User user;

  UserResult(this.userSnap, this.currentUser, this.user);
  @override
  Widget build(BuildContext context) {
    print("From search");
    print(user.id);
    String userId;
    return Container(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () => {
                userId = user.id,
                print(userId),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(
                              user: userSnap,
                              currentinUser: currentUser,
                              userId: userId,
                            )))
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(
                  user.displayName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  user.username,
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
