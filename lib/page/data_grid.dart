import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:configurable_data_grid/models/column_data.dart';
import 'dart:convert';
import 'package:configurable_data_grid/models/transaction.dart';
import 'package:get/get.dart';

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
          return isSmallScreen
              ? _buildMobileView(
                  snapshot.data, widget.titleColumn, widget.subtitleColumn)
              : _buildLargeScreenView(snapshot.data, widget.columns);
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
      final List<dynamic> jsonData = json.decode(response.body)['transactions'];
      return jsonData.map((e) => Transaction.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }


  //for screens larger than mobile phone
  _buildLargeScreenView(List<Transaction>? data, List<ColumnData>? columns) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: columns!
            .map((TransactionData) =>
            DataColumn(label: Text(TransactionData.label!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),))
            .toList(),
        rows: data!
            .map(
              (item) => DataRow(
            cells: [
              DataCell(Text(item.name!)),
              DataCell(Text(item.date.toString().substring(0,10))),
              DataCell(Text(item.category!)),
              DataCell(Text(item.amount.toString())),
              DataCell(Text(item.createdAt.toString().substring(0,10))),
            ],
          ),
        )
            .toList(),
      ),
    );
  }

  //methods used mobile phone view
  Widget _buildMobileView(List<Transaction>? transactions, String? titleColumnKey,
      String? subtitleColumnKey) {
    return ListView.builder(
      itemCount: transactions!.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildListTile(transaction, titleColumnKey, subtitleColumnKey);
      },
    );
  }

  //this tile is used in listview for mobile screen which has configured Title and Subtitle
  Widget _buildListTile(Transaction transaction, String? titleColumnKey,
      String? subtitleColumnKey) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(_getValueFromKey(transaction, titleColumnKey!)!),
        subtitle: Text(_getValueFromKey(transaction, subtitleColumnKey!)!),
        onTap: () => _onTransactionTapped(transaction),
      ),
    );
  }

  //to open details in dialog and edit config
  void _onTransactionTapped(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Configuration: To set as Title do Single Tab and for Subtitle Double Tab',
            style: TextStyle(
                fontSize: 17
            ),),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(child: Text(transaction.name!),
                onDoubleTap: () {
                  widget.titleColumn = 'name';
                },
                onTap: () {
                  widget.subtitleColumn = 'name';
                  setState(() {

                  });
                },),
              Divider(),
              GestureDetector(
                child: Text('Date: ${transaction.date.toString().substring(0,10)}',),
                onDoubleTap: () {
                  widget.titleColumn = 'date';
                },
                onTap: () {
                  widget.subtitleColumn = 'date';
                },
              ),
              Divider(),
              GestureDetector(child: Text('Category: ${transaction.category}'),
                onDoubleTap: () {
                  widget.titleColumn = 'category';
                },
                onTap: () {
                  widget.subtitleColumn = 'category';
                },
              ),
              Divider(),
              GestureDetector(child: Text('Amount: ${transaction.amount}'),
                onDoubleTap: () {
                  widget.titleColumn = 'amount';
                },
                onTap: () {
                  widget.subtitleColumn = 'amount';
                },
              ),
              Divider(),
              GestureDetector(child: Text('Created At: ${transaction.createdAt.toString().substring(0,10)}'),
                onDoubleTap: () {
                  widget.titleColumn = 'created_at';
                },
                onTap: () {
                  widget.subtitleColumn = 'created_at';
                },
              ),
              Divider(),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //get values for selected columnKey
  String? _getValueFromKey(Transaction transaction, String key) {
    switch (key) {
      case 'name':
        return transaction.name!;
      case 'date':
        return transaction.date.toString();
      case 'category':
        return transaction.category.toString();
      case 'amount':
        return transaction.amount.toString();
      case 'created_at':
        return transaction.createdAt.toString();


      default:
        return null;
    }
  }
}
