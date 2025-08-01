import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner/src/objects/camera_info.dart';

abstract class MobileScannerCamerasPlatform {
  Future<bool> checkPermission();

  Future<List<CameraInfo>?> getAvailableCameras([CameraFacing? facing]);

  Future<bool> stopCameras();

  Future<void> dispose();
}
