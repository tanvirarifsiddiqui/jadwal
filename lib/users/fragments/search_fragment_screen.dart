import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/controllers/fetch_search_info.dart';
import 'package:jadwal/mosques/model/search_mosque_model.dart';

class SearchFragmentScreen extends StatefulWidget {
  @override
  State<SearchFragmentScreen> createState() => _SearchFragmentScreenState();
}

class _SearchFragmentScreenState extends State<SearchFragmentScreen> {
  List<SearchedMosque> _mosques = []; //List to Store Mosques
  List<SearchedMosque> _foundedMosques = [];
  int count = 0;
  @override
  void initState() {
    super.initState();
    //fetching default profile image
    if (_mosques.isEmpty) {
      count++;
      print(count);
      //fetching country list
      FetchSearchInfo.fetchMosques().then((mosqueList) {
        setState(() {
          _mosques = mosqueList;
          _foundedMosques = _mosques;
        });
      }).catchError(
          (error) {}); // Call this to fetch and populate the list of countries.
    }// if block

    setState(() {
      _foundedMosques = _mosques;
    });
  }


  //Etra todo hare to eliminate
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }//todo till here

  onSearch(String search) {
    setState(() {
      _foundedMosques = _mosques.where((mosque) => mosque.mosque_name.toLowerCase().contains(search)).toList();
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
      body:_mosques.isNotEmpty? Container(
        color: Colors.grey.shade900,
        child: _foundedMosques.isNotEmpty ? ListView.builder(
            itemCount: _foundedMosques.length,
            itemBuilder: (context, index) {
              return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: mosqueComponent(mosque: _foundedMosques[index]),
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
            }) : const Center(child: Text("No mosque found", style: TextStyle(color: Colors.white),)),
      )
          :const Center(child: CircularProgressIndicator())
    );
  }

  mosqueComponent({required SearchedMosque mosque}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
              children: [
                SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipOval(

                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(API.mosqueImage+mosque.mosque_image),
                          )
                        ),
                      )
                    )
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.4,//solved by media query
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mosque.mosque_name,softWrap: true, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5,),
                        Text(mosque.mosque_address, softWrap: true, style: TextStyle(color: Colors.grey[500])),
                      ]
                  ),
                )
              ]
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                // _mosques.isFollowedByMe = !user.isFollowedByMe;todo ss
              });
            },
            child: AnimatedContainer(
                height: 35,
                width: 100,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                    color: mosque.isConnectedByUser ? Colors.blue[700] : Color(0xffffff),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: mosque.isConnectedByUser ? Colors.transparent : Colors.grey.shade700,)
                ),
                child: Center(
                    child: Text(mosque.isConnectedByUser ? 'Disconnect' : 'Connect', style: TextStyle(color: mosque.isConnectedByUser ? Colors.white : Colors.white))
                )
            ),
          )
        ],
      ),
    );
  }
}
