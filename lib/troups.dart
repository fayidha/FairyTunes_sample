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
  Map<String, double> ratingsMap = {}; // Store average ratings
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
        filteredTroupes = fetchedTroupes;
      });

      _fetchRatings(); // Fetch ratings after loading troupes
    } catch (e) {
      print("Error fetching troupes: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchRatings() async {
    try {
      for (var troupe in troupes) {
        String groupId = troupe['groupId'];
        double avgRating = await _calculateAverageRating(groupId);
        setState(() {
          ratingsMap[groupId] = avgRating;
        });
      }
      setState(() => isLoading = false);
    } catch (e) {
      print("Error fetching ratings: $e");
    }
  }

  Future<double> _calculateAverageRating(String groupId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('groupId', isEqualTo: groupId)
          .where('rating', isGreaterThan: 0) // Only consider valid ratings
          .get();

      if (snapshot.docs.isEmpty) return 0.0; // No ratings yet

      double totalRating = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        totalRating += (doc['rating'] as num).toDouble();
        count++;
      }

      return count > 0 ? totalRating / count : 0.0;
    } catch (e) {
      print("Error calculating rating for group $groupId: $e");
      return 0.0;
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
        style:
        TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
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

  Widget _buildRatingStars(double rating) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            );
          }),
        ),
        SizedBox(width: 6), // Add spacing between stars and number
        Text(
          rating.toStringAsFixed(1), // Show numeric rating (e.g., 4.3)
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
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
            String groupId = troupe['groupId'];
            String imageUrl =
            (troupe['images'] != null && troupe['images'].isNotEmpty)
                ? troupe['images'][0]
                : 'https://via.placeholder.com/200';
            double rating = ratingsMap[groupId] ?? 0.0; // Get rating

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TroupDetail(groupId: groupId),
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
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        _buildRatingStars(rating),
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
