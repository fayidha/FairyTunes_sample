import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dupepro/Teacher_dash.dart';
import 'package:dupepro/controller/session.dart';
import 'package:dupepro/location.dart';
import 'package:dupepro/model/Product_model.dart';
import 'package:dupepro/seller_dash.dart';
import 'package:dupepro/troups.dart';
import 'package:dupepro/videoplayer.dart';
import 'package:dupepro/view/detailPage.dart';
import 'package:dupepro/view/login.dart';
import 'package:dupepro/view/product.dart';
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
   String _userName="Unknown User";
   String _userEmail="No Email Found";
   String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }


  Future<void> _loadUserSession() async {
    Map<String, dynamic>? userDetails = await Session.getUserDetails();

    setState(() {
      _userName = userDetails?['name'];
      _userEmail = userDetails?['email'] ;
      _userImageUrl = userDetails?['userProfile'];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF380230),
        toolbarHeight: 70,
        title: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Color(0xFF380230)),
            hintText: 'Search troupes, products, teachers...',
            hintStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white24,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: Color(0xFF380230)),
          onChanged: (value) => print('search clicked!'),
        ),
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
                    : AssetImage('asset/music.jpg') as ImageProvider, // Default image if no URL
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
              onTap: ()  async {
                try {
                  await FirebaseAuth.instance.signOut(); // Logs out from Firebase
                  await Session.clearSession(); // Clears SharedPreferences session

                  // Navigate to login screen and remove all previous screens
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginForm()),
                        (route) => false,
                  );
                } catch (e) {
                  print("Logout error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logout failed! Please try again.")),
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
                  Navigator.push(context, MaterialPageRoute(builder:(context) => DraggableContainerExample(),));
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
            Image.asset('asset/ft1.PNG'),
            SizedBox(height: 40),
            Text(
              "Select Your Best Music Products Today!",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurpleAccent),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                      6,
                          (index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                          AssetImage('asset/210379377.png'),
                            ),
                          )),
                ),
              ),
            ),
            SizedBox(height: 40),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('advertisements').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No advertisements available"));
                }

                List<Product> products = snapshot.data!.docs.map((doc) {
                  return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return CarouselSlider(
                  items: products.map((product) {
                    String imageUrl = (product.imageUrls.isNotEmpty)
                        ? product.imageUrls.first
                        : 'https://via.placeholder.com/150'; // Placeholder for missing images

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetail(product: product),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 250,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.85, // Adjusted for better visibility
                  ),
                );
              },
            ),


            const SizedBox(height: 60),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 12,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('advertisements').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No video advertisements available"));
                    }

                    List<String> videoUrls = [];
                    for (var doc in snapshot.data!.docs) {
                      List<dynamic> videos = doc['videoUrls'] ?? [];
                      videoUrls.addAll(videos.cast<String>());
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "🎥 Sponsored Video Advertisements",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
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
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Advertisement",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    Color(0xFF380230).withOpacity(0.7)  ,

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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                                      style: TextStyle(fontSize: 16, color: Color(0xFF380230))),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                                  Icon(Icons.group, size: 20, color: Color(0xFF380230)),
                                  SizedBox(width: 8),
                                  Text('Troups',
                                      style: TextStyle(fontSize: 16, color: Color(0xFF380230))),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                                  Icon(Icons.school, size: 20, color: Color(0xFF380230)),
                                  SizedBox(width: 8),
                                  Text('Teachers',
                                      style: TextStyle(fontSize: 16, color: Color(0xFF380230))),
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

            // Music Bands Carousel
            CarouselSlider(
              items: [
                Image.asset('asset/band1.jpeg',
                    fit: BoxFit.cover, width: double.infinity),
                Image.asset('asset/band2.webp',
                    fit: BoxFit.cover, width: double.infinity),
                Image.asset('asset/band4.jpg',
                    fit: BoxFit.cover, width: double.infinity),
              ],
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 20),

            const SizedBox(height: 30),
          ElevatedButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SellerDashboard(),));
          }, child: Text('Seller!') ),
            const SizedBox(height: 30),

            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
            }, child: Text('Teacher add notes') ),
          ],
        )
      )
    );
  }
}
