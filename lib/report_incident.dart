import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'capture_evidence.dart';
import 'models/evidence.dart';
import 'services/incident_id.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedCategory;
  bool _isSubmitting = false;

  late Box<Evidence> _evidenceBox;

  final List<String> _categories = [
    'Robbery',
    'Assault',
    'Kidnapping',
    'Domestic Violence',
    'Suspicious Activity',
    'Traffic Incident',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _evidenceBox = Hive.box<Evidence>('evidenceBox');
  }

  /* =========================
     ADD EVIDENCE
     ========================= */
  Future<void> _addEvidence() async {
    final result = await Navigator.push<Evidence>(
      context,
      MaterialPageRoute(
        builder: (_) => const CaptureEvidencePage(),
      ),
    );

    if (result != null) {
      setState(() {}); // Refresh UI from Hive
    }
  }

  /* =========================
     SUBMIT REPORT (DEMO)
     ========================= */
  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;

    final incidentId = IncidentIdGenerator.generate();

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Report Submitted'),
          content: Text(
            'Incident ID: $incidentId\n'
            'Incident Category: $_selectedCategory\n'
            'Evidence Attached: ${_evidenceBox.length}\n\n'
            'Location & evidence metadata attached automatically.\n'
            '(Demo mode)',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /* =========================
     UI
     ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Incident Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select incident type',
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Incident Description',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the incident';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe what happened...',
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attached Evidence',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Evidence'),
                    onPressed: _addEvidence,
                  ),
                ],
              ),

              if (_evidenceBox.isEmpty)
                const Text(
                  'No evidence attached yet.',
                  style: TextStyle(color: Colors.grey),
                ),

              if (_evidenceBox.isNotEmpty)
                Column(
                  children: _evidenceBox.values.map((evidence) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.file(
                          File(evidence.imagePath),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          'Evidence • ${evidence.formattedTime}',
                        ),
                        subtitle: Text(
                          evidence.locationName,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
