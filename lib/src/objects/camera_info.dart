import 'package:mobile_scanner/mobile_scanner.dart';

class CameraInfo {
  /// The name of the camera.
  final String name;

  final String cameraId;

  /// The facing mode of the camera.
  final CameraFacing? facing;

  /// The sensor orientation of the camera.
  final int? sensorOrientation;

  CameraInfo({
    required this.name,
    required this.cameraId,
    this.facing,
    this.sensorOrientation,
  });
}
