
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kparerp/constants/constants.dart';

import '../main.dart';



Future UserLogin(String email, String pass) async {
  //debugPrint(email);
  var uri = "${base_url}/login.php";
  Map bodys = {
    'method' : 'login',
    'uname': email,
    'upass' : pass,
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'accept': 'application/json',
        'client-service': cservice.toString(),
        'auth-key': auth.toString(),
        'app_version': appversion.toString(),
        'content-type':'application/json',
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  //debugPrint(body);
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}

Future Fpass(String email) async {
  var uri = "${base_url}/login.php";
  Map bodys = {
    'method' : 'forgot_pass',
    'uname': email,
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'accept': 'application/json',
        'client-service': cservice.toString(),
        'auth-key': auth.toString(),
        'app_version': appversion.toString(),
        'content-type':'application/json',
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  //debugPrint(body);
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}