
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Uri _url = Uri.https(
  'api.hgbrasil.com',
  '/finance',
  {'?': 'format=json&key=06439c1d'},
);

void main() async {
  runApp(const MaterialApp(home: Home()));
}

Future<Map> buscarDados() async {
  var response = await http.get(_url);
  debugPrint(response.body);
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double _dolar = 0;
  double _euro = 0;
  double _bitcoin = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: bar(),
      body: body(),
    );
  }

  bar() => AppBar(
        title: const Text(
          '\$ Conversor \$',
          style: TextStyle(color: Colors.black, fontSize: 27.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreenAccent,
        actions: [
          IconButton( 
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _resetFields,
          )
        ],
      );

  body() => FutureBuilder<Map>(
        future: buscarDados(),
        builder: (context, snapshot) {
          debugPrint('teste1 ${snapshot.error}');
          debugPrint('teste2 ${snapshot.hasError}');
          debugPrint('teste3 ${snapshot.data}');

          if (snapshot.hasError) {
            return erro();
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return waiting();
              case ConnectionState.done:
                _dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                _euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                _bitcoin = snapshot.data!['results']['currencies']['BTC']['buy'];
                return done();
              default:
                return padrao();
            }
          }
        },
      );

  erro() => const Center(
        child: Text(
          "erro",
          style: TextStyle(color: Colors.white),
        ),
      );

  waiting() => const Center(
        child: Text(
          "Waiting",
          style: TextStyle(color: Colors.white),
        ),
      );

  done() => SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            icone(),
            textField('Reais', 'R/\$', realController, _realChanged),
            const Divider(),
            textField('Dólares', 'US/\$', dolarController, _dolarChanged),
            const Divider(),
            textField('Euros', 'EUR/€', euroController, _euroChanged),
            const Divider(),
            textField('Bitcoins', 'BTC/₿', bitcoinController, _bitcoinChanged),
            const Divider(),
          ],
        ),
      );

  padrao() => const Center(
        child: Text(
          "padrao",
          style: TextStyle(color: Colors.white),
        ),
      );

  icone() => const Icon(
        Icons.attach_money_rounded ,
        size: 200.0,
        color: Colors.black,
      );

  textField(String label, String prefix, TextEditingController controller,
          Function changed) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1)),
          prefixText: '$prefix ',
          prefixStyle: const TextStyle(color: Colors.black, fontSize: 19.0),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 19.0),
        onChanged: changed as void Function(String)?,
        keyboardType: TextInputType.number,
      );

  void _realChanged(String text) {
    double aux = double.parse(text.isEmpty ? '0' : text);

    dolarController.text = (aux / _dolar).toStringAsFixed(2);
    euroController.text = (aux / _euro).toStringAsFixed(2);
    bitcoinController.text = (aux / _bitcoin).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double aux = double.parse(text.isEmpty ? '0' : text);

    realController.text = (aux * _dolar).toStringAsFixed(2);
    euroController.text = ((_dolar / _euro) * aux).toStringAsFixed(2);
    bitcoinController.text = ((_dolar/_bitcoin)*aux).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double aux = double.parse(text.isEmpty ? '0' : text);

    realController.text = (aux * _euro).toStringAsFixed(2);
    dolarController.text = ((_euro / _dolar) * aux).toStringAsFixed(2);
    bitcoinController.text = ((_euro / _bitcoin) * aux).toStringAsFixed(2);
  }
  
  void _bitcoinChanged(String text) {
    double aux = double.parse(text.isEmpty ? '0' : text);

    euroController.text = ((_bitcoin / _euro) * aux).toStringAsFixed(2);
    realController.text = ((_bitcoin * aux)).toStringAsFixed(2);
    dolarController.text = ((_bitcoin / _dolar) / aux).toStringAsFixed(2);
  }

  void _resetFields(){
    realController.text ="";
    dolarController.text ="";
    euroController.text ="";
    bitcoinController.text ="";
    
  }
}
