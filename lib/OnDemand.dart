import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unknown/utils/app_settings.dart';

class Ondemand extends StatefulWidget {
  const Ondemand({super.key});

  @override
  OndemandState createState() => OndemandState();
}

class OndemandState extends State<Ondemand> {
  final _formKey = GlobalKey<FormState>();
  late CollectionReference _wasteCollectionRef;
  String? _errorMessage;

  String? wasteType;
  String? estimatedWeight;
  String? additionalInfo;
  String selectedUnit = 'kg';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    try {
      _wasteCollectionRef = FirebaseFirestore.instance.collection('pickupRequests');
    } catch (e) {
      _errorMessage = 'Failed to initialize database: ${e.toString()}';
    }
  }

  int _wordCount(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  double getNormalizedWeightInKg() {
    final raw = double.tryParse(estimatedWeight ?? '');
    if (raw == null) return 0;
    return selectedUnit == 'g' ? raw / 1000 : raw;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        final normalizedWeightKg = getNormalizedWeightInKg();

        final submissionData = {
          'wasteType': wasteType,
          'estimatedWeight': normalizedWeightKg,
          'unit': 'kg',
          'additionalInfo': additionalInfo,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        };

        await _wasteCollectionRef
            .add(submissionData)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw Exception('Submission time out. Please try again.');
        });

        if (mounted) {
          final submittedWasteType = wasteType!;
          final submittedWeight = '$normalizedWeightKg kg';
          final submittedAdditionalInfo = additionalInfo;
          _resetForm();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationPage(
                wasteType: submittedWasteType,
                weight: submittedWeight,
                additionalInfo: submittedAdditionalInfo,
              ),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to submit: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      wasteType = null;
      estimatedWeight = null;
      additionalInfo = null;
      selectedUnit = 'kg';
      _errorMessage = null;
    });
  }

  Widget _buildWasteTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: wasteType,
      decoration: InputDecoration(
        labelText: AppSettings.instance.tr('select_waste_type'),
        hintText: AppSettings.instance.tr('select_waste_type'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.recycling),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      items: [
        DropdownMenuItem(
          value: 'Organic Waste',
          child: Text(AppSettings.instance.tr('organic_waste')),
        ),
        DropdownMenuItem(
          value: 'Recyclable Waste',
          child: Text(AppSettings.instance.tr('recyclable_waste')),
        ),
        DropdownMenuItem(
          value: 'E-Waste',
          child: Text(AppSettings.instance.tr('e_waste')),
        ),
      ],
      onChanged: (value) => setState(() => wasteType = value),
      validator: (value) => value == null ? 'Please select a waste type' : null,
    );
  }

  Widget _buildWeightInputField() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: AppSettings.instance.tr('estimated_weight'),
              hintText: 'Enter weight',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.scale),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => setState(() => estimatedWeight = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a weight';
              }
              final num? weight = num.tryParse(value);
              if (weight == null || weight <= 0) {
                return 'Please enter a valid weight';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: selectedUnit,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            items: ['kg', 'g'].map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedUnit = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: AppSettings.instance.tr('additional_info'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.info_outline),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        counterText: additionalInfo == null
            ? ''
            : '${_wordCount(additionalInfo!)} / 200 words',
      ),
      maxLines: 3,
      onChanged: (value) => setState(() => additionalInfo = value),
      validator: (value) {
        if (value != null && _wordCount(value) > 200) {
          return 'Maximum 200 words allowed';
        }
        return null;
      },
    );
  }

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppSettings.instance.tr('on_demand_pickup')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildWasteTypeDropdown(),
              const SizedBox(height: 16),
              _buildWeightInputField(),
              const SizedBox(height: 16),
              _buildAdditionalInfoField(),
              const SizedBox(height: 16),
              _buildErrorWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.greenAccent : Colors.green,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      AppSettings.instance.tr('submit_request'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  final String wasteType;
  final String weight;
  final String? additionalInfo;

  const ConfirmationPage({
    super.key,
    required this.wasteType,
    required this.weight,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Confirmed'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.check_circle,
              color: isDark ? Colors.greenAccent : Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your waste collection request has been submitted successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2D3748) : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Waste Type:', wasteType, onSurface),
                  const SizedBox(height: 12),
                  _buildDetailRow('Estimated Weight:', weight, onSurface),
                  if (additionalInfo != null && additionalInfo!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('Additional Notes:', additionalInfo!, onSurface),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Our team will contact you shortly to schedule the collection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: onSurface.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.greenAccent : Colors.green,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Return to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color onSurface) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: onSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: onSurface.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}
