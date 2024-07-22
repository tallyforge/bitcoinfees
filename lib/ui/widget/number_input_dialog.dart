import 'package:flutter/material.dart';

class NumberInputDialog<T extends num> extends StatefulWidget {
  const NumberInputDialog({
    super.key,
    this.title = "Enter number",
    required this.initialValue,
  });

  final String title;
  final T initialValue;

  @override
  State<NumberInputDialog> createState() => _NumberInputDialogState<T>();

  static Future<double?> showForDouble(BuildContext context, {String title = "Enter number", double initialValue = 0}) {
    return showDialog<double>(context: context, builder: (context) => NumberInputDialog<double>(title: title, initialValue: initialValue));
  }

  static Future<int?> showForInt(BuildContext context, {String title = "Enter number", int initialValue = 0}) {
    return showDialog<int>(context: context, builder: (context) => NumberInputDialog<int>(title: title, initialValue: initialValue));
  }
}

class _NumberInputDialogState<T extends num> extends State<NumberInputDialog<T>> {
  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: T is double,
        ),
      ),
      actions: [
        TextButton(
          child: const Text("CANCEL"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("SUBMIT"),
          onPressed: () {
            var text = controller.text;
            var n = double.tryParse(text);
            if(n == null) {
              Navigator.of(context).pop();
              return;
            }

            if(T is int) {
              Navigator.of(context).pop(n.round());
            }
            else {
              Navigator.of(context).pop(n);
            }
          },
        )
      ],
    );
  }
}