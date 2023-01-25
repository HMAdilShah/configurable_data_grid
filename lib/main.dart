import 'package:flutter/material.dart';
import 'models/column_data.dart';
import 'page/data_grid.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Configurable Data Grid',
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Configurable-DataGrid'),
        ),
        body: DataGrid(
          // apiEndpoint: 'https://us-central1-fir-apps-services.cloudfunctions.net/transactions',
          apiEndpoint: 'https://mocki.io/v1/43ac82f0-dd21-4390-b910-30679aeaa48f',
          columns: [
            ColumnData(label: 'Name', key: 'name', type: 'string'),
            ColumnData(label: 'Date', key: 'date', type: 'date'),
            ColumnData(label: 'Category', key: 'category', type: 'string'),
            ColumnData(label: 'Amount', key: 'amount', type: 'number'),
            ColumnData(label: 'Created At', key: 'created_at', type: 'date'),
          ],
          jsonPaths: [
            'name',
            'date',
            'category',
            'amount',
            'created_at',
          ],
          titleColumn: 'name',
          subtitleColumn: 'date',
        ),
      ),
    );
  }
}
