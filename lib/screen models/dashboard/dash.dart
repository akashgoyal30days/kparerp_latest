import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kparerp/api%20models/docheckout.dart';
import 'package:kparerp/api%20models/getcheckinout.dart';
import 'package:kparerp/api%20models/getdetails.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'package:kparerp/api%20models/logoutserver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:kparerp/screen%20models/customerledger.dart';
import 'package:kparerp/screen%20models/dealer%20registration/registerdealer.dart';
import 'package:kparerp/screen%20models/mydealers.dart';
import 'package:kparerp/screen%20models/outstandingreport.dart';
import 'package:kparerp/screen%20models/profile.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/constants.dart';
import '../../main.dart';
import '../alert.dart';
import '../cpassword.dart';
import '../newdealers.dart';
import '../pricelist.dart';
import '../stockcurrent.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  bool clickedcheckout = false;
  dynamic remarksController = TextEditingController();
  dynamic orderValController = TextEditingController();
  dynamic totalValController = TextEditingController();
  dynamic pendingValController = TextEditingController();
  dynamic payRecvController = TextEditingController();
  String? img64;
  String? filebase64;
  File? _image;
  File? imageResized;
  final picker = ImagePicker();
  List<File> imagefiles = [];
  var pdf = pw.Document();
  List<Uint8List> imagesUint8list = [];
  img.Image? fixedImage;
  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera, imageQuality: 100, maxHeight: 1080,  maxWidth: 1080, preferredCameraDevice: CameraDevice.rear);
    final bytes = await File(pickedFile.path).readAsBytesSync();
    img64 = base64Encode(bytes);
      debugPrint(img64!.substring(0, img64!.length));
    setState(() {
      _image = File(pickedFile.path);
      imagefiles.add(_image!);
    });
  }
  createPDF() async {
    setState(() {
      pdf = pw.Document();
    });
    for (var img in imagefiles) {
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.FittedBox(child: pw.Image(image));
          }));
    }
    getdirectory();
    setState(() {

    });
  }
  String filename = '';
  void showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>   WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
            title: Column(
              children: [
                Text('This app collects location data to enable'),
                RichText(
                  textAlign: TextAlign.start,
                  text: new TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: new TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),

                    children: <TextSpan>[
                      new TextSpan(text: '-Location based attendance marking\n', style: new TextStyle(fontSize: 15)),
                      new TextSpan(text: '-Employer/Company can track your live location\n', style: new TextStyle(fontSize: 15)),
                      new TextSpan(text: '-To check and approve your travel\n', style: new TextStyle(fontSize: 15)),
                      new TextSpan(text: 'allowances even when the app is closed or not in use\n', style: new TextStyle(fontSize: 15)),
                      new TextSpan(text: '\n\nDo you want to allow?\n', style: new TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
            content: GestureDetector(
              onTap: () async {
                await launch("https://ezhrm.in/locationpolicy");
              },
              child: new RichText(
                textAlign: TextAlign.justify,
                text: new TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: new TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),

                  children: <TextSpan>[
                    new TextSpan(text: 'Click ', style: new TextStyle(fontSize: 15)),
                    new TextSpan(text: 'here ', style: new TextStyle(fontSize: 15, color: Colors.blue)),
                    new TextSpan(text: 'for details.', style: new TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Allow"),
                isDefaultAction: true,
                onPressed: ()async{
                  SharedPreferences allowed = await SharedPreferences.getInstance();
                  allowed.setString("isallowed", "yes");
                  Navigator.pop(context);

                  //startForegroundService('Admin is tracking your location', 'Please Keep Your GPS Enabled');
                  // Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text("Exit"),
                isDefaultAction: true,
                onPressed: ()async{
                  FlutterForegroundPlugin.stopForegroundService();
                  SystemNavigator.pop();
                },
              )
            ],
          ),
        )
    );
  }

  Future<bool> _requestPermissions() async{
    var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    if(permission != PermissionStatus.granted){
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }
  bool debug = true;
  Future<Directory?> _getDownloadDirectory() async{
    if(Platform.isAndroid){
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }
  final DateFormat formatter = DateFormat('ddMMyyyyhhmmss');
  Directory? appDocDir;
  String? filePath;
  String? fname;
  showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.info,
        color: Colors.blue,
      ),
    )..show(context);
  }
  Future getdirectory() async {
    setState(() {
      fname = formatter.format(DateTime.now());
    });
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if(isPermissionStatusGranted){
      final Directory _appDocDirFolder = Directory('${dir!.path}/KPar Erp');
      if(await _appDocDirFolder.exists()) {
        debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/KPar Erp';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        debugPrint(filePath);
        if (imagefiles.isNotEmpty) {
          try {
            final file = File(
                '${filePath}/${fname}.pdf');
            await file.writeAsBytes(await pdf.save());

            setState(() {
              filename = file.path.toString();
            });
            final bytes = await File(file.path).readAsBytesSync();
            filebase64 = base64.encode(bytes);
            if(filebase64!=null) {
              Checkout();
            }
         //   submitHome(commentController.text, filename, fname!);
          } catch (e) {
            showPrintedMessage('error', e.toString());
          }
        }
      }
      else {
        final Directory _appDocNewFolder = await _appDocDirFolder.create(
            recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/KPar Erp';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        if (imagefiles.isNotEmpty) {
          try {
            final file = File(
                '${filePath}/${fname}.pdf');
            await file.writeAsBytes(await pdf.save());
            setState(() {
              filename = file.path.toString();
            });
            final bytes = await File(file.path).readAsBytesSync();
            filebase64 = base64.encode(bytes);
            if(filebase64!=null) {
              Checkout();
            }
            //submitHome(commentController.text, filename, fname!);
          } catch (e) {
            showPrintedMessage('error', e.toString());
          }
        }
      }
    }
  }
  String? extension;
  String? selectedfilename;




  @override
  void initState(){
    showmyalert();
    Senttoalert();
    _initPackageInfo();
    requestLocationPermission();

    getsaveddata().then((value) =>[
      if(checkdata == false && isenteredcheck == false){
        check(),
      },


    ]

    );
    super.initState();
    setState(() {
      isenteredcheck = false;
    });
    WidgetsBinding.instance!.addObserver(this);
  }
  Future Senttoalert() async{
    if(locenable==false) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Alert()));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
    debugPrint(_lastLifecycleState.toString());
    if(_lastLifecycleState==AppLifecycleState.detached){
      debugPrint('detatched');
    }
  }


  Future<void> showmyalert() async {
    SharedPreferences allowed = await SharedPreferences.getInstance();
    debugPrint(allowed.getString("isallowed").toString());
    if(allowed.getString("isallowed")!="yes"){
      Future.delayed(Duration.zero, () => showAlert(context));
    }
  }
  bool checkdata= false;
  String dtype= '';
  String userid = '';
  String token = '';
  Future getsaveddata() async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userid = preference.getString('uid')!;
      token = preference.getString('token')!;
    });
   // //debugPrint(token);
   // //debugPrint(userid);
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
                              Text('Fetching details, please wait!!',
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
  String cid = '';


  void chcloader(){
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
                              Text('Checking out, please wait!!',
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

  void enterremarks(){
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
                        height: 200,
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
                             const Text('Enter remarks to continue check out',
                                style: TextStyle(color: Colors.white),),
                              Padding(
                                padding:EdgeInsets.all(20.0),
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
                                        labelText: 'Enter remarks',

                                        labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                    controller: remarksController,
                                    //initialValue: 'initial value',
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter remarks';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    onPressed:(){
                                      if(remarksController.text != ''){
                                      _getLocation().then((value) =>
                                      [
                                      if(lat != null && lng != null){
                                        setState(() {
                                          ischeckoutclicked = true;
                                        }),
                                        Navigator.pop(context),
                                        chcloader(),
                                        Checkout(),
                                      }
                                      ]);
                                    }else{
                                        Toast.show('Please enter the remarks', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                      }},
                                    child: const Text('Continue', style: TextStyle(color: Colors.blue),) ,
                                  ),
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    onPressed:(){
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel', style: TextStyle(color: Colors.white),) ,
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

  void logout(){
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
                              const Text('Are you sure you want to logout ?',
                                style: TextStyle(color: Colors.white),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    onPressed:() async{
                                      logOut(context);
                                      try {
                                        var rsp = await LogOutServer(
                                            userid, token);
                                        debugPrint(rsp.toString());
                                      } catch(error){
                                        debugPrint(error.toString());
                                      }
                                      },
                                    child: const Text('Yes', style: TextStyle(color: Colors.blue),) ,
                                  ),
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    onPressed:(){
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel', style: TextStyle(color: Colors.white),) ,
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
     // debugPrint(lat);
     // debugPrint(currentLocation);
     // debugPrint(lat);
    }catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }
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
  //Checking if your App has been Given Permission/
  Future<bool> requestLocationPermission({Function? onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
   // debugPrint('requestContactsPermission $granted');
    return granted;
  }


  // check out
  Future Checkout() async{
    try{
      var rsp = await Docheckout(userid, token, mlat.toString(), mlng.toString(), dtype.toString(), cid, remarksController.text, payRecvController.text,
      filebase64!,orderValController.text);
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')){
        Navigator.pop(context);
        if(rsp['stcode'] == 411){
          appupdate();
        }
        if(rsp['stcode']== 412){
          expsession(context);
        }
        if(rsp['status'] == true){
          setState(() {
            check();
            payRecvController.clear();
            pendingValController.clear();
            imagefiles.clear();
            totalValController.clear();
            orderValController.clear();
            filebase64=null;
            setState((){
              clickedcheckout = false;
            });
          });
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
        if(rsp['status']!= true){
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
      }
    }catch(error){
      Navigator.pop(context);
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }

  }
 bool ischeckoutclicked = false;
  bool isenteredcheck = false;
  PackageInfo _packageInfos = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    _packageInfos = info;

  }
  //check if checkin or out
  Future check() async{
    setState(() {
      isenteredcheck = true;
    });
    try{
    var rsp = await Checkinout(_packageInfos.version.toString(),userid, token);
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
      }else{
        setState((){
          checkdata = rsp['checked_in'];
          dtype = rsp['dtype'];
          cid = rsp['cid'];
          pendingValController.text = rsp['outstanding'].toString();
          totalValController.text = rsp['outstanding'].toString();
        });

        //debugPrint(checkdata);
          initState();
      }
        }
  }catch(error){
      //Navigator.pop(context);
      //debugPrint(error.toString());
    //  Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }

  }
  final _formnewkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      backgroundColor: Color(0xff212332),
      appBar: AppBar(
        title: Text(apptitle),
        leading:  Container(),
        backgroundColor: Color(0xff212332),
        actions: [
          IconButton(icon:Icon(Icons.logout), onPressed: (){
            logout();
          },)
        ],
      ),
      body: Container(

        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              if(clickedcheckout==false)
              Expanded(
                child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.5,
                    children: List.generate(8, (index) {
                      return GestureDetector(
                        onTap: (){
                          if(index==0){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return RegDelaer();
                                }));
                          }
                          if(index==1){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return MyDealers(  chck: checkdata,);
                                }));
                          }
                          if(index==2){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return CustomerLedger();
                                }));
                          }
                          if(index==3){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return OutstandingReport();
                                }));
                          }
                         /* if(index==4){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return CurrentStock();
                                }));
                          }*/
                          if(index==4){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return PriceList();
                                }));
                          }
                          if(index==5){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return NewDealers(
                                    chck: checkdata,
                                  );
                                }));
                          }
                          if(index==6){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return Cpwd(
                                  );
                                }));
                          }
                          if(index==7){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return Profile(
                                  );
                                }));
                          }

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only( topRight: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(0.0)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              stops: [0.1, 0.1, 0.2, 0.6],
                              colors: [
                                Colors.blue.withOpacity(0.0),
                                Colors.blue.withOpacity(0.4),
                                Colors.blue.withOpacity(0.1),
                                Colors.blue.withOpacity(0.0),
                              ],
                            ),

                          ),
                          child: Column(
                            children: [
                              if(index==0)
                                SizedBox(height: 10,),
                              if(index==0)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(Icons.app_registration, color: Color(0xffff9502),size: 50,))),
                                ),
                              if(index == 0)
                                SizedBox(height: 5,),
                              if(index==0)
                                const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index==0)
                                const Text('Dealer', style: TextStyle(color: Colors.white, fontSize: 16),),
                              if(index == 1)
                                SizedBox(height: 10,),

                              if(index == 1)
                                SizedBox(height: 10,),
                              if(index==1)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(Icons.search_sharp, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 1)
                                SizedBox(height: 5,),

                              if(index==1)
                                const Text('Dealers', style: TextStyle(color: Colors.white, fontSize: 16),),

                              if(index == 2)
                                SizedBox(height: 10,),
                              if(index==2)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(Icons.receipt, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 2)
                                SizedBox(height: 5,),
                              if(index==2)
                                const Text('Customer', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index==2)
                                const Text('Ledger', style: TextStyle(color: Colors.white, fontSize: 16),),
                              if(index == 3)
                                SizedBox(height: 10,),
                              if(index==3)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(CupertinoIcons.graph_circle_fill, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 3)
                                SizedBox(height: 5,),
                              if(index==3)
                                const Text('Outstanding', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index==3)
                                const Text('Report', style: TextStyle(color: Colors.white, fontSize: 16),),
                            /*  if(index == 4)
                                SizedBox(height: 10,),
                              if(index==4)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(CupertinoIcons.graph_circle_fill, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 4)
                                SizedBox(height: 5,),
                              if(index==4)
                                const Text('Current', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index==4)
                                const Text('Stock', style: TextStyle(color: Colors.white, fontSize: 16),),*/
                              if(index == 4)
                                SizedBox(height: 10,),
                              if(index==4)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(CupertinoIcons.graph_circle_fill, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 4)
                                SizedBox(height: 5,),
                              if(index==4)
                                const Text('Price', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index==4)
                                const Text('List', style: TextStyle(color: Colors.white, fontSize: 16),),
                              if(index == 5)
                                SizedBox(height: 10,),
                              if(index==5)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(CupertinoIcons.graph_circle_fill, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 5)
                                SizedBox(height: 5,),
                              if(index==5)
                                const Text('New', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index==5)
                                const Text('Dealers', style: TextStyle(color: Colors.white, fontSize: 16),),
                              if(index == 6)
                                SizedBox(height: 10,),
                              if(index== 6)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(Icons.vpn_key, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 6)
                                SizedBox(height: 5,),
                              if(index== 6)
                                const Text('Change', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index== 6)
                                const Text('Password', style: TextStyle(color: Colors.white, fontSize: 16),),

                              if(index== 7)
                                Align(
                                  alignment:Alignment.center,
                                  child: Container(
                                      height:50,
                                      width: 50,
                                      color: Colors.transparent,
                                      child: Center(child: const Icon(Icons.person, color: Color(0xffff9502),size: 50,))),

                                ),
                              if(index == 7)
                                SizedBox(height: 5,),
                              if(index== 7)
                                const Text('My', style: TextStyle(color: Colors.white, fontSize: 18),),
                              if(index== 7)
                                const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 16),),
                            ],
                          ),
                        ),
                      );
                    }
                    )
                ),
              ),
                if(clickedcheckout==true)
                Expanded(
                  child: Container(
                    child: Form(
                      key: _formnewkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:[
                          SizedBox(height:10),
                          const Text('Please fill all fields to check out',
                            style: TextStyle(color: Colors.white),),
                          Padding(
                            padding:EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
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
                                enabled: false,
                                autocorrect: true,
                                cursorColor: Colors.white,
                                keyboardType: TextInputType.number,
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
                                    labelText: 'Pending Value',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: pendingValController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter pending value';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding:EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
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
                                    labelText: 'Order Value',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: orderValController,
                                //initialValue: 'initial value',
                                onChanged: (val){
                                if(val.isNotEmpty){
                                  setState(() {
                                    totalValController.text = (int.parse(pendingValController.text.toString())+int.parse(val.toString())).toString();
                                  });
                                }

                                  if(val.isEmpty){
                                    val = '0';
                                    setState((){
                                      totalValController.text = (int.parse(pendingValController.text.toString())+0).toString();
                                    });

                                  }
                                },
                                onEditingComplete: (){
                                  totalValController.text = (int.parse(pendingValController.text.toString())+int.parse(orderValController.toString())).toString();
                                },
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    setState(() {
                                      totalValController.text = (int.parse(pendingValController.text.toString())+0).toString();
                                    });
                                    return 'Please enter order value';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding:EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
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
                                enabled: false,
                                //initialValue: "I am smart",
                                autocorrect: true,
                                cursorColor: Colors.white,
                                keyboardType: TextInputType.number,
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
                                    labelText: 'Total Value',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: totalValController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter total value';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding:EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
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
                                    labelText: 'Payment Recieved',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: payRecvController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter recieved payment value';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding:EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
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
                                    labelText: 'Enter remarks',

                                    labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                                controller: remarksController,
                                //initialValue: 'initial value',
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter remarks';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                child: Row(
                                  children: [
                                    Icon(Icons.camera, size: 50,color: Colors.white),
                                    Text('Pick Image',
                                    style: TextStyle(fontSize: 20, color:Colors.white))
                                  ],
                                ),
                                onPressed: (){
                                  getImageFromCamera();
                                }
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                elevation: 0,
                                color: Colors.transparent,
                                onPressed:(){
                                  setState((){
                                    clickedcheckout = false;
                                  });

                                },
                                child: const Text('Cancel', style: TextStyle(color: Colors.white),) ,
                              ),
                              RaisedButton(
                                elevation: 0,
                                color: Colors.transparent,
                                onPressed:(){
                                 if(_formnewkey.currentState!.validate()){
                                  if(imagefiles.isNotEmpty){

                                    _getLocation().then((value) =>
                                    [
                                      if(lat != null && lng != null){
                                        setState(() {
                                          ischeckoutclicked = true;
                                        }),
                                        //Navigator.pop(context),
                                        chcloader(),
                                        createPDF(),

                                      }
                                    ]);
                                  }else{
                                    Toast.show('Please pick image before continuing', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                  }}
                                 },
                                child: const Text('Continue', style: TextStyle(color: Colors.blue),) ,
                              ),
                            ],
                          ),
                          if(imagefiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 150,
                                child: GridView.count(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 2.0,
                                    mainAxisSpacing: 2.0,
                                    shrinkWrap: false,
                                    children: List.generate(imagefiles.length, (index) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          image: new DecorationImage(
                                            image: FileImage(imagefiles[index]),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        child: Center(
                                          child:   IconButton(onPressed: (){
                                            setState(() {
                                              imagefiles.removeAt(index);
                                            });
                                          }, icon: Icon(CupertinoIcons.delete, color: CupertinoColors.white,size: 30,)),
                                        ),
                                      );
                                    })),
                              ),
                            ),

                        ],
                      ),
                    ),
                  )
                ),
              if(checkdata == true && clickedcheckout==false)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      width: 135,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only( topRight: Radius.circular(0.0),
                            bottomRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(0.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [0.1, 0.3, 0.4, 0.8],
                          colors: [
                            Colors.red.withOpacity(0.2),
                            Colors.red.withOpacity(0.3),
                            Colors.red.withOpacity(0.3),
                            Colors.red.withOpacity(0.1),
                          ],
                        ),

                      ),
                      child: RaisedButton(
                        elevation: 0,
                        color: Colors.transparent,
                        onPressed: (){
                          setState(() {
                            clickedcheckout = true;
                           // enterremarks();
                          });
                        },
                        child: const Text('Check Out',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15
                          ),),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),

      ),
     // floatingActionButton: checkdata == 'true' ?:Container(),
    );
  }
}


