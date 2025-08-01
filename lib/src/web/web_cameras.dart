import 'dart:js_interop';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner/src/mobile_scanner_cameras_platform.dart';
import 'package:mobile_scanner/src/objects/camera_info.dart';
import 'package:web/web.dart';

class WebCameras extends MobileScannerCamerasPlatform {
  static WebCameras? _instance;

  factory WebCameras() {
    return _instance ??= WebCameras._();
  }

  WebCameras._();

  MediaStream? _mediaStreamInstance;

  @override
  Future<bool> checkPermission() async {
    try {
      _mediaStreamInstance =
          await window.navigator.mediaDevices
              .getUserMedia(
                MediaStreamConstraints(video: true.toJS, audio: false.toJS),
              )
              .toDart;

      console.log('Permission granted!'.toJS);
      return true;
    } on DOMException catch (e) {
      console.error('Permission denied!: ${e.message.toJS}'.toJS);
      _mediaStreamInstance = null;
      return false;
    }
  }

  @override
  Future<List<CameraInfo>?> getAvailableCameras([CameraFacing? facing]) async {
    if (!(await checkPermission())) return null;

    console.log('listing cameras'.toJS);
    final List<MediaDeviceInfo> devices =
        (await window.navigator.mediaDevices.enumerateDevices().toDart).toDart
            .where((d) => d.kind == 'videoinput')
            .toList();

    if (devices.isEmpty) return null;

    final RegExp back = RegExp(r'\b(back|rear|environment|world)\b');
    final RegExp front = RegExp(r'\b(front|user|face|integrated)\b');
    final RegExp external = RegExp(r'\b(usb|external|webcam|logitech|cam)\b');

    console.log('make [CameraInfo] list'.toJS);
    final List<CameraInfo> cameras =
        devices.map((device) {
          final String label = device.label.toLowerCase();

          final CameraFacing cameraFacing =
              back.hasMatch(label)
                  ? CameraFacing.back
                  : front.hasMatch(label)
                  ? CameraFacing.front
                  : external.hasMatch(label)
                  ? CameraFacing.external
                  : CameraFacing.unknown;

          return CameraInfo(
            name: device.label,
            cameraId: device.deviceId,
            facing: cameraFacing,
          );
        }).toList();

    if (facing == null) return cameras;

    console.log('return filtered list'.toJS);
    return cameras.where((c) => c.facing == facing).toList();
  }

  @override
  Future<bool> stopCameras() async {
    if (_mediaStreamInstance == null) return false;
    _mediaStreamInstance!.getTracks().toDart.forEach((track) => track.stop());
    return true;
  }

  @override
  Future<void> dispose() async {
    if (_mediaStreamInstance != null && _mediaStreamInstance!.active) {
      _mediaStreamInstance!.getTracks().toDart.forEach((element) {
        element.stop();
      });
      _mediaStreamInstance = null;
    }
  }
}
