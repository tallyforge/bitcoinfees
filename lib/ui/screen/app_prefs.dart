
import 'package:bitcoinfees/data/preferences/app_prefs.dart';
import 'package:bitcoinfees/ui/widget/number_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppPrefsScreen extends StatefulWidget {
  const AppPrefsScreen({super.key});

  @override
  State<AppPrefsScreen> createState() => _AppPrefsScreenState();
}

class _AppPrefsScreenState extends State<AppPrefsScreen> {
  late AppPrefs prefs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    prefs = context.watch<AppPrefs>();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (pop) {
        if(pop) {
          prefs.save();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Preferences")
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: const Text("Enable threshold notifications"),
                value: prefs.feeThresholdEnabled,
                onChanged: (value) {
                  if(value == null) return;

                  setState(() {
                    prefs.feeThresholdEnabled = value;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Notify on high fees?"),
                subtitle: Text(prefs.notifyHighFees ? "Yes" : "No"),
                value: prefs.notifyHighFees,
                onChanged: (value) {
                  if(value == null) return;

                  setState(() {
                    prefs.notifyHighFees = value;
                  });
                },
              ),
              ListTile(
                title: const Text("Notification threshold"),
                enabled: prefs.feeThresholdEnabled,
                subtitle: Text("${prefs.feeNotificationThreshold} sats/vbyte"),
                onTap: () async {
                  var newValue = await NumberInputDialog.showForInt(context, title: "Enter threshold", initialValue: prefs.feeNotificationThreshold);
                  if(newValue != null) {
                    setState(() {
                      prefs.feeNotificationThreshold = newValue;
                    });
                  }
                },
              ),
              CheckboxListTile(
                title: const Text("Enable short-term average notifications"),
                value: prefs.shortTermAverageFeeEnabled,
                onChanged: (value) {
                  if(value == null) return;

                  setState(() {
                    prefs.shortTermAverageFeeEnabled = value;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Enable long-term average notifications"),
                value: prefs.longTermAverageFeeEnabled,
                onChanged: (value) {
                  if(value == null) return;

                  setState(() {
                    prefs.longTermAverageFeeEnabled = value;
                  });
                },
              ),
              ListTile(
                title: const Text("Notification threshold"),
                enabled: prefs.shortTermAverageFeeEnabled || prefs.longTermAverageFeeEnabled,
                subtitle: Text("${prefs.averageFeeThresholdRatio} × average"),
                onTap: () async {
                  var newValue = await NumberInputDialog.showForDouble(context, title: "Enter threshold", initialValue: prefs.averageFeeThresholdRatio);
                  if(newValue != null) {
                    setState(() {
                      prefs.averageFeeThresholdRatio = newValue;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
