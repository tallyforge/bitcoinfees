import 'dart:async';

import 'package:bitcoinfees/background_processor.dart';
import 'package:bitcoinfees/data/fee_source.dart';
import 'package:bitcoinfees/data/source/bitcoinerlive.dart';
import 'package:bitcoinfees/ui/screen/app_prefs.dart';
import 'package:flutter/material.dart';
import 'package:result_type/result_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FeeEstimate> estimates = [];

  Future<void> _refreshEstimates() async {
    var estimateResult = await BitcoinerLiveFeeSource().getFeeEstimates();
    switch(estimateResult) {
      case Success(value: final data): {
        setState(() {
          estimates = data;
        });
      }
      case Failure(value: final error): {
        debugPrint("$error");
      }
    }

    runBackgroundTasks(estimates);
  }
  
  late Timer t;
  @override
  void initState() {
    super.initState();
    _refreshEstimates();
    t = Timer.periodic(const Duration(minutes: 5), (t) {
      _refreshEstimates();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    t.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AppPrefsScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for(var e in estimates)
              Text("${(e.timeToConfirmation.inMinutes / 10).round()} blocks: ${e.satsPerVbyte} sats/vByte",
                style: const TextStyle(fontSize: 18),
              )
          ],
        ),
      ),
    );
  }
}
