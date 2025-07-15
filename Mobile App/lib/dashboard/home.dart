import 'package:flutter/material.dart';
import 'package:spark1/dashboard/profilepage.dart';
import 'DiseasePage.dart';
import 'appointmentspage.dart';
import 'peoplepage.dart';
import 'shelterspage.dart';
import 'suppliespage.dart';

class Home extends StatefulWidget {
  final String username;
  final String email;

  const Home({super.key, required this.username, required this.email});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PeoplePage(),
    const SuppliesPage(),
    const AppointmentsPage(),
    const SheltersPage(),
    const DiseasePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: _pages[_selectedIndex],
            ),
            if (_selectedIndex == 0)
              Positioned(
                top: 20,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.username,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'lib/assets/profile.jpg',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        username: widget.username,
                        email: widget.email,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.gesture_sharp),
            label: "Track",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: "Supplies",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Shelters",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.disabled_visible),
            label: "Disease prediction",
          ),
        ],
      ),
    );
  }
}