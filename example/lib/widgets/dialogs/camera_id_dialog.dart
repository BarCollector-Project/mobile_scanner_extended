import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A dialog that displays the supported cameras on the device for manual
/// selection.
///
/// Currently only supported in the browser.
class CameraIdDialog extends StatefulWidget {
  const CameraIdDialog({required this.availableCameras, super.key});

  /// A future that will return the list of supported cameras.
  /// Otherwise, it will return empty, indicating that there is no support or
  /// even no cameras to be listed.
  ///
  /// Using the future makes it possible to display the dialog loading the
  /// cameras.
  /// It also bypasses Dart's warning:
  /// "Don't use 'BuildContext's across async gaps."
  final Future<List<CameraInfo>> availableCameras;

  @override
  State<CameraIdDialog> createState() => _CameraIdDialogState();
}

class _CameraIdDialogState extends State<CameraIdDialog> {
  CameraInfo? _tempSelectedCameraId;
  List<CameraInfo> _availableCameras = [];

  /// Here we expect 'availableCameras' to return the
  /// List\<CameraInfo\> with 'then()'.
  ///
  /// As soon as the future returns the list, we update the dialog.
  @override
  void initState() {
    super.initState();
    widget.availableCameras.then(
      (cameras) => setState(() {
        _availableCameras = cameras;
        _tempSelectedCameraId = _availableCameras.first;
      }),
    );
  }

  /// While the future is still running, the dialog shows us a loading indicator.
  ///
  /// After the future returns the list, it checks if it contains anything.
  /// If it does, we list it for selection.
  /// Otherwise, we can indicate that there are no cameras or that they are
  /// not supported.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Camera ID'),
      content: SingleChildScrollView(
        child: FutureBuilder<List<CameraInfo>>(
          future: widget.availableCameras,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            _availableCameras = snapshot.data ?? [];
            return _availableCameras.isEmpty
                ? const Center(
                  child: Text('No cameras available or not suported.'),
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _availableCameras.map((camera) {
                        return RadioListTile<CameraInfo>(
                          title: Text(camera.name),
                          value: camera,
                          groupValue: _tempSelectedCameraId,
                          onChanged: (CameraInfo? value) {
                            setState(() {
                              _tempSelectedCameraId = value;
                            });
                          },
                        );
                      }).toList(),
                );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _tempSelectedCameraId);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
