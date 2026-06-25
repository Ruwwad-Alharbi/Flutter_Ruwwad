import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  final VoidCallback onJoinUsPressed;

  const AccountScreen({super.key, required this.onJoinUsPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined, size: 100, color: Colors.black87),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: onJoinUsPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Join us now", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          const SizedBox(height: 12),
          const Text("to discover more sights of France", style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}