import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:new_app/slider_widget.dart';
import 'package:web3dart/web3dart.dart';
import "package:velocity_x/velocity_x.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: MyHomePage(title: 'Donation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Client httpClient;
  Web3Client ethClient;
  bool data = false;
  int myAmount = 0;
  final myAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
  String txHash;
  var myData;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/6d4d9a9d876e4757b220e3be377393ff",
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xd9145CCE52D386f254917e481eB44e9943F39138";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKCoin"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    //EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);

    myData = result[0];
    data = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .black
            .size(context.screenWidth, context.percentHeight * 30)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "FUNDS".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 5).heightBox,
          VxBox(
              child: VStack([
                "Balance".text.gray700.xl2.semiBold.makeCentered(),
                10.heightBox,
                data
                    ? "\$$myData".text.bold.xl6.makeCentered().shimmer()
                    : CircularProgressIndicator().centered()
              ]))
              .p16
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded
              .shadowXl
              .make(),
          30.heightBox,

          SliderWidget(
            min: 0,
            max: 100,
          ).centered(),

          HStack([
            FlatButton.icon(
                onPressed: () {},
                color: Colors.black26,
                shape: Vx.roundedSm,
                icon: Icon(Icons.refresh, color: Colors.white,),
                label: "Refresh".text.white.make()
            ),
            FlatButton.icon(
                onPressed: () {},
                color: Colors.black26,
                shape: Vx.roundedSm,
                icon: Icon(Icons.call_made_outlined, color: Colors.white,),
                label: "Deposit".text.white.make()
            ),
          ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ).p16(),
          if(txHash!=null)
            txHash.text.black.makeCentered().p16()
        ])
      ]),
    );
  }
}