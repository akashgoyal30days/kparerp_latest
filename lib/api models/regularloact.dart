
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kparerp/constants/constants.dart';

import '../main.dart';



Future Regularlocat(String appv, String uid, String token, String lat, String lng) async {
  var uri = internalpath;
  Map bodys = {
    'method' : 'regular_location',
    'dlat': lat,
    'dlong': lng
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'Accept': 'application/json',
        'Client-Service': cservice,
        'Auth-Key': auth,
        'app_version': appv.toString(),
        'user': uid,
        'token': token
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}