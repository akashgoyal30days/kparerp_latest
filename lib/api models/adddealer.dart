
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kparerp/constants/constants.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';

import '../main.dart';



Future AddDealer(String uid, String token, String name, String address, String mob, String email, String lat, String lng, String firm, String turnover, String comps, String img, String ctype) async {
  var uri = internalpath;
  Map bodys = {
    'method' : 'register_dealer',
    'name': name,
    'phone': mob,
    'email':email,
    'address': address,
    'lat': lat,
    'long': lng,
    'firm': firm,
    'turnover': turnover,
    'companies': comps,
    'form': img,
    'ctype': ctype
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'Accept': 'application/json',
        'client-service': cservice,
        'auth-key': auth,
        'app_version': appversion.toString(),
        'user': uid,
        'token': token
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}