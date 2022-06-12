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
  // * Fields
  Position? _position;
  bool _locationIsEnabled = false;
  Permissions _permissionStatus = Permissions.granted;

  // * Getters & Setters
  Position? get position => _position;

  bool get locationIsEnabled => _locationIsEnabled;
  set locationIsEnabled(bool isEnabled) {
    if (isEnabled != _locationIsEnabled) {
      _locationIsEnabled = isEnabled;
      notifyListeners();
    }
  }

  Permissions get permissionStatus => _permissionStatus;
  set permissionStatus(Permissions value) {
    if (value != _permissionStatus) {
      _permissionStatus = value;
      notifyListeners();
    }
  }

  // * Methods
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

  Future<void> checkLocationService() async{
    // Check if the location services are enabled.
    locationIsEnabled = await Geolocator.isLocationServiceEnabled();
  }

  Future<void> requestToEnableLocationService() async{
    await checkLocationService();

    // In case the location services are disabled => request to enable it
    if (!locationIsEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    return;
  }

  /// Location
  /// Check if the location permission is granted,
  /// if it's not granted then request it.
  /// If it's granted then get the user's current location data
  Future getGeoLocationPosition() async {
    final hasPermission = await requestPermission();
    await checkLocationService();

    // In case the location services are disabled => request to enable it
    if (!locationIsEnabled && hasPermission) {
      await Geolocator.openLocationSettings();
      return;
    }
    else if(locationIsEnabled && hasPermission){
      // In case it is granted => access the position of the device.
      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return;
    }
  }


  // #Double tap to exit
  Future<bool> onWillPopFunction() async{
    DateTime? lastPressed;
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);
    final isWarning =  lastPressed == null || now.difference(lastPressed) > maxDuration;

    if(isWarning){
      lastPressed = DateTime.now();
      // doubleTap(context);
      return false;
    }
    return true;
  }
}