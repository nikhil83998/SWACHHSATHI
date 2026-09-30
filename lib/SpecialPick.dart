import 'package:flutter/material.dart';
import 'package:unknown/utils/app_settings.dart';

class Specialpick extends StatefulWidget {
  const Specialpick({super.key});

  @override
  SpecialpickState createState() => SpecialpickState();
}

class SpecialpickState extends State<Specialpick> {
  String? wasteType;
  String? pickupShift;
  DateTime? pickUpDate;
  String? estimatedWeight;
  String selectedUnit = 'kg';
  String? additionalInfo;
  int _wordCount(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  final _formKey = GlobalKey<FormState>();

  double getNormalizedWeightInKg() {
    final raw = double.tryParse(estimatedWeight ?? '');
    if (raw == null) return 0;
    return selectedUnit == 'g' ? raw / 1000 : raw;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Waste Type: $wasteType');
      debugPrint('Pickup Shift: $pickupShift');
      debugPrint(
          'Pick Up Date: ${pickUpDate?.toLocal().toString().split(' ')[0]}');
      debugPrint(
          'Estimated Weight (normalized): ${getNormalizedWeightInKg()} kg');
      debugPrint('Additional Info: $additionalInfo');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickUpDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 5)),
    );
    if (picked != null && picked != pickUpDate) {
      setState(() {
        pickUpDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppSettings.instance.tr('special_pickup')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Waste Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppSettings.instance.tr('select_waste_type'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(Icons.recycling),
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
                onChanged: (value) {
                  setState(() {
                    wasteType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a waste type';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),

              // Pickup Shift Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppSettings.instance.tr('pickup_shift'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(Icons.access_time),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Morning',
                    child: Text(AppSettings.instance.tr('morning')),
                  ),
                  DropdownMenuItem(
                    value: 'Afternoon',
                    child: Text(AppSettings.instance.tr('afternoon')),
                  ),
                  DropdownMenuItem(
                    value: 'Evening',
                    child: Text(AppSettings.instance.tr('evening')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    pickupShift = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a pickup shift';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),

              // Pickup Date Picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: AppSettings.instance.tr('pickup_date'),
                      hintText: pickUpDate == null
                          ? 'Select a date'
                          : '${pickUpDate?.toLocal().toString().split(' ')[0]}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (pickUpDate == null) {
                        return 'Please select a pick-up date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Estimated Weight Input + Unit Selector
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: AppSettings.instance.tr('estimated_weight'),
                        hintText: 'Enter weight',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.scale),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          estimatedWeight = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a weight';
                        }
                        final num? weight = num.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Enter a valid number';
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: ['kg', 'g'].map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Additional Info
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppSettings.instance.tr('additional_info'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(Icons.info_outline),
                  counterText: additionalInfo == null
                      ? ''
                      : '${_wordCount(additionalInfo!)} / 200 words',
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    additionalInfo = value;
                  });
                },
                validator: (value) {
                  if (value != null && _wordCount(value) > 200) {
                    return 'Maximum 200 words allowed';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),

      // Send Button at bottom
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.greenAccent : Colors.green,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: Text(
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
