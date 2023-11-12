import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/controllers/users_fetch_info.dart';
import 'package:jadwal/mosques/model/search_mosque_model.dart';
import 'package:get/get.dart';
import 'package:jadwal/mosques/profile/user_mosque_profile.dart';

class SearchMosqueScreen extends StatefulWidget {
  @override
  State<SearchMosqueScreen> createState() => _SearchMosqueScreenState();
}

class _SearchMosqueScreenState extends State<SearchMosqueScreen> {
  List<SearchedMosque> _mosques = []; //List to Store Mosques
  List<SearchedMosque> _foundedMosques = [];

  @override
  void initState() {
    super.initState();
    //fetching default profile image
    if (_mosques.isEmpty) {
      //fetching country list
      UsersServerOperation.fetchMosquesForSearch().then((mosqueList) {
        setState(() {
          _mosques = mosqueList;
          _foundedMosques = _mosques;
        });
      }).catchError(
          (error) {}); // Call this to fetch and populate the list of countries.
    } // if block

    setState(() {
      _foundedMosques = _mosques;
    });
  }

  onSearch(String search) {
    setState(() {
      _foundedMosques = _mosques
          .where((mosque) => mosque.mosque_name.toLowerCase().contains(search))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black, // Background color
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.brown.shade800,
          title: SizedBox(
            height: 38,
            child: TextField(
              style: TextStyle(color: Colors.brown[200]),
              onChanged: (value) => onSearch(value),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.brown[900],
                  contentPadding: const EdgeInsets.all(0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.brown.shade200,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none),
                  hintStyle:
                      TextStyle(fontSize: 14, color: Colors.brown.shade200),
                  hintText: "Search mosques"),
            ),
          ),
        ),
        body: _mosques.isNotEmpty
            ? Container(
                color: const Color(0xff2b0c0d),
                child: _foundedMosques.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundedMosques.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            actionPane: const SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child:
                                mosqueComponent(mosque: _foundedMosques[index]),
                            actions: <Widget>[
                              IconSlideAction(
                                caption: 'Archive',
                                color: Colors.transparent,
                                icon: Icons.archive,
                                onTap: () => print("archive"),
                              ),
                              IconSlideAction(
                                caption: 'Share',
                                color: Colors.transparent,
                                icon: Icons.share,
                                onTap: () => print('Share'),
                              ),
                            ],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'More',
                                color: Colors.transparent,
                                icon: Icons.more_horiz,
                                onTap: () => print('More'),
                              ),
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.transparent,
                                icon: Icons.delete,
                                onTap: () => print('Delete'),
                              ),
                            ],
                          );
                        })
                    : const Center(
                        child: Text("No mosque found",
                            style: TextStyle(color: Colors.white))),
              )
            : const Center(child: CircularProgressIndicator()));
  }

  mosqueComponent({required SearchedMosque mosque}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2,right: 2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                // Get.to(MosqueProfileUser(mosqueId: mosque.mosque_id));
                Get.to(() => UserMosqueProfile(mosqueId: mosque.mosque_id));
              },
              child: Row(children: [
                SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipOval(
                        child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white60, // Adjust the border color
                            width: 2.5, // Adjust the border width
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                API.mosqueImage + mosque.mosque_image),
                          )),
                    ))),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.55, //solved by media query
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mosque.mosque_name,
                            softWrap: true,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(mosque.mosque_address,
                            softWrap: true,
                            style: TextStyle(color: Colors.brown[200])),
                      ]),
                ),
                const SizedBox(
                    width: 5), // Add space between address and connection text
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.connect_without_contact, color: Colors.white70,),
                    Text(
                      " ${mosque.connectors}", // Replace with your mosque connection data
                      style: const TextStyle(
                          color: Colors.white), // Style for connection text
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
