import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unknown/utils/app_settings.dart';
import 'dart:io';

class Requestpage extends StatefulWidget {
  const Requestpage({super.key});

  @override
  RequestpageState createState() => RequestpageState();
}

class RequestpageState extends State<Requestpage> {
  String? RequestType;
  String? additionalInfo;
  File? _image;
  int _wordCount(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Waste Type: $RequestType');
      debugPrint('Additional Info: $additionalInfo');
      debugPrint('Selected Image: ${_image?.path}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppSettings.instance.tr('request_history')),
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
                  prefixIcon: const Icon(Icons.recycling),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: ['Bin Cleaning Request', 'Dustbin Request']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    RequestType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a Request type';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),

              // Additional Information Text Field
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
              SizedBox(height: screenHeight * 0.02),

              // Image Upload Section
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Capture Image'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Select from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark
                        ? Colors.blue.withValues(alpha: 0.12)
                        : Colors.blue.shade50,
                  ),
                  child: CustomPaint(
                    painter: DashedBorderPainter(
                      color: isDark ? Colors.lightBlueAccent : Colors.blue,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: isDark ? Colors.lightBlueAccent : Colors.blue,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Upload Additional File',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.lightBlueAccent : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_image != null)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _image!,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Send button placed at the bottom of the screen
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
                AppSettings.instance.tr('send_request'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 6, dashSpace = 5;
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    Path dashPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
