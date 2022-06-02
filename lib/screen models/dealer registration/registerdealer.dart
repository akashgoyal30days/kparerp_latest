import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kparerp/api%20models/adddealer.dart';
import 'package:kparerp/api%20models/getturnover_and_Company.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:launch_review/launch_review.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../alert.dart';

class RegDelaer extends StatefulWidget {
  @override
  State<RegDelaer> createState() => _RegDelaerState();
}

class _RegDelaerState extends State<RegDelaer> {
  dynamic emailController = TextEditingController();
  dynamic nameController = TextEditingController();
  dynamic addressController = TextEditingController();
  dynamic mobileController = TextEditingController();
  dynamic firmController = TextEditingController();
  dynamic turnoverController = TextEditingController();
  var turnlist = [];
  var complist = [];
  var currlist = [];
  final _formnewkey = GlobalKey<FormState>();
  bool showthis = true;
  String? _mycreditmodal;
  var intrim_credit_val = '';
  String? _valuenew;
  String? turn;
  String? regas;
  String? _mycreditproduct;
  final PermissionHandler permissionHandler = PermissionHandler();
  late Map<PermissionGroup, PermissionStatus> permissions;
  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future getinternaldet() async{
    try{
      var rsp = await TurnDet(userid, token);
      debugPrint(rsp.toString());

      if (rsp.containsKey('status')){
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
            complist=rsp['companies'];
            turnlist = rsp['turnover'];
            currlist = rsp['ctype'];
          });
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
      }
    }catch(error){
      debugPrint(error.toString());
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }

  }


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
  //Checking if your App has been Given Permission/
  Future<bool> requestLocationPermission({Function? onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
      debugPrint('requestContactsPermission $granted');
    return granted;
  }
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
                              Text('Uploading details, please wait!!',
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

  @override
  void initState(){
    getsaveddata();
    requestLocationPermission();
    _getLocation();
    Senttoalert();
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
      userid = preference.getString('uid').toString();
      token = preference.getString('token').toString();
    });
    debugPrint(token);
    getinternaldet();
  }

  Position? userLocation;
  var lng, lat;
  var currentLocation;
  bool? isLocationEnabled;
  Future<Position> _getLocation() async {
    try {
        isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      userLocation =  currentLocation;
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
      debugPrint(lat);
        debugPrint(currentLocation);
        debugPrint(lat);
    }catch (e) {
      currentLocation = null;
       }
    return currentLocation;
  }
  var addresses;
  String address = '';
  var first;
  File _image = File('');
  //get address
  Future getAddress() async{
    final coordinates = new Coordinates(double.parse(mlat),double.parse(mlng));
    addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    first = addresses.first;
 /*     debugPrint("${first.featureName} , ${first.addressLine}");
    debugPrint('1 ${first.locality}');
    debugPrint('2 ${first.adminArea}');
    debugPrint('3 ${first.subLocality}');
    debugPrint('4 ${first.subAdminArea}');
    debugPrint('5 ${first.addressLine}');
    debugPrint('6 ${first.featureName}');
    debugPrint('7 ${first.thoroughfare}');
    debugPrint('8 ${first.subThoroughfare}');*/

    setState(() {
        address = "${first.addressLine}";
        addressController.text = address;
      });
    }

  List<String> selectedcomp = <String>[];
  String? img64;
  final picker = ImagePicker();
  //getting image function
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera, imageQuality: 100, maxHeight: 700,  maxWidth: 700, preferredCameraDevice: CameraDevice.rear);
    final bytes = await File(pickedFile.path).readAsBytesSync();
    img64 = base64.encode(bytes);

      debugPrint(img64!.substring(0, img64!.length));

      debugPrint(base64Decode(img64!).toString());

    setState(() {
      _image = File(pickedFile.path);
    });
    debugPrint(_image.toString.toString());

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
            title: Text('Register Dealer'),
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
            child:ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Form(
                      key: _formnewkey,
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Padding(
                            padding:const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: const Color(0xff1c1c1c),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius:const BorderRadius.all(Radius.circular(20))
                              ),
                              child: TextFormField(
                                //initialValue: "I am smart",
                                autocorrect: true,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,

                                decoration: const InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    labelText: 'Name',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: nameController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: const Color(0xff1c1c1c),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius:const BorderRadius.all(Radius.circular(20))
                              ),
                              child: TextFormField(
                                //initialValue: "I am smart",
                                autocorrect: true,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,

                                decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    enabledBorder: const OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    labelText: 'Address',
                                    suffixIcon: IconButton(icon:Icon(Icons.location_on), onPressed: (){
                                      getAddress();
                                    },
                                      color: Colors.blue,),

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: addressController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: const Color(0xff1c1c1c),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius:const BorderRadius.all(Radius.circular(20))
                              ),
                              child: TextFormField(
                                //initialValue: "I am smart",
                                autocorrect: true,
                                cursorColor: Colors.white,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                    isDense: true,
                                    filled: true,

                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    labelText: 'Mobile number',


                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: mobileController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty|| value.length < 10) {
                                    return 'Please enter valid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: const Color(0xff1c1c1c),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius:const BorderRadius.all(Radius.circular(20))
                              ),
                              child: TextFormField(
                                //initialValue: "I am smart",
                                autocorrect: true,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,

                                decoration: const InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    labelText: 'Email ID',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: emailController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                /*validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  return null;
                                },*/
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: const Color(0xff1c1c1c),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius:const BorderRadius.all(Radius.circular(20))
                              ),
                              child: TextFormField(
                                //initialValue: "I am smart",
                                autocorrect: true,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,

                                decoration: const InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    labelText: 'Firm Name',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: firmController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter firm name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Container(
                              width: 500,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xff1c1c1c),
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 25, 10),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButton<String>(
                                      dropdownColor: Color(0xFF2A2D3E),
                                      elevation: 0,
                                      value: regas,
                                      iconSize: 30,
                                      icon: Icon(Icons.arrow_drop_down,color: Colors.blue,),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                      hint: Text('Register as',style: TextStyle(color: Colors.grey),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          regas = value.toString();
                                        });


                                      },
                                      items: currlist?.map((itemn) {
                                        return DropdownMenuItem(
                                          child: Text(itemn['label'],style: TextStyle(color: Colors.grey),),
                                          value: itemn['type'].toString(),
                                        );
                                      })?.toList() ??
                                          [],

                                    ),
                                  ),
                                ),
                              ),),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Container(
                              width: 500,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xff1c1c1c),
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 25, 10),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButton<String>(
                                      dropdownColor: Color(0xFF2A2D3E),
                                      elevation: 0,
                                      value: turn,
                                      iconSize: 30,
                                      icon: Icon(Icons.arrow_drop_down,color: Colors.blue,),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                      hint: Text('Turnover',style: TextStyle(color: Colors.grey),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          turn = value.toString();
                                        });


                                      },
                                      items: turnlist?.map((itemn) {
                                        return DropdownMenuItem(
                                          child: Text(itemn,style: TextStyle(color: Colors.grey),),
                                          value: itemn.toString(),
                                        );
                                      })?.toList() ??
                                          [],

                                    ),
                                  ),
                                ),
                              ),),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Container(
                              width: 500,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xff1c1c1c),
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 25, 10),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButton<String>(
                                      dropdownColor: Color(0xFF2A2D3E),
                                      elevation: 0,
                                      value: _valuenew,
                                      iconSize: 30,
                                      icon: Icon(Icons.arrow_drop_down,color: Colors.blue,),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                      hint: Text('Select Companies',style: TextStyle(color: Colors.grey),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _valuenew = value.toString();
                                          if(_valuenew != null) {
                                            if (!selectedcomp.contains(_valuenew)) {
                                              selectedcomp.add(_valuenew!);
                                            }
                                          }
                                        });


                                      },
                                      items: complist?.map((itemn) {
                                        return DropdownMenuItem(
                                          child: Text(itemn,style: TextStyle(color: Colors.grey),),
                                          value: itemn.toString(),
                                        );
                                      })?.toList() ??
                                          [],

                                    ),
                                  ),
                                ),
                              ),),
                          ),
                          if(selectedcomp.isNotEmpty && showthis == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 25, top: 8, bottom: 8),
                              child: Container(
                                height: 30,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedcomp.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          //width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.transparent,
                                            ),
                                            borderRadius: new BorderRadius.circular(30.0),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(selectedcomp[index].toString()),
                                              GestureDetector(
                                                  onTap: (){
                                                    selectedcomp.removeWhere((
                                                        val) => val ==
                                                        selectedcomp[index].toString());
                                                    debugPrint(selectedcomp.toString());
                                                    setState(() {
                                                      showthis = true;
                                                      _valuenew = 'start';
                                                    });
                                                  },
                                                  child: const Icon(Icons.cancel, color: Colors.red,)),
                                            ],
                                          ),
                                        ));
                                  },
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30, top: 8, bottom: 20),
                            child: const Text('Pick Image', style: TextStyle(color: Colors.white, fontSize: 20),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: (){
                                  getImage();
                                },
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2,
                                          color: Theme.of(context).scaffoldBackgroundColor),
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color: Colors.black.withOpacity(0.1),
                                            offset: Offset(0, 10))
                                      ],
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: _image == null  //profilePhoto which is File object
                                              ?FileImage(_image)
                                              : FileImage(_image), // picked file
                                          fit: BoxFit.fill)),
                                  child: Center(
                                    child: _image == null?Icon(Icons.camera, size: 30,color: Colors.white,):Container(),
                                  ),
                                ),

                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width/2,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if(_formnewkey.currentState!.validate()) {
                                        //showLoader();
                                        if (_image != null && selectedcomp.isNotEmpty && regas != null && turn != null) {
                                          var email = emailController.text;
                                          var name = nameController.text;
                                          var add = addressController.text;
                                          var mob = mobileController.text;
                                          var firm = firmController.text;
                                          var comp = selectedcomp.toString();
                                          debugPrint(comp.toString());
                                          try {
                                            showLoader();
                                            var rsp = await AddDealer(userid, token, name, add, mob, email, mlat.toString(), mlng.toString(), firm, turn.toString(), comp, img64.toString(), regas.toString());
                                            debugPrint(rsp.toString());
                                            if (rsp.containsKey('status')) {
                                              Navigator.pop(context);
                                              if(rsp['stcode'] == 411){
                                                appupdate();
                                              }
                                              if(rsp['stcode']== 412){
                                                expsession(context);
                                              }
                                              Toast.show(rsp['message'], context,
                                                  duration: Toast.LENGTH_LONG,
                                                  gravity: Toast.TOP,
                                                  backgroundColor: Colors.white,
                                                  textColor: Colors.black,
                                                  backgroundRadius: 10);
                                            }
                                            if (rsp['status'] == "true") {
                                              emailController.clear();
                                              nameController.clear();
                                              addressController.clear();
                                              mobileController.clear();
                                              firmController.clear();
                                              selectedcomp.clear();
                                              _image = File('');
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(builder: (context) {
                                                    return Dashboard();
                                                  }));
                                            }
                                            else {
                                              Toast.show(rsp['message'], context,
                                                  duration: Toast.LENGTH_LONG,
                                                  gravity: Toast.TOP,
                                                  backgroundColor: Colors.white,
                                                  textColor: Colors.black,
                                                  backgroundRadius: 10);
                                            }
                                            //debugPrint(rsp);
                                          } catch (error) {
                                            Navigator.pop(context);
                                            debugPrint(error.toString());
                                          }
                                        }
                                        else{
                                          Toast.show('Please confirm that you had taken the image and selected the listed company or type of registration and turnover', context,
                                              duration: Toast.LENGTH_LONG,
                                              gravity: Toast.TOP,
                                              backgroundColor: Colors.white,
                                              textColor: Colors.black,
                                              backgroundRadius: 10);
                                        }
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text('Submit'),
                                        Icon(Icons.upload, size: 18,)
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(shape: const StadiumBorder(), elevation: 0,primary: Colors.blue, ),
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ),
          ),
    );
  }
}


