import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/permission_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final PermissionProvider _model;
  bool _detectPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _model = PermissionProvider();
    _model.getGeoLocationPosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This block of code is used in the event that the user
  // has denied the permission forever. Detects if the permission
  // has been granted when the user returns from the
  // permission system screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _detectPermission &&
        (_model.permissionStatus == Permissions.permanentlyDenied)) {
      _detectPermission = false;
      _model.requestPermission();
    } else if (state == AppLifecycleState.paused &&
        _model.permissionStatus == Permissions.permanentlyDenied) {
      _detectPermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<PermissionProvider>(
        builder: (context, model, child) {
          Widget _body;
          switch (model.permissionStatus) {
            case Permissions.granted:
            _body = Center(
              child: ElevatedButton(
                onPressed: model.getGeoLocationPosition,
                child: const Text('Get location'),
              ),
            );
              break;
            case Permissions.denied:
              // _body = Container(color: Colors.yellowAccent);
              _body = LocationPermission(
                isPermanent: false,
                onPressed: model.getGeoLocationPosition,
              );
              break;
            case Permissions.permanentlyDenied:
              _body = LocationPermission(
                isPermanent: true,
                onPressed: model.getGeoLocationPosition,
              );
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Permission Handling'),
            ),
            body: _body,
          );
        },
      ),
    );
  }
}

/// This widget will serve to inform the user in
/// case the permission has been denied. There is a
/// variable [isPermanent] to indicate whether the
/// permission has been denied forever or not.
class LocationPermission extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const LocationPermission({
    Key? key,
    required this.isPermanent,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              'Location Permission',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'We need to request your permission to get '
              'your current location in order to run the app.',
              textAlign: TextAlign.center,
            ),
          ),
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'You need to give this permission from the system settings...',
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
                left: 16.0, top: 24.0, right: 16.0, bottom: 24.0),
            child: ElevatedButton(
              child: Text(isPermanent ? 'Open settings' : 'Allow access'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}
