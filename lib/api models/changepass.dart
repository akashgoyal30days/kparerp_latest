
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kparerp/constants/constants.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';

import '../main.dart';



Future ChangePass(String uid, String token,String old, String newpass) async {
  var uri = internalpath;
  Map bodys = {
    'method' : 'change_password',
    'cpass': old,
    'npass' : newpass,
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'Accept': 'application/json',
        'Client-Service': cservice,
        'Auth-Key': auth,
        'app_version': appversion.toString(),
        'user': uid,
        'token': token
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  //debugPrint(body);
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}