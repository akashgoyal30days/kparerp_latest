
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kparerp/constants/constants.dart';
import 'package:kparerp/screen%20models/dashboard/dash.dart';

import '../main.dart';



Future Docheckout(String uid, String token, String lat, String lng, String type, String cid, String remark, String amt, String doc, String oval) async {
  var uri = internalpath;
  Map bodys = {
    'method' : 'check_out',
    'cid': cid,
    'dlat': lat,
    'dlong': lng,
    'dtype': type,
    'amount_received': amt,
    'order_value': oval,
    'doc': doc,
    'remarks': remark
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