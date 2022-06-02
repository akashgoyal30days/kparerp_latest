import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'package:kparerp/api%20models/stock%20and%20price.dart';
import 'package:kparerp/constants/color%20const.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:launch_review/launch_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../main.dart';
import 'alert.dart';

class CurrentStock extends StatefulWidget {
  @override
  State<CurrentStock> createState() => _CurrentStockState();
}

class _CurrentStockState extends State<CurrentStock> {
  var currlist = [];
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
      getinternaldet(),
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


  Future getinternaldet() async{
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
          backgroundColor: Color(0xff212332),
          appBar: AppBar(
            backgroundColor: Color(0xff212332),
            title: Text('Current Stock'),
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
            child: ListView(
              children: [
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
                      scrollDirection: Axis.vertical,
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
                              children: const [
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
                                  TableCell(child: Center(
                                    child: Text('Current Balance',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15
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
                    height: MediaQuery.of(context).size.height-60,

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
                                    child: Text(currlist[index]['cur_bal'],
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
            ),
          )
      ),
    );
  }
}


