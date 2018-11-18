import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

typedef List<Widget> CreateWidgetList();

class CityPicker {
  static Widget show() {
    return new _CityPicker();
  }
}

class _CityPicker extends StatefulWidget {
  @override
  State createState() {
    return new _CityPickerState();
  }
}

class _CityPickerState extends State<_CityPicker> {
  List data = new List();
  List province = new List();
  List city = new List();
  List area = new List();
  FixedExtentScrollController provinceController =
      new FixedExtentScrollController();
  FixedExtentScrollController cityController =
      new FixedExtentScrollController();
  FixedExtentScrollController areaController =
      new FixedExtentScrollController();
  int provinceIndex = 0;
  int cityIndex = 0;
  int areaIndex = 0;

  void _loadData() {
    rootBundle.loadString('assets/data/province.json').then((v) {
      List data = json.decode(v);
      setState(() {
        this.data = data;
        this.province = data;
        this.city = data[provinceIndex]['children'];
        this.area = data[provinceIndex]['children'][cityIndex]['children'];
        _changed(0);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _changed(int index) {
    setState(() {
      provinceIndex = index;
      cityIndex = 0;
      areaIndex = 0;
      city = data[provinceIndex]['children'];
      area = data[provinceIndex]['children'][cityIndex]['children'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      body: new Container(
        width: double.infinity,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new MyPicker(
                controller: provinceController,
                key: Key('province'),
                createWidgetList: () {
                  return province.map((v) {
                    return new Text(v['label']);
                  }).toList();
                },
                changed: (int index) {
                  setState(() {
                    cityController.jumpToItem(0);
                    areaController.jumpToItem(0);
                    provinceIndex = index;
                    cityIndex = 0;
                    areaIndex = 0;
                    city = data[provinceIndex]['children'];
                    area =
                        data[provinceIndex]['children'][cityIndex]['children'];
                  });
                },
              ),
            ),
            new Expanded(
              flex: 1,
              child: new MyPicker(
                controller: cityController,
                key: Key('city'),
                createWidgetList: () {
                  return city.map((v) {
                    return new Text(v['label']);
                  }).toList();
                },
                changed: (index) {
                  setState(() {
                    areaController.jumpToItem(0);
                    cityIndex = index;
                    areaIndex = 0;
                    area =
                        data[provinceIndex]['children'][cityIndex]['children'];
                  });
                },
              ),
            ),
            new Expanded(
              flex: 1,
              child: new MyPicker(
                controller: areaController,
                key: Key('area'),
                createWidgetList: () {
                  return area.map((v) {
                    return new Text(v['label']);
                  }).toList();
                },
                changed: (index) {
                  setState(() {
                    areaIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPicker extends StatefulWidget {
  final CreateWidgetList createWidgetList;
  final ValueChanged<int> changed;
  final Key key;
  final FixedExtentScrollController controller;

  MyPicker({this.createWidgetList, this.changed, this.key, this.controller});

  @override
  State createState() {
    return new _MyPickerState();
  }
}

class _MyPickerState extends State<MyPicker> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new CupertinoPicker(
        key: widget.key,
        scrollController: widget.controller,
        itemExtent: 40.0,
        onSelectedItemChanged: (index) {
          if (widget.changed != null) {
            widget.changed(index);
          }
        },
        children: widget.createWidgetList().length > 0
            ? widget.createWidgetList()
            : [new Text('请选择')],
      ),
    );
  }
}
