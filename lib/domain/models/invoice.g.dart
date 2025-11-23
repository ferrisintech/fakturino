// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceAdapter extends TypeAdapter<Invoice> {
  @override
  final int typeId = 0;

  @override
  Invoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Invoice(
      id: fields[0] as int,
      invoiceNumber: fields[1] as String,
      contractorName: fields[2] as String,
      netAmount: fields[3] as double,
      vatRate: fields[4] as int,
      grossAmount: fields[5] as double,
      attachmentPath: fields[6] as String?,
    )..createdAt = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, Invoice obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.contractorName)
      ..writeByte(3)
      ..write(obj.netAmount)
      ..writeByte(4)
      ..write(obj.vatRate)
      ..writeByte(5)
      ..write(obj.grossAmount)
      ..writeByte(6)
      ..write(obj.attachmentPath)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
