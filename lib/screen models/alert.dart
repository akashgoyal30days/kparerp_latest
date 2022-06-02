import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:app_settings/app_settings.dart';

import '../main.dart';

class Alert extends StatefulWidget {
  const Alert({Key? key}) : super(key: key);

  @override
  _AlertState createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  Timer? t;

  void locat() async{
    bool locat = await Geolocator.isLocationServiceEnabled();
    if(locat==true){
      setState(() {
        locenable = true;
      });
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Dashboard()));
    }
  }

  // openSettingsMenu(settingsName) async {
  //   const oneSec = Duration(seconds:1);
  //   t = await Timer.periodic(oneSec, (Timer t) => locat());
  //   var resultSettingsOpening = false;
  //
  //   try {
  //     resultSettingsOpening =
  //     await AccessSettingsMenu.openSettings(settingsType: settingsName);
  //   } catch (e) {
  //     resultSettingsOpening = false;
  //   }
  // }

  @override
  void dispose(){
    t!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff212332),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_sharp, size: 150, color: Colors.white,),
            SizedBox(height:20),
            Text('Please enable your location to continue', style: TextStyle(decoration: TextDecoration.none, fontSize: 20,color: Colors.white,),textAlign: TextAlign.center,),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: RaisedButton(
               color: Colors.blue,
               elevation: 0,
               onPressed: (){
                 AppSettings.openLocationSettings();

               },
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text('Turn on GPS', style: TextStyle(color:Colors.white),),
             ),),
           )
          ],
        ),
      ),
    );
  }
}
