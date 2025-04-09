import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/bookDetail.dart';
import 'package:dupepro/controller/Product_Controller.dart';
import 'package:dupepro/controller/session.dart';
import 'package:dupepro/location.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/troups.dart';
import 'package:dupepro/videoplayer.dart';
import 'package:dupepro/view/login.dart';
import 'package:dupepro/view/logovdo.dart';
import 'package:dupepro/view/notification_artist.dart';
import 'package:dupepro/view/product.dart';
import 'package:dupepro/view/productcategory.dart';
import 'package:dupepro/view/teachers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Unknown User";
  String _userEmail = "No Email Found";
  String? _userImageUrl;
  List<String> categories = [];
  Map<String, String> categoryImages = {};

  get productId => null;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _fetchCarouselImages();
  }

  List<String> carouselImages = [];

  Future<void> _fetchCarouselImages() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      List<String> fetchedImages = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('images') && data['images'] is List) {
          fetchedImages.addAll(List<String>.from(data['images']));
        }
      }

      setState(() {
        carouselImages = fetchedImages;
      });
    } catch (e) {
      print("Error fetching carousel images: $e");
    }
  }

  Future<void> _loadUserSession() async {
    Map<String, dynamic>? userDetails = await Session.getUserDetails();

    setState(() {
      _userName = userDetails?['name'];
      _userEmail = userDetails?['email'];
      _userImageUrl = userDetails?['userProfile'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '𝔽𝕒𝕚𝕣𝕪𝕋𝕦𝕟𝕖𝕤',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF380230).withOpacity(0.9),
          elevation: 39,
          centerTitle: true,
          toolbarHeight: 100,
          // toolbarHeight: 70,
          // title: TextField(
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(Icons.search, color: Color(0xFF380230)),
          //     hintText: 'Search troupes, products, teachers...',
          //     hintStyle: TextStyle(color: Colors.white70),
          //     filled: true,
          //     fillColor: Colors.white24,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(30),
          //       borderSide: BorderSide.none,
          //     ),
          //   ),
          //   style: TextStyle(color: Color(0xFF380230)),
          //   onChanged: (value) => print('search clicked!'),
          // ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(_userName),
                accountEmail: Text(_userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _userImageUrl != null
                      ? NetworkImage(_userImageUrl!) // Load from URL
                      : AssetImage('asset/music.jpg')
                          as ImageProvider, // Default image if no URL
                ),
                decoration: BoxDecoration(color: Color(0xFF380230)),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Color(0xFF380230)),
                title: Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Color(0xFF380230)),
                title: Text('Settings'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text("Log Out"),
                onTap: () async {
                  try {
                    await FirebaseAuth.instance
                        .signOut(); // Logs out from Firebase
                    await Session
                        .clearSession(); // Clears SharedPreferences session

                    // Navigate to login screen and remove all previous screens
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginForm()),
                      (route) => false,
                    );
                  } catch (e) {
                    print("Logout error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Logout failed! Please try again.")),
                    );
                  }
                }, // Call logout function
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF380230), Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DraggableContainerExample(),
                      ));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.add_location, size: 24, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Deliver to this location",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Image.asset('asset/ft1.PNG'),
            VideoWidget(),
            SizedBox(height: 40),
            Text(
              "Select Your Best Music Products Today!",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black),
            ),
            SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 120,
                child: FutureBuilder<List<Product>>(
                  future: ProductController().getAllProducts(),
                  // Correct way to call the method
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator()); // Loading state
                    } else if (snapshot.hasError) {
                      return Center(
                          child:
                              Text("Error: ${snapshot.error}")); // Show error
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text("No categories found")); // No data case
                    }

                    // Extract categories & images dynamically
                    Map<String, String> categoryImages = {};
                    for (var product in snapshot.data!) {
                      categoryImages.putIfAbsent(
                          product.category,
                          () => product.imageUrls.isNotEmpty
                              ? product.imageUrls.first
                              : 'assets/default.png');
                    }

                    List<String> categories = categoryImages.keys.toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        String imageUrl =
                            categoryImages[category] ?? 'assets/default.png';

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductCategoryPage(
                                      selectedCategory: category),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: imageUrl.startsWith('http')
                                      ? NetworkImage(imageUrl)
                                      : AssetImage('assets/default.png')
                                          as ImageProvider,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  category,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 40),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Product> products = snapshot.data!.docs
                    .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No advertisements available"));
                }

                List<String> imageUrls = [];
                for (var doc in snapshot.data!.docs) {
                  if (doc
                      .data()
                      .toString()
                      .contains('advertisementImageUrls')) {
                    List<dynamic> images = doc['advertisementImageUrls'] ?? [];
                    imageUrls.addAll(images.cast<String>());
                  }
                }

                // If no images are found, show a message
                if (imageUrls.isEmpty) {
                  return const Center(
                      child: Text("No image advertisements available"));
                }

                return CarouselSlider(
                  items: imageUrls.map((imageUrl) {
                    return GestureDetector(
                      onTap: () {
                      /*  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetail(productId: products),
                          ),
                        );*/
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: true, // Auto-play the carousel
                    enlargeCenterPage: true, // Enlarge the center item
                    aspectRatio: 16 / 9, // Aspect ratio of the image
                    viewportFraction:
                        0.8, // Fraction of the viewport to show each item
                  ),
                );
              },
            ),
            const SizedBox(height: 60),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 12,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<String> videoUrls = [];
                    for (var doc in snapshot.data!.docs) {
                      if (doc
                          .data()
                          .toString()
                          .contains('advertisementVideoUrls')) {
                        List<dynamic> videos =
                            doc['advertisementVideoUrls'] ?? [];
                        videoUrls.addAll(videos.cast<String>());
                      }
                    }

                    // If no videos are found, show a message
                    if (videoUrls.isEmpty) {
                      return const Center(
                          child: Text("No video advertisements available"));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "🎥 Sponsored Video Advertisements",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        CarouselSlider(
                          items: videoUrls
                              .map((url) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        VideoPlayerWidget(videoUrl: url),
                                        Positioned(
                                          bottom: 10,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "Advertisement",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          options: CarouselOptions(
                            height: 250,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 6),
                            viewportFraction: 0.85,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 60),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 40),

            Text(
              "Deals for you..",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 30),
            Text('Choose your need! '),
            Icon(Icons.check_box),
            const SizedBox(height: 40),
            // Special Container with Gradient Background for Product, Troups, and Teachers
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.3),
                    Color(0xFF380230).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Product Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductList(),
                          ));
                    },
                    child: Card(
                      elevation: 30,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.2),
                              Colors.purpleAccent.withOpacity(0.2)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.asset(
                                'asset/prod.avif',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.production_quantity_limits,
                                      size: 20, color: Color(0xFF380230)),
                                  SizedBox(width: 8),
                                  Text('Products',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF380230))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Troups Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TroupePage(),
                          ));
                    },
                    child: Card(
                      elevation: 30,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.2),
                              Colors.purpleAccent.withOpacity(0.2)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.asset(
                                'asset/troups.jpg',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group,
                                      size: 20, color: Color(0xFF380230)),
                                  SizedBox(width: 8),
                                  Text('Troups',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF380230))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Teachers Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherPage(),
                          ));
                    },
                    child: Card(
                      elevation: 30,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.2),
                              Colors.purpleAccent.withOpacity(0.2)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.asset(
                                'asset/teach.jpg',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.school,
                                      size: 20, color: Color(0xFF380230)),
                                  SizedBox(width: 8),
                                  Text('Teachers',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF380230))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Text(
              "🎶 Book your favorite music bands and tracks today for an unforgettable experience!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 50),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No groups available"));
                }

                List<Map<String, dynamic>> allImagesWithGroups = [];

                for (var doc in snapshot.data!.docs) {
                  List<dynamic>? images = doc['images'];
                  if (images != null && images.isNotEmpty) {
                    for (String imageUrl in images.cast<String>()) {
                      allImagesWithGroups
                          .add({'imageUrl': imageUrl, 'groupId': doc.id});
                    }
                  }
                }

                if (allImagesWithGroups.isEmpty) {
                  return Center(child: Text("No images available"));
                }

                return CarouselSlider(
                  items: allImagesWithGroups.map((item) {
                    return GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         TroupDetail(groupId: item['groupId']),
                        //   ),
                        // );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 150,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 20),

            const SizedBox(height: 30),
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => SellerDashboard(),
            //           ));
            //     },
            //     child: Text('Seller!')),
            // const SizedBox(height: 30),
            //
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => NotificationByTime()));
            //     },
            //     child: Text('Teacher add notes')),
          ],
        )));
  }
}
