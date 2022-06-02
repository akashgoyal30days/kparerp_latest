
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kparerp/constants/constants.dart';

import '../main.dart';



Future LogOutServer(String uid, String token) async {
  var uri = internalpath;
  Map bodys = {
    'method' : 'logout'
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
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}