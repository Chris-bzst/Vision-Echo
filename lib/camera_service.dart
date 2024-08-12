// import 'package:camera/camera.dart';

// class CameraService {
//   CameraController? _controller;
//   List<CameraDescription>? _cameras;

//   Future<void> initialize() async {
//     _cameras = await availableCameras();
//     _controller = CameraController(_cameras!.first, ResolutionPreset.medium);
//     await _controller!.initialize();
//   }

//   Future<void> startPhotoCapture(Function(XFile) onPhotoTaken) async {
//     while (true) {
//       await Future.delayed(const Duration(seconds: 10));
//       if (_controller != null && _controller!.value.isInitialized) {
//         XFile photo = await _controller!.takePicture();
//         onPhotoTaken(photo);
//       }
//     }
//   }

//   CameraController? get controller => _controller;
// }


import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  Future<void> initialize() async {
    try {
      // Get a list of available cameras
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize the camera controller
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      await _controller!.initialize();
    } catch (e) {
      // Handle errors, such as when no cameras are available
      print('Error initializing camera: $e');
      rethrow;
    }
  }

  void startPhotoCapture(Function(XFile) onPhotoTaken) {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    // Periodically capture photos
    Future.delayed(Duration(seconds: 4), () async {
      try {
        final XFile photo = await _controller!.takePicture();
        onPhotoTaken(photo);
      } catch (e) {
        print('Error taking photo: $e');
      }
    });
  }

  void dispose() {
    _controller?.dispose();
  }
}
