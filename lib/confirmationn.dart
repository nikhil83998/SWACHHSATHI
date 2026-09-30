import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  final String wasteType;
  final String deliveryShift;
  final String pickUpDate;
  final String estimatedWeight;
  final String additionalInfo;

  const ConfirmationPage({
    super.key,
    required this.wasteType,
    required this.deliveryShift,
    required this.pickUpDate,
    required this.estimatedWeight,
    required this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        backgroundColor: Colors.green, // Fresh and friendly theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 72,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Request Confirmed!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Thank you for scheduling your special pickup.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(label: 'Waste Type:', value: wasteType),
                    const SizedBox(height: 12),
                    DetailRow(label: 'Delivery Shift:', value: deliveryShift),
                    const SizedBox(height: 12),
                    DetailRow(label: 'Pick Up Date:', value: pickUpDate),
                    const SizedBox(height: 12),
                    DetailRow(
                        label: 'Estimated Weight:', value: estimatedWeight),
                    const SizedBox(height: 12),
                    DetailRow(label: 'Additional Info:', value: additionalInfo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Done Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.done),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DetailRow Widget for Consistency in Display
class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
