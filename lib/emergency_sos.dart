import 'dart:async';
import 'package:flutter/material.dart';

class EmergencySOSPage extends StatefulWidget {
  const EmergencySOSPage({super.key});

  @override
  State<EmergencySOSPage> createState() => _EmergencySOSPageState();
}

class _EmergencySOSPageState extends State<EmergencySOSPage> {
  Timer? _timer;
  int _countdown = 5;
  bool _isCountingDown = false;

  void _startCountdown() {
    setState(() {
      _countdown = 5;
      _isCountingDown = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        _sendSOS();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _cancelSOS() {
    _timer?.cancel();
    setState(() {
      _isCountingDown = false;
    });
  }

  void _sendSOS() {
    _cancelSOS();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SOS Sent'),
        content: const Text(
          'Emergency alert has been sent.\n\n'
          'Authorities will respond immediately.\n'
          '(Demo mode)',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _confirmSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Emergency SOS'),
        content: const Text(
          'This will send an emergency alert to authorities.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Send SOS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'EMERGENCY SOS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Long-press the button below to send an emergency alert.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            // SOS BUTTON
            GestureDetector(
              onLongPress: _confirmSOS,
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _isCountingDown
                      ? 'Sending in $_countdown...'
                      : 'HOLD TO SEND SOS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (_isCountingDown) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _cancelSOS,
                child: const Text(
                  'Cancel SOS',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
