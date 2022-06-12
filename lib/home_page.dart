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
  final PermissionProvider _permissionProvider = PermissionProvider();
  bool _detectPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionProvider.getGeoLocationPosition();
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
        (_permissionProvider.permissionStatus == Permissions.granted)) {
      _permissionProvider.checkLocationService();
    }
    if (state == AppLifecycleState.resumed &&
        _detectPermission &&
        (_permissionProvider.permissionStatus == Permissions.permanentlyDenied)) {
      _detectPermission = false;
      _permissionProvider.requestPermission();
    } else if (state == AppLifecycleState.paused &&
        _permissionProvider.permissionStatus == Permissions.permanentlyDenied) {
      _detectPermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _permissionProvider,
      child: Consumer<PermissionProvider>(
        builder: (context, provider, child) {
          Widget _body;
          switch (provider.permissionStatus) {
            case Permissions.granted:
            _body = provider.locationIsEnabled ? Center(
              child: Text(
                'Your location coordinates: \n\n'
                    'Latitude: ${provider.position?.latitude}\n'
                    'Longitude: ${provider.position?.longitude}'
              ),
            ): Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enable the location service!',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.indigo,
                      ),
                    ),
                    onPressed: () {
                      provider.requestToEnableLocationService();
                    },
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
              break;
            case Permissions.denied:
              _body = NoPermission(
                isPermanentlyDenied: false,
                onPressed: provider.getGeoLocationPosition,
              );
              break;
            case Permissions.permanentlyDenied:
              _body = NoPermission(
                isPermanentlyDenied: true,
                onPressed: provider.getGeoLocationPosition,
              );
              break;
          }

          return WillPopScope(
            onWillPop: provider.onWillPopFunction,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.purple,
                title: const Text('Permission Handling'),
                centerTitle: true,
              ),
              body: SafeArea(child: _body),
            ),
          );
        },
      ),
    );
  }
}


/// This widget will serve to inform the user in
/// case the permission has been denied. There is a
/// variable [isPermanentlyDenied] to indicate whether the
/// permission has been denied forever or not.
class NoPermission extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback onPressed;

  const NoPermission({
    Key? key,
    required this.isPermanentlyDenied,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Location Permission',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'We need to request your permission to get '
                'your current location in order to run the app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (isPermanentlyDenied)
            const Text(
              'You need to give this permission from the system settings...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.purple,
              ),
            ),
            onPressed: () {
              isPermanentlyDenied ? openAppSettings() : onPressed();
            },
            child: Text(
              isPermanentlyDenied ? 'Open settings' : 'Allow access',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
