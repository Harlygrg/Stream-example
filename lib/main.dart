import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:stream_example/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  final StreamController<UserModel> _streamController = StreamController();


  @override
  void dispose() {
    _streamController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 2), (timer) {
      getCryptoPrice();
    });
  }

  Future<void> getCryptoPrice()async{

    final response = await http.get(Uri.parse("https://api.nomics.com/v1/currencies/ticker?key=e11d2be4ea7925c0e9129337d2e3da3dadb2c489&ids=BTC"));
    final dataBody = json.decode(response.body).first;
    UserModel userModel = UserModel.fromJson(dataBody);
    _streamController.sink.add(userModel);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<UserModel>(
          stream: _streamController.stream,
          builder: (context,snapdata){
            switch(snapdata.connectionState){
              case ConnectionState.waiting : return Center(child: CircularProgressIndicator(),);
              default : if(snapdata.hasError){
                return Text("Please wait...");
              }
              else{
                return coinWidget(snapdata.data! );
              }

            };
          },
        ),
      ),
    );
  }

Widget coinWidget (UserModel userModel){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${userModel.name}"),

          SvgPicture.network("${userModel.logoUrl}",width: 150,height: 150,),
          Text("${userModel.price}"),
        ],
      ),
    );
}
}
