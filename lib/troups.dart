import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dupepro/bookDetail.dart';

class TroupePage extends StatefulWidget {
  @override
  _TroupePageState createState() => _TroupePageState();
}

class _TroupePageState extends State<TroupePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> troupes = [];
  List<Map<String, dynamic>> filteredTroupes = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTroupes();
  }

  Future<void> _fetchTroupes() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('groups').get();

      List<Map<String, dynamic>> fetchedTroupes = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        troupes = fetchedTroupes;
        filteredTroupes = fetchedTroupes; // Initially show all troupes
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching troupes: $e");
      setState(() => isLoading = false);
    }
  }

  void _searchTroupes(String query) {
    setState(() {
      filteredTroupes = troupes
          .where((troupe) =>
          troupe['groupName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: isSearching
          ? TextField(
        controller: searchController,
        autofocus: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search troupes...",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: _searchTroupes,
      )
          : Text(
        "Troupes",
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF380230),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 5,
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (isSearching) {
                searchController.clear();
                filteredTroupes = troupes; // Reset search
              }
              isSearching = !isSearching;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(
        5,
            (index) => Icon(
          index < 4 ? Icons.star : Icons.star_border, // Dummy rating (4/5)
          size: 16,
          color: Colors.amber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF380230)))
          : filteredTroupes.isEmpty
          ? Center(
        child: Text(
          "No troupes found",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredTroupes.length,
          itemBuilder: (context, index) {
            var troupe = filteredTroupes[index];
            String groupName = troupe['groupName'] ?? 'Unnamed Troupe';
            String imageUrl = (troupe['images'] != null && troupe['images'].isNotEmpty)
                ? troupe['images'][0]
                : 'https://via.placeholder.com/200';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TroupDetail(groupId: troupes[index]['groupId']),
                  ),
                );


              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black38,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        _buildRatingStars(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
