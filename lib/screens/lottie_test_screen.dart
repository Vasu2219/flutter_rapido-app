import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieTestScreen extends StatelessWidget {
  const LottieTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lottie Animation Test'),
        backgroundColor: const Color(0xFFFFD54F),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Car Animation Test
            Column(
              children: [
                const Text(
                  'Car Animation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Lottie.asset(
                    'assets/lottie/Car.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Car Lottie Error: $error');
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.red[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 50, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text('Car Animation Failed'),
                            const SizedBox(height: 4),
                            Text(
                              error.toString(),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Motorcycle Animation Test
            Column(
              children: [
                const Text(
                  'Motorcycle Animation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Lottie.asset(
                    'assets/lottie/Motorcycle.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Motorcycle Lottie Error: $error');
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.orange[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 50, color: Colors.orange),
                            const SizedBox(height: 8),
                            const Text('Motorcycle Animation Failed'),
                            const SizedBox(height: 4),
                            Text(
                              error.toString(),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Test Button
            ElevatedButton(
              onPressed: () {
                print('Assets are configured correctly!');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console for asset loading status'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Test Animations'),
            ),
          ],
        ),
      ),
    );
  }
}
