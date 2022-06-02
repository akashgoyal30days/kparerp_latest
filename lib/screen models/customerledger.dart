import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
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
class CustomerLedger extends StatefulWidget {
  @override
  State<CustomerLedger> createState() => _CustomerLedgerState();
}

class _CustomerLedgerState extends State<CustomerLedger> {
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
  String? _mycreditproduct;
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
  @override
  void initState(){
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
  Future Senttoalert() async{
    if(locenable==false) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Alert()));
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
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
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
            title: isdateopen == false?Text('Customer Ledger'):ishtmloaded==false?Text('Select Date', style: TextStyle(color: Colors.black)):Text('Ledger', style: TextStyle(color: Colors.black),),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                  color: isdateopen == false?Colors.white:Colors.black,),
                onPressed: () {
                  if (ishtmloaded == false) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                          return Dashboard();
                        }));
                  }
                  else {
                      setState(() {
                        isdateopen = false;
                        todate = '';
                        fromdate = '';
                        ishtmloaded = false;
                        cid = '';
                        _mycreditproduct = null;
                        isshareenabled = false;
                      });
                    }
                }
            ),
          ),
          body:ishtmloaded == false?
          Column(
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                    padding:
                    EdgeInsets.only(left: 15, right: 15, top: 0),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          dropdownColor: Color(0xFF2A2D3E),
                          elevation: 0,
                          value: _mycreditproduct,
                          iconSize: 30,
                          icon: Icon(Icons.arrow_drop_down,color: Colors.blue,),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          hint: Text('Select Dealer',style: TextStyle(color: Colors.grey),),
                          onChanged: (String? value) {
                            setState(() {
                              _mycreditproduct = null;
                              _mycreditproduct = value;
                              cid = _mycreditproduct.toString();
                              ishtmloaded = false;
                                debugPrint(_mycreditproduct);
                            });

                          },
                          items: currlist?.map((itemn) {
                            return DropdownMenuItem(
                              child: Text(itemn['name'],style: TextStyle(color: Colors.grey),),
                              value: itemn['cid'].toString(),
                            );
                          })?.toList() ??
                              [],
                        ),
                      ),
                    ),
                  ),),
              ),
              Container(
                height: MediaQuery.of(context).size.height/2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SfDateRangePicker(
                    showNavigationArrow: true,
                    toggleDaySelection: true,
                    initialSelectedDate: DateTime.now(),
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    initialDisplayDate: DateTime.now(),
                    allowViewNavigation: false,
                    minDate: DateTime.parse('2020-01-01'),
                    navigationDirection : DateRangePickerNavigationDirection.horizontal,
                    backgroundColor: Colors.white,
                    confirmText: 'SUBMIT',
                    cancelText: 'CANCEL',
                    selectionColor:Color(0xff212332),
                    startRangeSelectionColor: Color(0xff212332),
                    endRangeSelectionColor: Color(0xff212332),
                    rangeSelectionColor: Color(0xff212332).withOpacity(0.2),
                    selectionMode :DateRangePickerSelectionMode.extendableRange,
                    enablePastDates: true,
                    showActionButtons: true,
                    onCancel: (){
                      setState(() {
                        todate = '';
                        fromdate = '';
                        _mycreditproduct = null;
                        cid = '';
                      });
                    },
                    onSubmit: (v){
                      //debugPrint(v.toString());
                      if(cid != '') {
                        viewledger();
                      }else{
                        Toast.show('Please select dealer', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                      }
                    },
                    maxDate: DateTime.now(),
                    onSelectionChanged: _onSelectionChanged,
                    //selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                        DateTime.now().subtract(const Duration(days: 0)),
                        DateTime.now().add(const Duration(days: 0))),
                  ),
                ),
              ),
            ],
          ):Container(
            color: Colors.white,
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
          ),
      ),
    );
  }
}


