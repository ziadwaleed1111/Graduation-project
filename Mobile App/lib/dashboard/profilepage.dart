import 'package:flutter/material.dart';
import 'package:spark1/Splash%20Screen/WelcomeScreen.dart';
import 'package:get/get.dart';
import 'package:spark1/dashboard/mypets.dart';


class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  void logout() {
    isLoggedIn.value = false;
  }
}

class ProfilePage extends StatelessWidget {
  final String username;
  final String email;
  final AuthController authController = Get.put(AuthController());

  ProfilePage({super.key, required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('lib/assets/profile.jpg'),
            ),
            const SizedBox(height: 10),
            Text(
              username,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Your profile'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  const ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Manage Address'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pets),
                    title: const Text('My Pets'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                       Navigator.push(
                      context,
                        MaterialPageRoute(builder: (context) => const MyPets()),
                       );
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Help Center'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  const ListTile(
                    leading: Icon(Icons.privacy_tip),
                    title: Text('Privacy'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log out'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    authController.logout();
    Get.offAll(() => const WelcomeScreen());
  }
}