//this will define our structure of data that is also given in sample json in task
//and this structured data will be used in our grid
//they are used as labels/title in the top row
class ColumnData {
  final String? label;
  final String? key;
  final String? type;

  ColumnData({
    this.label,
    this.key,
    this.type,
  });
}
