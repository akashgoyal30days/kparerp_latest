// @dart=2.9
import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kparerp/constants/color%20const.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:kparerp/screen%20models/login/login.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api models/regularloact.dart';

//whole app global variable
String appversion;
var myuser;
var mytoken;
bool islocateabled = true;
DateTime lastdate = DateTime.now();
bool locenable = true;
//------------global variable declaration ends--------------//

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //syntax for production before calling methods in void main to run on app start
  _initPackageInfo(); // to get app version
  SharedPreferences preference =
      await SharedPreferences.getInstance(); // initialising shared preference
  var username =
      preference.getString('uid'); // storing user id in username variable
  myuser =
      preference.getString('uid'); // storing user id in this global variable
  mytoken = preference
      .getString('token'); // storing user token in this global variable
  requestLocationPermission(); // requesting location permission on app start
  //debugPrint(username);
//  sentlocat();
  if (username != null) {
    BackgroundLocation
        .stopLocationService(); //stopping location tracking on app start so that we can restart it easily
    locatstream(
        mytoken); //starting location tracking again if user had not logged out
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'KPar Erp',
    home: username == null ? MyApp() : Dashboard(),
  ));
}

void startForegroundService() async {
  await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 300);
  await FlutterForegroundPlugin.setServiceMethod(locatstream);
  await FlutterForegroundPlugin.startForegroundService(
    holdWakeLock: false,
    onStarted: () {
      //locatstream();
      // sendlocation();
      //  debugPrint("Foreground on Started");
    },
    onStopped: () {
      //  debugPrint("Foreground on Stopped");
    },
    title: "KPar is tracking your location",
    content: "Kindly keep your gps enabled and dont kill the app",
    iconName: "mipmap/ic_launcher",
  );
}

void globalForegroundService() {
  debugPrint("current datetime is ${DateTime.now()}");
}

void locatstream(String token) async {
  _getLocation(); // get current location
  await BackgroundLocation.startLocationService(); //start location tracking
  await BackgroundLocation.setAndroidConfiguration(10000); //setting time config
  await BackgroundLocation.setAndroidNotification(
    title: "KPar is tracking your location",
    message: "Kindly keep your gps enabled and dont kill the app",
    icon: "mipmap/ic_launcher",
  );
  // setting texts writtern in notification tray
  await BackgroundLocation.startLocationService(
      distanceFilter: 10); //setting distance filter

  await BackgroundLocation.startLocationService(
      forceAndroidLocationManager:
          false); // starting method channel for location

  //-------fetching and sending location upodates------------//
  await BackgroundLocation.getLocationUpdates((location) {
    debugPrint(location.latitude.toString());
    mlat = location.latitude.toString();
    mlng = location.longitude.toString();
    debugPrint(lastdate.toString());
    debugPrint(DateTime.now().difference(lastdate).inSeconds.toString());
    if (DateTime.now().difference(lastdate).inSeconds > 299) {
      sendlocation(token); // sending location to server on every 5 minute
    }
  });
/*  StreamSubscription<Position> positionStream = getPositionStream()
      .listen((Position position) {
    debugPrint(position.toString());
    if(position!=null){
      mlat = position.latitude.toString();
      mlng = position.longitude.toString();
    }
    // Handle position changes
  });*/
}

PackageInfo _packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
);
Future<void> _initPackageInfo() async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  _packageInfo = info;
  appversion = _packageInfo.version.toString();
}

Future sendlocation(String token) async {
  lastdate = DateTime.now();
  var rspp = await Regularlocat(_packageInfo.version.toString(),
      myuser.toString(), token.toString(), mlat.toString(), mlng.toString());
  //debugPrint("aa"+rspp.toString());
  if (rspp['stcode'] == 412) {
    // FlutterForegroundPlugin.stopForegroundService();
    SharedPreferences preference = await SharedPreferences.getInstance();
    BuildContext context;
    // Navigator.popUntil(context, (_) => !Navigator.canPop(context));
    Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (context) => Login(
                  backscreen: 'expsession',
                )));
  }
}

Position muserLocation;
var mlng, mlat;
var mcurrentLocation;
bool misLocationEnabled;
Stream<Position> getPositionStream({
  LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  int distanceFilter = 0,
  bool forceAndroidLocationManager = false,
  Duration intervalDuration,
  Duration timeLimit,
}) =>
    GeolocatorPlatform.instance.getPositionStream(
      desiredAccuracy: desiredAccuracy,
      distanceFilter: distanceFilter,
      forceAndroidLocationManager: forceAndroidLocationManager,
      timeInterval: 500, //240000,
      timeLimit: timeLimit,
    );
Future<Position> _getLocation() async {
  try {
    misLocationEnabled = await Geolocator.isLocationServiceEnabled();
    islocateabled = misLocationEnabled;
    if (misLocationEnabled == false) {
      BackgroundLocation.stopLocationService();
      // Alert();
      locenable = false;
      //SystemNavigator.pop();
    }
    debugPrint('enabled or not - $misLocationEnabled');
  } catch (e) {
    mcurrentLocation = null;
  }
  return mcurrentLocation;
}

final PermissionHandler permissionHandler = PermissionHandler();
Map<PermissionGroup, PermissionStatus> permissions;
Future<bool> _requestPermission(PermissionGroup permission) async {
  final PermissionHandler _permissionHandler = PermissionHandler();
  var result = await _permissionHandler.requestPermissions([permission]);
  if (result[permission] == PermissionStatus.granted) {
    return true;
  }
  return false;
}

//Checking if your App has been Given Permission/
Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
  var granted = await _requestPermission(PermissionGroup.location);
  if (granted != true) {
    requestLocationPermission();
  }
  // debugPrint('requestContactsPermission $granted');
  //debugPrint('mmlat - ${mcurrentLocation}');
  return granted;
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KPar Erp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryBlack,
      ),
      home: const MyHomePage(title: 'KPar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    nextscreen();
    super.initState();
  }

  Future nextscreen() async {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Login(
          backscreen: 'normal',
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff212332),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
