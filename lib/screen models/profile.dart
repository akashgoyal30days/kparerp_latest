import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kparerp/api%20models/adddealer.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kparerp/api%20models/getdetails.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:launch_review/launch_review.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../main.dart';
import 'alert.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void showLoader(){
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
        ),
        isScrollControlled: true,
        elevation: 0,
        enableDrag: false,
        context: context,
        isDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width/1.3,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only( topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0)),
                          color: Color(0xff2a2d3e),
                        ),

                        child:Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              CircularProgressIndicator(
                              ),
                              Text('fetching details, please wait!!',
                                style: TextStyle(color: Colors.white),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              );
            }),
          );
        });}
  Future getinternaldet() async{
    try{
      var rsp = await GetDet(userid, token);
      debugPrint(rsp.toString());

      if (rsp.containsKey('status')){
        Navigator.pop(context);
        if(rsp['stcode'] == 411){
          appupdate();
        }
        if(rsp['stcode']== 412){
          expsession(context);
        }
        if(rsp['status']!= true){
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
        if(rsp['status']== true){
          setState(() {
            name = rsp['data']['name'];
            address = rsp['data']['address'];
            phone = rsp['data']['phone'];
            email = rsp['data']['email'];
            state = rsp['data']['state'];
            city = rsp['data']['city'];
            pin = rsp['data']['pin'];
            pan = rsp['data']['pan'];

          });
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
      }
    }catch(error){
      Navigator.pop(context);
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }

  }
  String name = '';
  String address = '';
  String phone = '';
  String email = '';
  String state = '';
  String city = '';
  String pin = '';
  String pan = '';
  Future<void> appupdate()async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
        ),
        isScrollControlled: true,
        elevation: 0,
        enableDrag: false,
        context: context,
        isDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width/1.3,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only( topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0)),
                          color: Color(0xff2a2d3e),
                        ),

                        child:Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('A new version is available on playstore, kindly update first',
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                    textAlign: TextAlign.center,),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    onPressed:() async{
                                      LaunchReview.launch(androidAppId: "com.in30days.kparerp.kparerp",
                                      );
                                    },
                                    child: const Text('Ok', style: TextStyle(color: Colors.blue),) ,
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              );
            }),
          );
        });}
  @override
  void initState(){
    getsaveddata().then((value) => [
      showLoader(),
      getinternaldet(),
      Senttoalert()
    ]);
    super.initState();
  }
  Future Senttoalert() async{
    if(locenable==false) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Alert()));
    }
  }

  String userid = '';
  String token = '';
  Future getsaveddata() async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userid = preference.getString('uid')!;
      token = preference.getString('token')!;
    });
    //debugPrint(token);
    //debugPrint(userid);
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return Dashboard();
            }));
        return true;
      },
      child: Scaffold(
          backgroundColor: Color(0xff212332),
          appBar: AppBar(
            backgroundColor: Color(0xff212332),
            title: Text('My Profile'),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                        return Dashboard();
                      }));
                }
            ),
          ),
          body:Container(
             child:ListView(
               children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('Name: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                        SizedBox(width: 5,),
                        if(name!='')
                        Text(name, style: TextStyle(color: Colors.white, fontSize: 20),),
                      ],
                    ),
                  ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('Address: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(address!='')
                       Expanded(child: Text(address, style: TextStyle(color: Colors.white, fontSize: 20),)),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('Phone: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(phone!='')
                       Text(phone, style: TextStyle(color: Colors.white, fontSize: 20),),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('Email: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(email!='')
                       Text(email, style: TextStyle(color: Colors.white, fontSize: 20),),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('State: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(state!='')
                       Text(state, style: TextStyle(color: Colors.white, fontSize: 20),),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('City: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(city!='')
                       Text(city, style: TextStyle(color: Colors.white, fontSize: 20),),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('Pin Code: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(pin!='')
                       Text(pin, style: TextStyle(color: Colors.white, fontSize: 20),),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       Text('Pan Number: ', style: TextStyle(color: Colors.white, fontSize: 20),),
                       SizedBox(width: 5,),
                       if(pan!='' && pan!= null)
                       Text(pan, style: TextStyle(color: Colors.white, fontSize: 20),),
                     ],
                   ),
                 )
               ],
             ),
          )
      ),
    );
  }
}


