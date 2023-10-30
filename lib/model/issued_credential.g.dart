// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issued_credential.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssuedCredentialAdapter extends TypeAdapter<IssuedCredential> {
  @override
  final int typeId = 0;

  @override
  IssuedCredential read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssuedCredential(
      credentialId: fields[0] as String?,
      userDid: fields[1] as String?,
      userAddress: fields[2] as String?,
      base64Data: fields[3] as String?,
      signature: fields[4] as String?,
      issuerDid: fields[5] as String?,
      issuerAddress: fields[6] as String?,
      issueDate: fields[7] as DateTime?,
      createdBy: fields[8] as String?,
      issued: fields[9] as bool?,
    )..hashData = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, IssuedCredential obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.credentialId)
      ..writeByte(1)
      ..write(obj.userDid)
      ..writeByte(2)
      ..write(obj.userAddress)
      ..writeByte(3)
      ..write(obj.base64Data)
      ..writeByte(4)
      ..write(obj.signature)
      ..writeByte(5)
      ..write(obj.issuerDid)
      ..writeByte(6)
      ..write(obj.issuerAddress)
      ..writeByte(7)
      ..write(obj.issueDate)
      ..writeByte(8)
      ..write(obj.createdBy)
      ..writeByte(9)
      ..write(obj.issued)
      ..writeByte(10)
      ..write(obj.hashData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssuedCredentialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
