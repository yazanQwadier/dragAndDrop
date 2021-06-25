import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DragAndDrop());
}

class DragAndDrop extends StatefulWidget {
  @override
  _DragAndDropState createState() => _DragAndDropState();
}

class _DragAndDropState extends State<DragAndDrop> {
  bool successfulDrop = false;
  Map btns_order;

  // function to set in cache and get from it
  set_btns_in_cache() async {
    SharedPreferences cache_btns = await SharedPreferences.getInstance();
    String btns = cache_btns.getString("btns");
    if (btns != null) {
      return btns;
    } else {
      Map<String, String> btns_map = {'1': "button 1", '2': "button 2"};
      btns = jsonEncode(btns_map);
      cache_btns.setString("btns", btns);
      return btns;
    }
  }

  // Build Buttons Function
  Widget build_button_widget(button, order) {
    return Draggable(
      child: DragTarget<String>(
        builder: (BuildContext context, List<String> incoming, List rejected) {
          if (successfulDrop == true) {
            return Text('Dropped!');
          } else {
            return button;
          }
        },
        onWillAccept: (data) {
          print("from ${data} to ${order}");
          return (data != order);
        },
        onAccept: (data) {
          print("onAccept " + data.toString());

          setState(() {
            var temp = btns_order[order];
            btns_order[order] = btns_order[data];
            btns_order[data] = temp;
          });
        },
        onLeave: (data) {
          print("onLeave " + data.toString());
        },
      ),
      data: order,
      feedback: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          color: Colors.green,
          width: 60,
          height: 60,
        ),
      ),
      childWhenDragging: Container(width: 80, height: 35, color: Colors.grey),
    );
  }

  @override
  void initState() {
    set_btns_in_cache().then((response) {
      setState(() {
        btns_order = jsonDecode(response);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Drag And Drop')),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 50),
              (btns_order != null)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: btns_order.keys.map((key) {
                        Widget button;
                        switch (btns_order[key]) {
                          case "button 1":
                            button = ElevatedButton(
                                onPressed: () {
                                  print("button 1");
                                },
                                child: Text("Button 1"));

                            break;
                          case "button 2":
                            button = ElevatedButton(
                                onPressed: () {
                                  print("button 2");
                                },
                                child: Text("Button 2"));
                            break;
                        }
                        print(key);

                        return build_button_widget(button, key);
                      }).toList())
                  : Text(''),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
