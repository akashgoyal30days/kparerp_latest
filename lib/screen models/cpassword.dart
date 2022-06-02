import 'package:flutter/material.dart';
import 'package:kparerp/api%20models/changepass.dart';
import 'package:kparerp/api%20models/loginscreen.dart';
import 'package:kparerp/api%20models/logoutmodel.dart';
import 'package:kparerp/constants/color%20const.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:launch_review/launch_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import 'alert.dart';

class Cpwd extends StatefulWidget {
  @override
  State<Cpwd> createState() => _CpwdState();
}

class _CpwdState extends State<Cpwd> {
  dynamic oldpasswordController = TextEditingController();
  dynamic newpasswordController = TextEditingController();
  dynamic confpasswordController = TextEditingController();
  final _formnewkey = GlobalKey<FormState>();
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
    Senttoalert();
  }
  @override
  void initState(){
    getsaveddata();
    super.initState();
  }
  Future Senttoalert() async{
    if(locenable==false) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => Alert()));
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
                              Text('Changing password, please wait!!',
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff212332),
          title: Text('Change Password'),
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
        backgroundColor: Color(0xff212332),
        body:Container(
          child: Form(
            key: _formnewkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const SizedBox(height: 80),
                Padding(
                  padding:const EdgeInsets.all(20.0),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xff1c1c1c),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: TextFormField(
                      //initialValue: "I am smart",
                      autocorrect: true,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.go,
                      obscureText: true,

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
                          labelText: 'Old Password',

                          labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                      controller: oldpasswordController,
                      //initialValue: 'initial value',
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter old password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xff1c1c1c),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: TextFormField(
                      //initialValue: "I am smart",
                      autocorrect: true,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.go,
                      obscureText: true,

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
                          labelText: 'New Password',

                          labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                      controller: newpasswordController,
                      //initialValue: 'initial value',
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter old password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xff1c1c1c),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: TextFormField(
                      //initialValue: "I am smart",
                      autocorrect: true,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.go,
                      obscureText: true,

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
                          labelText: 'Confirm new password',

                          labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                      controller: confpasswordController,
                      //initialValue: 'initial value',
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please confirm new password';
                        }
                        return null;
                      },
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
                            if(_formnewkey.currentState!.validate()){
                              var old = oldpasswordController.text;
                              var newp = newpasswordController.text;
                              if (newpasswordController.text ==
                                  confpasswordController.text &&
                                  confpasswordController.text !=
                                      oldpasswordController.text &&
                                  oldpasswordController.text !=
                                      newpasswordController.text) {
                                try{
                                  showLoader();
                                  var rsp = await ChangePass(userid, token, old, newp);
                                  debugPrint(rsp.toString());
                                  debugPrint(rsp.toString());
                                  if (rsp.containsKey('status')) {
                                    if(rsp['status'] == true){
                                      logOut(context);
                                    }
                                    else{
                                      Navigator.pop(context);
                                      if(rsp['stcode'] == 411){
                                        appupdate();
                                      }
                                      if(rsp['stcode']== 412){
                                        expsession(context);
                                      }
                                      Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                    }
                                  }
                                  //debugPrint(rsp);
                                }catch(error){
                                  Navigator.pop(context);
                                  debugPrint(error.toString());
                                  Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);


                                }
                                // load();
                              }
                              else if (newpasswordController.text !=
                                  confpasswordController.text) {
                                Toast.show("Confirm Password And New Password Doesn't Matched", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                              }
                              else if (newpasswordController.text ==
                                  oldpasswordController.text) {
                                Toast.show("New Password And Current Password Should Not Be Same", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                              }
                              setState(() {});
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Submit'),
                              Icon(Icons.check, size: 18,)
                            ],
                          ),
                          style: ElevatedButton.styleFrom(shape: const StadiumBorder(), elevation: 0,primary: Colors.blue, ),
                        )
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        )
    );
  }
}


