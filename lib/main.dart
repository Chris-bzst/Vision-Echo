
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'camera_service.dart';
import 'package:vision_echo/providers/gemini_provider.dart';
import 'tts_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart'; // For `compute` function

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final cameraService = CameraService();
  await dotenv.load();
  await cameraService.initialize(cameras);
  runApp(MyApp(cameraService: cameraService));
}

class MyApp extends StatelessWidget {
  final CameraService cameraService;

  MyApp({required this.cameraService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => GeminiProvider()), // Add GeminiProvider here
      ],
      child: MaterialApp(
        home: PhotoScreen(cameraService: cameraService),
      ),
    );
  }
}

class PhotoScreen extends StatefulWidget {
  final CameraService cameraService;

  PhotoScreen({required this.cameraService});

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late TTSService ttsService;
  List<Map<String, dynamic>> photoResults = [];
  bool _isSpeaking = false; // Add a flag to track TTS status


  @override
  void initState() {
    super.initState();
    ttsService = TTSService();
    widget.cameraService.startPhotoCapture((photo) async {
      await processPhoto(photo);
    });
  }

  Future<void> processPhoto(XFile photo) async {
    final geminiProvider = Provider.of<GeminiProvider>(context, listen: false);

    // Resize the image in a background isolate
    final resizedBytes = await compute(resizeImage, photo.path);

    // Generate content from resized image
    await geminiProvider.generateContentFromImage(bytes: resizedBytes);
    final responseText = geminiProvider.response ?? 'No response';

    // Speak the response
        if (!_isSpeaking) {
      _isSpeaking = true;
      await ttsService.speak(responseText);
      _isSpeaking = false;
    }

    // Update the UI on the main thread
    setState(() {
      photoResults.add({
        'photo': photo,
        'response': responseText,
      });
    });
  }

  // Function to be run in a background isolate
  static Future<Uint8List> resizeImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes);
    final resizedImage =
        img.copyResize(image!, width: 800); // Resize to width of 800 pixels
    return Uint8List.fromList(
        img.encodeJpg(resizedImage)); // Convert List<int> to Uint8List
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BouncingDots(),
            SizedBox(height: 20), // Space between the dots and the text
            Text(
              'Vision Echoing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ));
    // This is used for Test
    //   body: ListView.builder(
    //     itemCount: photoResults.length,
    //     itemBuilder: (context, index) {
    //       final photo = photoResults[index]['photo'] as XFile;
    //       final response = photoResults[index]['response'] as String;

    //       return Card(
    //         color: Colors.grey[850],
    //         margin: EdgeInsets.all(10),
    //         child: Column(
    //           children: <Widget>[
    //             Image.file(File(photo.path)),
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Text(
    //                 response,
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                   fontSize: 16,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
  
}


class BouncingDots extends StatefulWidget {
  @override
  _BouncingDotsState createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      upperBound: 1,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticIn);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildDot(_animation.value),
              SizedBox(width: 20), // Space between dots
              _buildDot(_animation.value),
              SizedBox(width: 20), // Space between dots
              _buildDot(_animation.value),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot(double animationValue) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      transform: Matrix4.translationValues(0, -animationValue * 20, 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
