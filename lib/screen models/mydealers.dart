import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kparerp/api%20models/docheckin.dart';
import 'package:kparerp/api%20models/getmydealerslist.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'package:kparerp/api%20models/stock%20and%20price.dart';
import 'package:kparerp/constants/color%20const.dart';
import 'package:launch_review/launch_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/foundation.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

import '../api models/viewledger.dart';
import '../main.dart';
import 'alert.dart';
class MyDealers extends StatefulWidget {
  MyDealers({required this.chck});
  bool chck;
  @override
  State<MyDealers> createState() => _MyDealersState();
}
const htmlData = r"""
<h3 style="text-align:center">SAROJINI LED LIGHTS PVT LTD</h3><h5 style="text-align:center">Ledger Summary: From:- 2021-09-02 To:- 2021-09-04</h5><table cellspacing="0" border="1" cellpadding="5" style="font-size:10px;"> <tr><td><b>Date</b></td><td><b>Voucher</b></td><td><b>Description</b></td><td><b>Remarks</b></td><td><b>Debit</b></td><td><b>Credit</b></td><td><b>Balance</b></td></tr><tr><td></td><td></td><td>Balance b/f</td><td></td><td>136.00</td><td></td><td>136.00 Dr.</td></tr><tr><td>03-09-2021</td><td>Sales</td><td>On Account of Bill No. KP/21-22/001</td><td></td><td>1285.00</td><td></td><td>1421.00 Dr.</td></tr><tr><td></td><td></td><td></td><td></td><td>1421.00</td><td>0.00</td><td></td></tr></table>
""";
class _MyDealersState extends State<MyDealers> {
  var currlist = [];
  String fromdate = '';
  String todate = '';
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  String cid = '';
  bool ishtmloaded = false;
  String mydata = '';
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
                              Text('Checking you in, please wait!!',
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


  late String generatedPdfFilePath;
  late String mydate;

  Future<Directory?> downloadsDirectory = DownloadsPathProvider.downloadsDirectory;
  Future<bool> _requestPermissions() async{
    var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    if(permission != PermissionStatus.granted){
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }
  Future<Directory?> _getDownloadDirectory() async{
    if(Platform.isAndroid){
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }
  bool isshareenabled = false;
  Future generateDocument() async {
    setState((){
      mydate = DateTime.now().toString().replaceAll(" ", "");
      mydate = mydate.replaceAll("-", "");
      mydate= mydate.replaceAll(":", "");
      mydate=mydate.replaceAll(".", "");
    });
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if(isPermissionStatusGranted){
      final Directory _appDocDirFolder = Directory('${dir!.path}/KPar Erp/outstanding');
      if(await _appDocDirFolder.exists()){
        debugPrint('exists');
        appDocDir = (await _getDownloadDirectory())!;
        var targetPath = '${appDocDir.path}/KPar Erp/outstanding';
        var targetFileName = mydate.toString();
        final dir = await getExternalStorageDirectory();

        debugPrint("Directoryyyyyyyyy:${appDocDir.path}");

        final String path = "${dir!.path}/example.pdf";
        final file = File(path);
        var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
            mydata, targetPath, targetFileName);
        generatedPdfFilePath = generatedPdfFile.path;
        Toast.show('Pdf Saved At \n ${appDocDir.path}/KPar Erp/outstanding', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        return _appDocDirFolder.path;
      }else{
        final Directory _appDocNewFolder = await _appDocDirFolder.create(recursive: true);
        appDocDir = (await _getDownloadDirectory())!;
        var targetPath = '${appDocDir.path}/KPar Erp/outstanding';
        var targetFileName = mydate.toString();
        final dir = await getExternalStorageDirectory();
        debugPrint("Directoryyyyyyyyy:${appDocDir.path}");
        final String path = "${dir!.path}/example.pdf";
        final file = File(path);
        var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
            mydata, targetPath, targetFileName);
        generatedPdfFilePath = generatedPdfFile.path;
        Toast.show('Pdf Saved At \n ${appDocDir.path}/KPar Erp/outstanding', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
      }
    }else{
      Toast.show('KPar Erp has not the permission to save a file in your device, please provide permission', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }
  }
  late Directory appDocDir;

  //Checking if your App has been Given Permission/
  Future<bool> requestLocationPermission({Function? onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }
  var items = [];
  var indexpostion = [];
  bool isempfound = true;
  TextEditingController editingController = TextEditingController();
  void filterSearchResults(String query) {
    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(currlist);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['name'].toString().toLowerCase().contains(query.toLowerCase())) {
          setState(() {
            dummyListData.add(item);
            isempfound = true;
          });
        }else{
          setState((){
            isempfound = false;
          });
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
        indexpostion.clear();
        for(var i=0; i<items.length; i++){
          final index = dummySearchList.indexWhere((element) =>
          element[i]['name'] == items[i]['name']);
          indexpostion.add(index);
        }
        debugPrint(indexpostion.toString());
      });
      items.clear();
      for(var i=0; i<indexpostion.length; i++){
        items.add(currlist[int.parse(indexpostion[i].toString())]);
        debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isempfound = true;
        items.clear();
        items.addAll(currlist);

      });
    }
  }

  Future Checkin(String cid) async{
    try{
      var rsp = await Docheckin(userid, token, mlat.toString(), mlng.toString(), 'o', cid);
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')){
        Navigator.pop(context);
        if(rsp['status'] == true){
          setState(() {
            setState(() {
              // currlist = rsp['data'];
              Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);

              widget.chck = true;
            });
          });
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


  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range =
            DateFormat('dd-MM-yyyy').format(args.value.startDate).toString() +
                ' - ' +
                DateFormat('dd-MM-yyyy')
                    .format(args.value.endDate ?? args.value.startDate)
                    .toString();
        debugPrint('d - ${_range.toString()}');
        setState(() {
          fromdate = '${_range[0].toString()}${_range[1].toString()}${_range[2].toString()}${_range[3].toString()}${_range[4].toString()}'
              '${_range[5].toString()}${_range[6].toString()}${_range[7].toString()}${_range[8].toString()}${_range[9].toString()}';

          todate = '${_range[13].toString()}${_range[14].toString()}${_range[15].toString()}${_range[16].toString()}${_range[17].toString()}'
              '${_range[18].toString()}${_range[19].toString()}${_range[20].toString()}${_range[21].toString()}${_range[22].toString()}';
        });

       /* debugPrint('1 - ${_range[0].toString()}${_range[1].toString()}${_range[2].toString()}${_range[3].toString()}${_range[4].toString()}'
            '${_range[5].toString()}${_range[6].toString()}${_range[7].toString()}${_range[8].toString()}${_range[9].toString()}');
        debugPrint('2 - ${_range[13].toString()}${_range[14].toString()}${_range[15].toString()}${_range[16].toString()}${_range[17].toString()}'
            '${_range[18].toString()}${_range[19].toString()}${_range[20].toString()}${_range[21].toString()}${_range[22].toString()}');*/
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
        debugPrint('a - ${_selectedDate.toString()}');
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
        debugPrint('b - ${_dateCount.toString()}');
      } else {
        _rangeCount = args.value.length.toString();
        debugPrint('c - ${_rangeCount.toString()}');
      }
    });
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
  @override
  void initState(){
    requestLocationPermission();
    getsaveddata().then((value) =>[

      showLoader(),
      getdealers(),
      Senttoalert(),
    ]

    );
    setState(() {
      fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
      todate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
      debugPrint(fromdate.toString());
    });
    super.initState();
  }
  Future Senttoalert() async{
    if(locenable==false) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Alert()));
    }
  }


  Future getdealers() async{
    try{
      var rsp = await DealerList(userid, token);
      debugPrint(rsp.toString());

      if (rsp.containsKey('status')){
        Navigator.pop(context);
        if(rsp['stcode']==411){
          appupdate();
        }
        if(rsp['stcode']== 412){
          expsession(context);
        }
        if(rsp['status'] == true){
          setState(() {
            currlist = rsp['data'];
          });
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

  Future viewledger() async{
    try{
      var rsp = await   ViewLedger(userid, token, cid,  fromdate, todate);
      debugPrint(rsp.toString());

      if (rsp.containsKey('status')){
       // Navigator.pop(context);
        if(rsp['stcode']== 412){
          expsession(context);
        }
        if(rsp['status'] == true){
          setState(() {
            //currlist = rsp['data'];
            mydata = rsp['data'];
            ishtmloaded = true;
           // Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);

          });
        }
        if(rsp['status']!= true){
         // Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
      }
    }catch(error){
     // Navigator.pop(context);
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }

  }

  String userid = '';
  String token = '';
  bool isdateopen = false;
  Future getsaveddata() async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userid = preference.getString('uid')!;
      token = preference.getString('token')!;
    });
    //debugPrint(token);
    //debugPrint(userid);
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
          backgroundColor: isdateopen == false?Color(0xff212332):Colors.white,
          appBar: AppBar(
            backgroundColor: isdateopen == false?Color(0xff212332):Colors.white,
            elevation: isdateopen == false?5:0,
            title: isdateopen == false?Text('Dealers'):ishtmloaded==false?Text('Select Date', style: TextStyle(color: Colors.black)):Text('Ledger', style: TextStyle(color: Colors.black),),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                color: isdateopen == false?Colors.white:Colors.black,),
                onPressed: () {
                  if (isdateopen == false) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                          return Dashboard();
                        }));
                  }
                  else {
                    if (ishtmloaded == false) {
                      setState(() {
                        isdateopen = false;
                        todate = '';
                        fromdate = '';
                      });
                    }
                    if (ishtmloaded == true) {
                      setState(() {
                        isdateopen = false;
                        todate = '';
                        fromdate = '';
                        ishtmloaded = false;
                      });
                    }
                  }
                }
            ),
          ),
          body:isdateopen == false?Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                if(currlist.isNotEmpty)
                  Container(
                    color: Colors.black,
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: editingController,
                        onChanged: (v){
                          filterSearchResults(v.toString());
                        },
                        decoration: InputDecoration(
                            labelText: "Search",
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: "Search using name",
                            hintStyle: TextStyle(color: Colors.white),
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue, width: 1.0),
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.white,),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if(items.isEmpty&&isempfound == true)
                Container(
                  height: MediaQuery.of(context).size.height-155,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: currlist.isEmpty?0:currlist.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child:  Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
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
                                  Colors.blue.withOpacity(0.2),
                                  Colors.blue.withOpacity(0.3),
                                  Colors.blue.withOpacity(0.3),
                                  Colors.blue.withOpacity(0.0),
                                ],
                              ),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('NAME :', style: TextStyle(color: Colors.white),),
                                      SizedBox(width: 10,),
                                      Text(currlist[index]['name'], style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Text('ADDRESS :', style: TextStyle(color: Colors.white),),
                                      SizedBox(width: 10,),
                                      Expanded(child: Text(currlist[index]['address'], style: TextStyle(color: Colors.white),)),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('CONTACT NO. :', style: TextStyle(color: Colors.white),),
                                          SizedBox(width: 10,),
                                          Text(currlist[index]['phone'], style: TextStyle(color: Colors.white),),
                                        ],
                                      ),

                                      if(widget.chck == false)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: 25,
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
                                                  Colors.green.withOpacity(0.2),
                                                  Colors.green.withOpacity(0.3),
                                                  Colors.green.withOpacity(0.3),
                                                  Colors.green.withOpacity(0.1),
                                                ],
                                              ),

                                            ),
                                            child: RaisedButton(
                                              elevation: 0,
                                              color: Colors.transparent,
                                              onPressed: (){
                                                setState(() {
                                                  setState(() {
                                                    _getLocation().then((value) =>
                                                    [
                                                    if(lat != null && lng != null){
                                                      chcloader(),
                                                      Checkin(
                                                          currlist[index]['cid'])
                                                    }
                                                    ]);
                                                  });
                                                });
                                              },
                                              child: const Text('Check In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15
                                                ),),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Text('EMAIL ID :', style: TextStyle(color: Colors.white),),
                                      SizedBox(width: 10,),
                                      Text(currlist[index]['email'], style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('OUTSTANDING :', style: TextStyle(color: Colors.white),),
                                          SizedBox(width: 10,),
                                          Text(currlist[index]['cur_bal'], style: TextStyle(color: Colors.white),),
                                        ],
                                      ),
                                      Container(
                                        height: 25,
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
                                              Colors.blue.withOpacity(0.2),
                                              Colors.blue.withOpacity(0.3),
                                              Colors.blue.withOpacity(0.3),
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          ),

                                        ),
                                        child: RaisedButton(
                                          elevation: 0,
                                          color: Colors.transparent,
                                          onPressed: (){
                                            setState(() {
                                              isdateopen = true;
                                              cid = currlist[index]['cid'].toString();
                                              fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
                                              todate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
                                              debugPrint(fromdate.toString());
                                            });
                                          },
                                          child: const Text('View Ledger',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 15
                                          ),),
                                        ),
                                      )
                                    ],
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if(items.isNotEmpty&&isempfound == true)
                  Container(
                    height: MediaQuery.of(context).size.height-155,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: items.isEmpty?0:items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child:  Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
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
                                    Colors.blue.withOpacity(0.2),
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.0),
                                  ],
                                ),

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('NAME :', style: TextStyle(color: Colors.white),),
                                        SizedBox(width: 10,),
                                        Text(items[index]['name'], style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text('ADDRESS :', style: TextStyle(color: Colors.white),),
                                        SizedBox(width: 10,),
                                        Expanded(child: Text(currlist[index]['address'], style: TextStyle(color: Colors.white),)),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('CONTACT NO. :', style: TextStyle(color: Colors.white),),
                                            SizedBox(width: 10,),
                                            Text(items[index]['phone'], style: TextStyle(color: Colors.white),),
                                          ],
                                        ),

                                        if(widget.chck == false)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                height: 25,
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
                                                      Colors.green.withOpacity(0.2),
                                                      Colors.green.withOpacity(0.3),
                                                      Colors.green.withOpacity(0.3),
                                                      Colors.green.withOpacity(0.1),
                                                    ],
                                                  ),

                                                ),
                                                child: RaisedButton(
                                                  elevation: 0,
                                                  color: Colors.transparent,
                                                  onPressed: (){
                                                    setState(() {
                                                      setState(() {
                                                        _getLocation().then((value) =>
                                                        [
                                                          if(lat != null && lng != null){
                                                            chcloader(),
                                                            Checkin(items[index]['cid'])
                                                          }
                                                        ]);
                                                      });
                                                    });
                                                  },
                                                  child: const Text('Check In',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15
                                                    ),),
                                                ),
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text('EMAIL ID :', style: TextStyle(color: Colors.white),),
                                        SizedBox(width: 10,),
                                        Text(items[index]['email'], style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('OUTSTANDING :', style: TextStyle(color: Colors.white),),
                                            SizedBox(width: 10,),
                                            Text(items[index]['cur_bal'], style: TextStyle(color: Colors.white),),
                                          ],
                                        ),
                                        Container(
                                          height: 25,
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
                                                Colors.blue.withOpacity(0.2),
                                                Colors.blue.withOpacity(0.3),
                                                Colors.blue.withOpacity(0.3),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                            ),

                                          ),
                                          child: RaisedButton(
                                            elevation: 0,
                                            color: Colors.transparent,
                                            onPressed: (){
                                              setState(() {
                                                isdateopen = true;
                                                cid = items[index]['cid'].toString();
                                                fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
                                                todate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
                                                debugPrint(fromdate.toString());
                                              });
                                            },
                                            child: const Text('View Ledger',
                                              style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 15
                                              ),),
                                          ),
                                        )
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if(items.isEmpty&&isempfound == false)
                  Container(
                      height: MediaQuery.of(context).size.height-155,
                      child: Center(
                        child: Text('No dealers found',
                          style: TextStyle(
                              fontSize: 20, color: Colors.white
                          ),),
                      )
                  ),
                if(items.isNotEmpty&&isempfound == false)
                  Container(
                    height: MediaQuery.of(context).size.height-155,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: items.isEmpty?0:items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child:  Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
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
                                    Colors.blue.withOpacity(0.2),
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.0),
                                  ],
                                ),

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('NAME :', style: TextStyle(color: Colors.white),),
                                        SizedBox(width: 10,),
                                        Text(items[index]['name'], style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text('ADDRESS :', style: TextStyle(color: Colors.white),),
                                        SizedBox(width: 10,),
                                        Expanded(child: Text(currlist[index]['address'], style: TextStyle(color: Colors.white),)),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('CONTACT NO. :', style: TextStyle(color: Colors.white),),
                                            SizedBox(width: 10,),
                                            Text(items[index]['phone'], style: TextStyle(color: Colors.white),),
                                          ],
                                        ),

                                        if(widget.chck == false)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                height: 25,
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
                                                      Colors.green.withOpacity(0.2),
                                                      Colors.green.withOpacity(0.3),
                                                      Colors.green.withOpacity(0.3),
                                                      Colors.green.withOpacity(0.1),
                                                    ],
                                                  ),

                                                ),
                                                child: RaisedButton(
                                                  elevation: 0,
                                                  color: Colors.transparent,
                                                  onPressed: (){
                                                    setState(() {
                                                      setState(() {
                                                        _getLocation().then((value) =>
                                                        [
                                                          if(lat != null && lng != null){
                                                            chcloader(),
                                                            Checkin(items[index]['cid'])
                                                          }
                                                        ]);
                                                      });
                                                    });
                                                  },
                                                  child: const Text('Check In',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15
                                                    ),),
                                                ),
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text('EMAIL ID :', style: TextStyle(color: Colors.white),),
                                        SizedBox(width: 10,),
                                        Text(items[index]['email'], style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('OUTSTANDING :', style: TextStyle(color: Colors.white),),
                                            SizedBox(width: 10,),
                                            Text(items[index]['cur_bal'], style: TextStyle(color: Colors.white),),
                                          ],
                                        ),
                                        Container(
                                          height: 25,
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
                                                Colors.blue.withOpacity(0.2),
                                                Colors.blue.withOpacity(0.3),
                                                Colors.blue.withOpacity(0.3),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                            ),

                                          ),
                                          child: RaisedButton(
                                            elevation: 0,
                                            color: Colors.transparent,
                                            onPressed: (){
                                              setState(() {
                                                isdateopen = true;
                                                cid = items[index]['cid'].toString();
                                                fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
                                                todate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
                                                debugPrint(fromdate.toString());
                                              });
                                            },
                                            child: const Text('View Ledger',
                                              style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 15
                                              ),),
                                          ),
                                        )
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ):
          ishtmloaded ==false?SfDateRangePicker(
            showNavigationArrow: true,
              toggleDaySelection: true,
            initialSelectedDate: DateTime.now(),
            navigationMode: DateRangePickerNavigationMode.scroll,
            initialDisplayDate: DateTime.now(),
            allowViewNavigation: false,
            minDate: DateTime.parse('2020-01-01'),
            navigationDirection : DateRangePickerNavigationDirection.horizontal,
            //backgroundColor: Color(0xff212332),
            confirmText: 'SUBMIT',
            selectionColor:Color(0xff212332),
            startRangeSelectionColor: Color(0xff212332),
            endRangeSelectionColor: Color(0xff212332),
            rangeSelectionColor: Color(0xff212332).withOpacity(0.2),
            selectionMode :DateRangePickerSelectionMode.extendableRange,
            enablePastDates: true,
            showActionButtons: true,
            onCancel: (){
              setState(() {
                isdateopen = false;
                todate = '';
                fromdate = '';
              });
            },
            onSubmit: (v){
              //debugPrint(v.toString());
              if(todate != '' && fromdate != '') {
                viewledger();
              }else{
                Toast.show('Please select the from and to date', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
              }
            },
            maxDate: DateTime.now(),
            onSelectionChanged: _onSelectionChanged,
            //selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange: PickerDateRange(
                DateTime.now().subtract(const Duration(days: 0)),
                DateTime.now().add(const Duration(days: 0))),
          ):Container(
           child: Column(
             children: [
               Expanded(
                 child: Html(
                   data: mydata,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     Container(
                       height: 30,
                       width: MediaQuery.of(context).size.width/2.5,
                       child: RaisedButton(
                         color: Colors.blue,
                         onPressed: (){
                           generateDocument().then((value) => [
                             setState((){
                               isshareenabled = true;
                             })
                           ]);

                         },
                         child: Text('Generate Pdf', style: TextStyle(color:Colors.white),),
                       ),
                     ),
                     Container(
                       height: 30,
                       width: MediaQuery.of(context).size.width/2.5,
                       child: RaisedButton(
                         color: Colors.green,
                         onPressed: isshareenabled == true?() async {
                           debugPrint(appDocDir.path);
                           var sharePdf = await File('${appDocDir.path}/KPar Erp/outstanding/$mydate.pdf').readAsBytes();
                           await Share.file(
                             'PDF Document',
                             '$mydate.pdf',
                             sharePdf.buffer.asUint8List(),
                             '*/*',
                           );
                         }:null,
                         child: Text('Share', style: TextStyle(color:Colors.white),),
                       ),
                     ),
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


