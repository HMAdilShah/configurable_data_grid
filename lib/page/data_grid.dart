import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:configurable_data_grid/models/column_data.dart';
import 'dart:convert';
import 'package:configurable_data_grid/models/transaction.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DataGrid extends StatefulWidget {
  final String? apiEndpoint;
  final List<ColumnData>? columns;
  final List<String>? jsonPaths;
  String? titleColumn;
  String? subtitleColumn;

  DataGrid({
    this.apiEndpoint,
    this.columns,
    this.jsonPaths,
    this.titleColumn,
    this.subtitleColumn,
  });

  @override
  _DataGridState createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  Future<List<Transaction>>? _data;
  String configProp = 'key';

  @override
  void initState() {
    super.initState();
    _data = fetchData(widget.apiEndpoint, widget.columns, widget.jsonPaths);
  }

  @override
  Widget build(BuildContext context) {
    //if screen size is less than 600 it will render _buildMobileView
    // and _buildLargeScreenView in vice versa
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return FutureBuilder<List<Transaction>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.2,
                child: isSmallScreen
                    ? _buildMobileView(snapshot.data, widget.columns,
                        widget.titleColumn, widget.subtitleColumn)
                    : _buildLargeScreenView(snapshot.data!, widget.columns),
              ),
              //configuration properties
              // ● Label, key and Data type for each column
              /*ToggleSwitch(
                initialLabelIndex: 0,
                totalSwitches: 3,
                labels: ['Label', 'Key', 'Type'],
                onToggle: (index) {
                  print('switched to: $index');

                  if (configProp == 'key') {
                    widget.titleColumn = widget.columns![0].key;
                    widget.subtitleColumn = widget.columns![1].key;
                  } else if (configProp == 'label') {
                    widget.titleColumn = widget.columns![0].label;
                    widget.subtitleColumn = widget.columns![1].label;
                  }
                  if (configProp == 'type') {
                    widget.titleColumn = widget.columns![0].type;
                    widget.subtitleColumn = widget.columns![1].type;
                  }
                },
              ),*/
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  //fetch data from the apiEndpoint
  Future<List<Transaction>> fetchData(String? apiEndpoint,
      List<ColumnData>? columns, List<String>? jsonPaths) async {
    final response = await http.get(Uri.parse(apiEndpoint!));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final transactions = <Transaction>[];
      for (dynamic e in jsonData['data']) {
        transactions.add(Transaction.fromJson(e));
      }
      return transactions;
    } else {
      throw Exception('Failed to load data');
    }
    /*if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<Transaction> transactions = [];
      for (var item in data) {
        transactions.add(Transaction.fromJson(item, jsonPaths!));
      }
      return transactions;
    } else {
      throw Exception('Failed to load data');
    }*/
  }

  //for screens larger than mobile phone
  Widget _buildLargeScreenView(
      List<Transaction> transactions, List<ColumnData>? columns) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          for (var col in columns!) DataColumn(label: Text(col.label!)),
        ],
        rows: transactions.map((trans) {
          return DataRow(
            cells: [
              for (var col in columns)
                DataCell(Text(trans.getValueLargeScreen(col).toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  //methods used mobile phone view
  Widget _buildMobileView(
      List<Transaction>? transactions,
      List<ColumnData>? columns,
      String? titleColumnKey,
      String? subtitleColumnKey) {
    if (titleColumnKey!.isEmpty) {
      if (configProp == 'key') {
        titleColumnKey = columns![0].key;
        subtitleColumnKey = columns[1].key;
      }
      /* else if (configProp == 'label') {
        titleColumnKey = columns![0].label;
        subtitleColumnKey = columns[1].label;
      } else if (configProp == 'type') {
        titleColumnKey = columns![0].type;
        subtitleColumnKey = columns[1].type;
      }*/
    } else if (subtitleColumnKey!.isEmpty) {
      if (configProp == 'key') {
        subtitleColumnKey = columns![1].key;
      }
    }
    return ListView.builder(
      itemCount: transactions?.length,
      itemBuilder: (BuildContext context, int index) {
        Transaction trans = transactions![index];
        return Column(children: [
          _buildListTile(columns, trans, titleColumnKey, subtitleColumnKey,
              widget.jsonPaths)
        ]);
      },
    );
  }

  //this tile is used in listview for mobile screen which has configured Title and Subtitle
  Widget _buildListTile(
      List<ColumnData>? columns,
      Transaction transaction,
      String? titleColumnKey,
      String? subtitleColumnKey,
      List<String>? jsonPaths) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: ListTile(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text((transaction
              .getValue(columns, titleColumnKey!, jsonPaths)
              .toString())),
          subtitle: Text(
            (transaction
                .getValue(columns, subtitleColumnKey!, jsonPaths)
                .toString()),
          ),
          onTap: () => _onTransactionTapped(transaction),
        ));
  }

  //to open details in dialog and edit config
  void _onTransactionTapped(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
                'Configuration: \nTo set as Title do Single Tab\n and for Subtitle Double Tab'),
            content: Container(
                height: 300.0,
                width: 300.0,
                child: ListView.builder(
                  itemCount: widget.columns?.length,
                  itemBuilder: (BuildContext context, int index) {
                    ColumnData colm = widget.columns![index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.titleColumn = colm.key;
                        });
                        Navigator.pop(context);
                      },
                      onDoubleTap: () {
                        setState(() {
                          widget.subtitleColumn = colm.key;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            colm.label!,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          )),
                    );
                  },
                )));
      },
    );
  }
}
