import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kparerp/constants/constants.dart';
import '../main.dart';



Future TurnDet(String uid, String token) async {
  var uri = internalpath;
  Map bodys = {
    'method' : 'comp_turn'
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
  //var convertedDatatoJson = response.body;
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}