// //this model is used to store the data of transactions that we get from the api
import 'column_data.dart';

class Transaction {
  final Map<String, dynamic> jsonData;

  Transaction(this.jsonData);

  dynamic getValue(
    List<ColumnData>? columns,
    String configProp,
    List<String>? jsonPaths,
  ) {
    for (var i = 0; i < columns!.length; i++) {
      if (configProp == columns[i].key) {
        return jsonData[columns[i].key];
      }
      if (configProp == columns[i].label) {
        return jsonData[columns[i].label];
      }

      if (configProp == columns[i].type) {
        return jsonData[columns[i].type];
      }
    }
  }

  dynamic getValueLargeScreen(ColumnData column) {
    dynamic value = jsonData[column.key];
    print(value);
    return value;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(json);
  }
}
