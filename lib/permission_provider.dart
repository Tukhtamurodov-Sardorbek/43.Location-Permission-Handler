import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


enum Permissions {
  granted,
  denied,
  // restricted, // Only supported on iOS
  // limited, // Only supported on iOS
  permanentlyDenied,
}

class PermissionProvider with ChangeNotifier {
  Position? position;

  // PermissionStatus _locationStatus = PermissionStatus.denied;

  Permissions _permissionStatus = Permissions.granted;

  Permissions get permissionStatus => _permissionStatus;

  set permissionStatus(Permissions value) {
    if (value != _permissionStatus) {
      _permissionStatus = value;
      notifyListeners();
    }
  }

  Future<bool> requestPermission() async {
    // Request for permission
    final status = await Permission.location.request();

    if (status.isGranted) {
      permissionStatus = Permissions.granted;
      return true;
    } else if (Platform.isIOS || status.isPermanentlyDenied) {
      permissionStatus = Permissions.permanentlyDenied;
    } else {
      permissionStatus = Permissions.denied;
    }
    return false;
  }


  /// Location
  /// Check if the location permission is granted,
  /// if it's not granted then request it.
  /// If it's granted then get the user's current location data
  Future<Position> getGeoLocationPosition() async {
    // #Getting the position coordinates
    bool isEnabled;

    final hasPermission = await requestPermission();

    // Check if the location services are enabled.
    isEnabled = await Geolocator.isLocationServiceEnabled();

    // In case the location services are disabled => request to enable it
    if (!isEnabled && hasPermission) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    // In case it is granted => access the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

}