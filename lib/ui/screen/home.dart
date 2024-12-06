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

  Widget _buildFeeEstimateColumn(String label, int feeValue, Color labelColor) {
    String tooltipMessage = switch(label) {
      "Low" => "Value in sats/vByte.\n\nWhile not guaranteed, a transaction at this fee rate should be confirmed on the Bitcoin blockchain within 24 hours.",
      "Mid" => "Value in sats/vByte.\n\nWhile not guaranteed, a transaction at this fee rate should be confirmed on the Bitcoin blockchain within 3 hours.",
      "High" => "Value in sats/vByte.\n\nWhile not guaranteed, a transaction at this fee rate should be confirmed on the Bitcoin blockchain within 1 hour.",
      _ => "",
    };

    return Expanded(
      child: GestureDetector(
        onTapDown: (details) {
          //final RenderBox box = context.findRenderObject() as RenderBox;
          //final Offset position = box.localToGlobal(details.localPosition);
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  tooltipMessage,
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$feeValue",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the sorted estimates and select first, middle, and last
    var sortedEstimates = List<FeeEstimate>.from(estimates)
      ..sort((a, b) => a.timeToConfirmation.compareTo(b.timeToConfirmation));
    
    if (sortedEstimates.isEmpty) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    var highFee = sortedEstimates.first.satsPerVbyte;
    var midFee = sortedEstimates[sortedEstimates.length ~/ 2].satsPerVbyte;
    var lowFee = sortedEstimates.last.satsPerVbyte;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  _buildFeeEstimateColumn("Low", lowFee, Colors.amber),
                  const Spacer(),
                  _buildFeeEstimateColumn("Mid", midFee, Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  _buildFeeEstimateColumn("High", highFee, Colors.green),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
