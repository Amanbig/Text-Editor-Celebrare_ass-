import 'package:flutter/material.dart';

class Options extends StatelessWidget {
  final Function() onEditOptions;
  final Function() onEditOrder;
  const Options({super.key, required this.onEditOptions,required this.onEditOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: onEditOptions,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.white)
            ),
            child: Text(
              'edit options',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onEditOrder,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.white)
            ),
            child: Text(
              'edit order',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
