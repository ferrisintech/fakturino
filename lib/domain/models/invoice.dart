import 'package:hive/hive.dart';

part 'invoice.g.dart';

@HiveType(typeId: 0)
class Invoice extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  late String invoiceNumber;

  @HiveField(2)
  late String contractorName;

  @HiveField(3)
  late double netAmount;

  @HiveField(4)
  late int vatRate;

  @HiveField(5)
  late double grossAmount;

  @HiveField(6)
  String? attachmentPath;

  @HiveField(7)
  late int createdAt;

  Invoice({
    this.id = -1,
    required this.invoiceNumber,
    required this.contractorName,
    required this.netAmount,
    required this.vatRate,
    required this.grossAmount,
    this.attachmentPath,
    int? createdAtTimestamp,
  }) : createdAt = createdAtTimestamp ?? DateTime.now().millisecondsSinceEpoch;

  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  set createdDateTime(DateTime date) => createdAt = date.millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceNumber == other.invoiceNumber &&
          contractorName == other.contractorName &&
          netAmount == other.netAmount &&
          vatRate == other.vatRate &&
          grossAmount == other.grossAmount &&
          attachmentPath == other.attachmentPath &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      invoiceNumber.hashCode ^
      contractorName.hashCode ^
      netAmount.hashCode ^
      vatRate.hashCode ^
      grossAmount.hashCode ^
      attachmentPath.hashCode ^
      createdAt.hashCode;
}