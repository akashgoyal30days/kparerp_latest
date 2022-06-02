import 'package:flutter/material.dart';
import 'package:kparerp/api%20models/loginscreen.dart';
import 'package:kparerp/constants/color%20const.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';
import 'package:kparerp/screen%20models/dashboard/onlyforpopup.dart';
import 'package:launch_review/launch_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

class Login extends StatefulWidget {
  const Login({required this.backscreen});
  final String backscreen;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String screen = 'login';

  dynamic emailController = TextEditingController();
  dynamic forgotemailController = TextEditingController();
  dynamic passwordController = TextEditingController();
  final _formnewkey = GlobalKey<FormState>();
  final _formnewkey1 = GlobalKey<FormState>();

  @override
  void initState(){
    if(widget.backscreen=="expsession"){
      forexp();
    }

  }
  void forexp() async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.remove('uid');
    preference.remove('token');
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
                              Text('Matching details, please wait!!',
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
        backgroundColor: Color(0xff212332),
      body:Container(
        child: screen == 'login'?Form(
          key: _formnewkey,
          child: ListView(
            children:[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only( topRight: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                      topLeft: Radius.circular(0.0),
                      bottomLeft: Radius.circular(10.0)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.1, 0.1, 0.9, 0.3],
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset('assets/kpar.png'),
                  ),
                ),
              ),
              SizedBox(height: 50,),
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding:const EdgeInsets.all(20.0),
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter email';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
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
                              labelText: 'Password',

                              labelStyle: TextStyle(fontSize: 18, color: Colors.grey,)),
                          controller: passwordController,
                          //initialValue: 'initial value',
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width/2.5,
                                child: TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      screen = 'fpass';
                                    });
                                  },
                                  child: Text('Forgot Password?', style: TextStyle(color: Colors.blue),),
                                )
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width/3,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if(_formnewkey.currentState!.validate()){
                                      showLoader();
                                      var email = emailController.text;
                                      var pass = passwordController.text;
                                      try{
                                        var rsp = await UserLogin(email, pass);
                                        debugPrint(rsp.toString());
                                        debugPrint(rsp.toString());
                                        if (rsp.containsKey('status')) {
                                          if(rsp['status'] == true){
                                            //startForegroundService();
                                            locatstream(rsp['token'].toString());
                                            SharedPreferences preference = await SharedPreferences.getInstance();
                                            preference.setString('token', rsp['token']);
                                            preference.setString('uid', rsp['uid']);
                                            Toast.show(rsp['message'],
                                                context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                            Navigator.popUntil(context, (_) => !Navigator.canPop(context));
                                            Navigator.pushReplacement(context,
                                                MaterialPageRoute(builder: (context) {
                                                  return Dashboard();
                                                }));
                                          }
                                          else{
                                            Navigator.pop(context);
                                            Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                          }
                                        }
                                        //debugPrint(rsp);
                                      }catch(error){
                                        Navigator.pop(context);
                                        debugPrint(error.toString());

                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text('Log In'),
                                      Icon(Icons.login, size: 18,)
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(), elevation: 0,primary: Colors.blue, ),
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                    if(widget.backscreen == 'expsession')
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('Your session expired!! Kindly relogin', style: TextStyle(color: Colors.white, fontSize: 20),textAlign: TextAlign.center,)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ):
        Form(
          key: _formnewkey1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const SizedBox(height: 80),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 0, 8),
                child: Text('Forgot ', style: TextStyle(color: Colors.white,
                    fontSize: 38),),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 0, 8),
                child: Text('Password , ', style: TextStyle(color: Colors.white,
                    fontSize: 38),),
              ),
              const SizedBox(height: 30,),
              Padding(
                padding:const EdgeInsets.all(20.0),
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
                    controller: forgotemailController,
                    //initialValue: 'initial value',
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                          height: 35,
                          //width: MediaQuery.of(context).size.width/2.5,
                          child: TextButton(
                            onPressed: () async {
                              setState(() {
                                screen = 'login';
                                forgotemailController.clear();
                              });
                            },
                            child: Text('Cancel', style: TextStyle(color: Colors.blue),),
                          )
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                          height: 35,
                          //width: MediaQuery.of(context).size.width/3,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(_formnewkey1.currentState!.validate()){
                                showLoader();
                                var email = forgotemailController.text;
                                try{
                                  var rsp = await Fpass(email);
                                  debugPrint(rsp.toString());
                                  // debugPrint(rsp.toString());
                                  if (rsp.containsKey('status')) {
                                    if(rsp['status'] == true){
                                      Navigator.pop(context);

                                     Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                     setState(() {
                                       screen = 'login';
                                       forgotemailController.clear();
                                     });
                                    }
                                    else{
                                      Navigator.pop(context);
                                      Toast.show(rsp['message'], context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 10);
                                    } if(rsp['stcode'] == 411){
                                      appupdate();
                                    }
                                  }
                                  //debugPrint(rsp);
                                }catch(error){
                                  Navigator.pop(context);
                                  debugPrint(error.toString());

                                }
                              }
                            },
                            child: Text('Request new password'),
                            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), elevation: 0,primary: Colors.blue, ),
                          )
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      )
    );
  }
}


