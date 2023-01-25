//this model is used to store the data of transactions that we get from the api
class Transaction {
  final int? id;
  final String? name;
  final DateTime? date;
  final String? category;
  final double? amount;
  final DateTime? createdAt;

  Transaction({
    this.id,
    this.name,
    this.date,
    this.category,
    this.amount,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      amount: json['amount'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
