class Budget {
  final String category;
  final double limit;

  Budget({required this.category, required this.limit});

  Map<String, dynamic> toJson() => {
        'category': category,
        'limit': limit,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        category: json['category'] as String,
        limit: (json['limit'] as num).toDouble(),
      );

  Budget copyWith({
    String? category,
    double? limit,
  }) {
    return Budget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
    );
  }
}
