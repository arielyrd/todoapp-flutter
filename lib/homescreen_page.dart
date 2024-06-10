import 'package:flutter/material.dart';
import 'main.dart';

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RememberIt!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'ReminderIt! Home Page')));
              },
              child: const Text('Continue to Main Page'),
            ),
          ],
        ),
      ),
    );
  }
}
