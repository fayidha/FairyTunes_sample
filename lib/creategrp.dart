import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _groupNameController = TextEditingController();
  final _groupDescController = TextEditingController();
  final List<Map<String, String>> _members = [];
  Map<String, String>? _selectedUser;

  final List<Map<String, String>> _registeredUsers = [
    {"name": "meghna", "email": "meghna@example.com", "category": "Musician"},
    {"name": "akhil", "email": "akhil@example.com", "category": "Vocalist"},
    {"name": "freddy", "email": "freddy@example.com", "category": "Composer"},
    {"name": "David", "email": "david@example.com", "category": "Instrumentalist"},
    {"name": "Emma", "email": "emma@example.com", "category": "Producer"},
  ];

  final Map<String, String> _currentUser = {
    "name": "Me (You)",
    "email": "me@example.com",
    "category": "Admin"
  };

  @override
  void initState() {
    super.initState();
    _members.add(_currentUser);
  }

  void _addMember() {
    if (_selectedUser != null && !_members.contains(_selectedUser)) {
      setState(() => _members.add(_selectedUser!));
    }
  }

  void _removeMember(int index) {
    if (_members[index] != _currentUser) {
      setState(() => _members.removeAt(index));
    }
  }

  void _createGroup() {
    if (_groupNameController.text.isNotEmpty && _members.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "${_groupNameController.text}" created successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a group name and add at least one member.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create group", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF380230),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAvatar(),
            _buildTextField(_groupNameController, 'Group Name'),
            _buildTextField(_groupDescController, 'Group Description'),
            _buildUserDropdown(),
            Expanded(child: _buildMemberList()),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.camera_alt, size: 40, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildUserDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Map<String, String>>(
            value: _selectedUser,
            hint: Text("Select User"),
            items: _registeredUsers.map((user) {
              return DropdownMenuItem(value: user, child: Text("${user["name"]} - ${user["category"]}"));
            }).toList(),
            onChanged: (value) => setState(() => _selectedUser = value),
          ),
        ),
        IconButton(icon: Icon(Icons.add_circle, color: Colors.green), onPressed: _addMember),
      ],
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(member["name"]!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(member["email"]!),
            trailing: member == _currentUser
                ? Icon(Icons.star, color: Colors.blue)
                : IconButton(icon: Icon(Icons.remove_circle, color: Colors.red), onPressed: () => _removeMember(index)),
          ),
        );
      },
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: _createGroup,
      icon: Icon(Icons.group_add),
      label: Text('Create Group'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF380230),
        foregroundColor: Colors.white,
      ),
    );
  }
}
