import 'package:flutter/material.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: const Center(
        child: Text(
          'Report Incident Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
