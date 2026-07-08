class GiftItem {
  final String id;
  final String authorId;
  final String type;
  final int amount;

  GiftItem({
    required this.id,
    required this.authorId,
    required this.type,
    required this.amount,
  });

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json["_id"] ?? "",
      authorId: json["authorId"]?["_id"]?.toString() ?? "",
      type: json["giftType"] ?? "",
      amount: json["amount"] ?? 1,
    );
  }
}
