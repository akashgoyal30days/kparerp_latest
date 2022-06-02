import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:kparerp/main.dart';
import 'package:kparerp/screen%20models/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future logOut(BuildContext context) async{
  //FlutterForegroundPlugin.stopForegroundService();
  BackgroundLocation.stopLocationService();
  SharedPreferences preference = await SharedPreferences.getInstance();
  preference.remove('uid');
  preference.remove('token');
  Navigator.popUntil(context, (_) => !Navigator.canPop(context));

  Navigator.pushReplacement(context,
      new MaterialPageRoute(builder: (context) => Login(backscreen: 'logout',)));
}

Future expsession(BuildContext context) async{
  BackgroundLocation.stopLocationService();
  SharedPreferences preference = await SharedPreferences.getInstance();
  preference.remove('uid');
  preference.remove('token');
  Navigator.popUntil(context, (_) => !Navigator.canPop(context));
  Navigator.pushReplacement(context,
      new MaterialPageRoute(builder: (context) => Login(backscreen: 'expsession',)));
}