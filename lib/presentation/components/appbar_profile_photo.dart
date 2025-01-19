import 'package:flutter/material.dart';

import '../screens/profile/profile_screen.dart';

class AppBarProfilePhoto extends StatelessWidget {
  const AppBarProfilePhoto({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(
            child: CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage('images/profile.jpg'),
            ),
          ),
        ),
      ),
    );
  }
}
