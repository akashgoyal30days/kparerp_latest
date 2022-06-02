import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'package:kparerp/api%20models/pricelist.dart';
import 'package:kparerp/api%20models/stock%20and%20price.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:launch_review/launch_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../main.dart';
import 'alert.dart';

class PriceList extends StatefulWidget {
  @override
  State<PriceList> createState() => _PriceListState();
}

class _PriceListState extends State<PriceList> {
  int initialval = 0;
  var currlist = [];
  List _foundlist = [];
  void _showPopupMenu() async {
    await showMenu(
      elevation : 0.0,
      context: context,
      position: RelativeRect.fromLTRB(600, 140, 0, 100),
      color: Colors.blue,
      items: [
        const PopupMenuItem(
          value: 1,
          child:Center(child: Text("SS Rate", style: TextStyle(color: Colors.white, fontSize: 15),)),
        ),
        const PopupMenuItem(
          value: 2,
          child:Center(child: Text("DLP Rate", style: TextStyle(color: Colors.white, fontSize: 15),)),
        ),
        const PopupMenuItem(
          value: 3,
          child:Center(child: Text("RDP Rate", style: TextStyle(color: Colors.white, fontSize: 15),)),
        ),
        const PopupMenuItem(
          value: 4,
          child:Center(child: Text("MRP", style: TextStyle(color: Colors.white, fontSize: 15),)),
        ),


      ],
    ).then((value){
      setState(() {
        initialval = value!;
        debugPrint(initialval.toString());
      });
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
    getsaveddata().then((value) =>[
      showLoader(),
      alllist(),
      Senttoalert()
    ]

    );
    super.initState();
  }

  Future Senttoalert() async{
    if(locenable==false) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Alert()));
    }
  }

  String mydata = '';
  Future alllist() async{
    try{
      var rsp = await GetStock(userid, token);
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
            currlist = rsp['data'];
            _foundlist = currlist;
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




  Future sharepdf() async{
    var sharePdf = await File('${appDocDir.path}/KPar Erp/pricelist/$mydate.pdf').readAsBytes();
    await Share.file(
      'PDF Document',
      '$mydate.pdf',
      sharePdf.buffer.asUint8List(),
      '*/*',
    );
  }
  Future plist() async{
    try{
      var rsp = await Plist(userid, token);
      debugPrint(rsp.toString());

      if (rsp.containsKey('status')){
        Navigator.pop(context);
        if(rsp['stcode']== 412){
          expsession(context);
        }
        if(rsp['status']!= true){
          Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        }
        if(rsp['status']== true){
         setState(() {
           mydata = rsp['data'];
         });
         generateDocument().then((value) => [
           Sharep(),
         ]);
                 }
      }
    }catch(error){
      Navigator.pop(context);
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }

  }
  String userid = '';
  String token = '';
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
      final Directory _appDocDirFolder = Directory('${dir!.path}/KPar Erp/pricelist');
      if(await _appDocDirFolder.exists()){
        debugPrint('exists');
        appDocDir = (await _getDownloadDirectory())!;
        var targetPath = '${appDocDir.path}/KPar Erp/pricelist';
        var targetFileName = mydate.toString();
        final dir = await getExternalStorageDirectory();

        debugPrint("Directoryyyyyyyyy:${appDocDir.path}");

        final String path = "${dir!.path}/example.pdf";
        final file = File(path);
        var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
            mydata, targetPath, targetFileName);
        generatedPdfFilePath = generatedPdfFile.path;
        Toast.show('Pdf Saved At \n ${appDocDir.path}/KPar Erp/pricelist', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
        return _appDocDirFolder.path;
      }else{
        final Directory _appDocNewFolder = await _appDocDirFolder.create(recursive: true);
        appDocDir = (await _getDownloadDirectory())!;
        var targetPath = '${appDocDir.path}/KPar Erp/pricelist';
        var targetFileName = mydate.toString();
        final dir = await getExternalStorageDirectory();
        debugPrint("Directoryyyyyyyyy:${appDocDir.path}");
        final String path = "${dir!.path}/example.pdf";
        final file = File(path);
        var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
            mydata, targetPath, targetFileName);
        generatedPdfFilePath = generatedPdfFile.path;
        Toast.show('Pdf Saved At \n ${appDocDir.path}/KPar Erp/pricelist', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
      }
    }else{
      Toast.show('KPar Erp has not the permission to save a file in your device, please provide permission', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
    }
  }
  late Directory appDocDir;



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
  void downloadingpdf(){
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
                              Text('Downloading Pdf, please wait!!',
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
  void Sharep(){
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
                        height: 150,
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child:Text('Your price list is downloaded at ${appDocDir.path}/KPar Erp/pricelist/$mydate.pdf',
                                    style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    onPressed:() {
                                      Navigator.pop(context);
                                      sharepdf();
                                    },
                                    child: const Text('Share', style: TextStyle(color: Colors.blue),) ,
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
        if(item['cat_name'].toString().toLowerCase().contains(query.toLowerCase())) {
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
          element[i]['cat_name'] == items[i]['cat_name']);
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
            title: Text('Price List'),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                        return Dashboard();
                      }));
                }
            ),
            actions: [
              if(currlist.isNotEmpty)
              IconButton(onPressed: (){
                downloadingpdf();
                plist();
              },
              icon: Icon(Icons.download))
            ],
          ),
          body:Container(
            child:  ListView(
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
                          hintText: "Search using category name",
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
                Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only( topRight: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(0.0),
                          bottomLeft: Radius.circular(0.0)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 0.3, 0.4, 0.8],
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.blue.withOpacity(0.5),
                          Colors.blue.withOpacity(0.5),
                          Colors.blue.withOpacity(0.5),
                        ],
                      ),

                    ),
                    height: 40,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                              columnWidths: {
                                0: FlexColumnWidth(1.2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(0.5),
                                3: FlexColumnWidth(1.9),
                              },
                              children:[
                                TableRow(children: [
                                  TableCell(child: Text('Sl. No.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),)),
                                  TableCell(child: Text('Category Name',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),)),
                                  TableCell(child: Text('',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),)),
                                  TableCell(child: Center(
                                    child: Text('Name',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15
                                      ),),
                                  )),
                                  TableCell(child: Text('',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),)),
                                  TableCell(child: GestureDetector(
                                    onTap: (){
                                      _showPopupMenu();
                                    },
                                    child: Center(
                                      child: Row(
                                        children: [
                                         if(initialval == 0)
                                           Text('MRP',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15
                                            ),),
                                          if(initialval == 1)
                                            Text('SS',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15
                                              ),),
                                          if(initialval == 2)
                                            Text('DLP',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15
                                              ),),
                                          if(initialval == 3)
                                            Text('RDP',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15
                                              ),),
                                          if(initialval == 4)
                                            Text('MRP',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15
                                              ),),
                                          Icon(Icons.arrow_drop_down_circle_outlined, size: 15,
                                          color: Colors.white,)
                                        ],
                                      ),
                                    ),
                                  )),
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if(items.isEmpty&&isempfound == true)
                Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only( topRight: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(0.0),
                          bottomLeft: Radius.circular(0.0)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 0.3, 0.4, 0.8],
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.2),
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.0),
                        ],
                      ),

                    ),
                    height: MediaQuery.of(context).size.height-230,

                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: currlist.isEmpty?0:currlist.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                              columnWidths: {
                                0: FlexColumnWidth(1.2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(0.5),
                                3: FlexColumnWidth(1.9),
                              },
                              children:[
                                TableRow(children: [
                                  TableCell(child: Text('${index+1}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),)),
                                  TableCell(child: Text(currlist[index]['cat_name'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),)),
                                  TableCell(child: Text('',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),)),
                                  TableCell(child: Center(
                                    child: Text(currlist[index]['name'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13
                                      ),),
                                  )),
                                  TableCell(child: Text('',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),)),
                                  TableCell(child: Center(
                                    child: initialval == 0?
                                    Text(currlist[index]['rate'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),): initialval == 1?
                                    Text(currlist[index]['ss_rate'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),):
                                    initialval == 2?
                                    Text(currlist[index]['dlp_rate'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),) :initialval == 3?
                                    Text(currlist[index]['rdp_rate'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),): initialval == 4?
                                    Text(currlist[index]['rate'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),):
                                    Text(currlist[index]['rate'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),),
                                  )),
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if(items.isNotEmpty&&isempfound == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only( topRight: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(0.0),
                            bottomLeft: Radius.circular(0.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.1, 0.3, 0.4, 0.8],
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.2),
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.0),
                          ],
                        ),

                      ),
                      height: MediaQuery.of(context).size.height-230,

                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: items.isEmpty?0:items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child:  Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Table(
                                columnWidths: {
                                  0: FlexColumnWidth(1.2),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(0.5),
                                  3: FlexColumnWidth(1.9),
                                },
                                children:[
                                  TableRow(children: [
                                    TableCell(child: Text('${index+1}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14
                                      ),)),
                                    TableCell(child: Text(items[index]['cat_name'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14
                                      ),)),
                                    TableCell(child: Text('',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15
                                      ),)),
                                    TableCell(child: Center(
                                      child: Text(items[index]['name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13
                                        ),),
                                    )),
                                    TableCell(child: Text('',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15
                                      ),)),
                                    TableCell(child: Center(
                                      child: initialval == 0?
                                      Text(items[index]['rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),): initialval == 1?
                                      Text(items[index]['ss_rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),):
                                      initialval == 2?
                                      Text(items[index]['dlp_rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),) :initialval == 3?
                                      Text(items[index]['rdp_rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),): initialval == 4?
                                      Text(items[index]['rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),):
                                      Text(items[index]['rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),),
                                    )),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if(items.isEmpty&&isempfound == false)
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only( topRight: Radius.circular(0.0),
                              bottomRight: Radius.circular(0.0),
                              topLeft: Radius.circular(0.0),
                              bottomLeft: Radius.circular(0.0)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.1, 0.3, 0.4, 0.8],
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.2),
                              Colors.blue.withOpacity(0.3),
                              Colors.blue.withOpacity(0.0),
                            ],
                          ),

                        ),
                        height: MediaQuery.of(context).size.height-230,
                        child: Center(
                          child: Text('Not available with this category name',
                            style: TextStyle(
                                fontSize: 20, color: Colors.white
                            ),),
                        )
                    ),
                  ),
                if(items.isNotEmpty&&isempfound == false)
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only( topRight: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(0.0),
                            bottomLeft: Radius.circular(0.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.1, 0.3, 0.4, 0.8],
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.2),
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.0),
                          ],
                        ),

                      ),
                      height: MediaQuery.of(context).size.height-230,

                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: items.isEmpty?0:items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child:  Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Table(
                                columnWidths: {
                                  0: FlexColumnWidth(1.2),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(0.5),
                                  3: FlexColumnWidth(1.9),
                                },
                                children:[
                                  TableRow(children: [
                                    TableCell(child: Text('${index+1}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14
                                      ),)),
                                    TableCell(child: Text(items[index]['cat_name'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14
                                      ),)),
                                    TableCell(child: Text('',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15
                                      ),)),
                                    TableCell(child: Center(
                                      child: Text(items[index]['name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13
                                        ),),
                                    )),
                                    TableCell(child: Text('',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15
                                      ),)),
                                    TableCell(child: Center(
                                      child: initialval == 0?
                                      Text(items[index]['rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),): initialval == 1?
                                      Text(items[index]['ss_rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),):
                                      initialval == 2?
                                      Text(items[index]['dlp_rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),) :initialval == 3?
                                      Text(items[index]['rdp_rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),): initialval == 4?
                                      Text(items[index]['rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),):
                                      Text(items[index]['rate'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),),
                                    )),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            )
          )
      ),
    );
  }
}


