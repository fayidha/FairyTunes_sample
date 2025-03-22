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
          .map((doc) => {'groupId': doc.id, ...doc.data() as Map<String, dynamic>})
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('rating', isGreaterThan: 0) // Only get bookings with ratings
          .get();

      Map<String, double> totalRatings = {};
      Map<String, int> ratingCounts = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String groupId = data['groupId'];
        double rating = (data['rating'] as num).toDouble();

        if (totalRatings.containsKey(groupId)) {
          totalRatings[groupId] = totalRatings[groupId]! + rating;
          ratingCounts[groupId] = ratingCounts[groupId]! + 1;
        } else {
          totalRatings[groupId] = rating;
          ratingCounts[groupId] = 1;
        }
      }

      Map<String, double> computedRatings = {};
      totalRatings.forEach((groupId, total) {
        computedRatings[groupId] = total / ratingCounts[groupId]!;
      });

      setState(() {
        ratingsMap = computedRatings;
        _sortTroupesByRating();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching ratings: $e");
      setState(() => isLoading = false);
    }
  }

  void _sortTroupesByRating() {
    setState(() {
      filteredTroupes.sort((a, b) {
        double ratingA = ratingsMap[a['groupId']] ?? 0.0;
        double ratingB = ratingsMap[b['groupId']] ?? 0.0;
        return ratingB.compareTo(ratingA); // Sort descending
      });
    });
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
      _sortTroupesByRating(); // Ensure sorted order remains
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
                _sortTroupesByRating();
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
        SizedBox(width: 6),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : "0.0",
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
            double rating = ratingsMap[groupId] ?? 0.0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TroupDetail(groupId: groupId,rating:rating),
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
