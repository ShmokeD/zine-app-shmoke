import 'package:flutter/material.dart';
import 'package:zineapp2023/theme/color.dart';

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Column(
          children: [
            Spacer(),
            Icon(
              Icons.message,
              size: 50,
              color: textDarkBlue,
            ),
            SizedBox(height: 15),
            Text(
              'No Messages',
              style: TextStyle(fontSize: 20),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
