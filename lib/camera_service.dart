
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  Future<void> initialize(List<CameraDescription> cameras) async {
    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(rearCamera, ResolutionPreset.medium);
    await _controller!.initialize();
  }

  Future<void> startPhotoCapture(Function(XFile) onPhotoTaken) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      if (_controller != null && _controller!.value.isInitialized) {
        XFile photo = await _controller!.takePicture();
        onPhotoTaken(photo);
      }
    }
  }

  CameraController? get controller => _controller;
}
