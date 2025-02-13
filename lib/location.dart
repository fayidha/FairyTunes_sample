import 'package:flutter/material.dart';

class DraggableContainerExample extends StatefulWidget {
  @override
  _DraggableContainerExampleState createState() =>
      _DraggableContainerExampleState();
}

class _DraggableContainerExampleState extends State<DraggableContainerExample> {
  double _containerHeight = 150; // Initial height of the container
  double _maxHeight = 500; // Maximum height
  double _minHeight = 100; // Minimu  m height

  final List<Map<String, String>> data = [
    {"title": "Location 1", "description": "Description for location 1"},
    {"title": "Location 2", "description": "Description for location 2"},
    {"title": "Location 3", "description": "Description for location 3"},
    {"title": "Location 4", "description": "Description for location 4"},
    {"title": "Location 5", "description": "Description for location 5"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Draggable Container Example"),
      ),
      body: Stack(
        children: [
// Main content or background
          Container(
            color:Color(0xFF380230),
            child: Center(
              child: Text(
                "Background Content",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),

// Draggable container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _containerHeight -= details.delta.dy;
                  _containerHeight =
                      _containerHeight.clamp(_minHeight, _maxHeight);
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: _containerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
// Drag handle
                    Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

// Title text
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Locations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

// List of data
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(data[index]["title"]!),
                            subtitle: Text(data[index]["description"]!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}