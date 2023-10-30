// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_credential.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletCredentialAdapter extends TypeAdapter<WalletCredential> {
  @override
  final int typeId = 1;

  @override
  WalletCredential read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletCredential(
      credentialId: fields[0] as String,
      userDid: fields[5] as String,
      issuerDid: fields[4] as String,
      issuerAddress: fields[3] as String,
      base64Data: fields[8] as String,
      signedData: fields[7] as String,
      signature: fields[1] as String,
      issueDate: fields[2] as DateTime,
      name: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WalletCredential obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.credentialId)
      ..writeByte(1)
      ..write(obj.signature)
      ..writeByte(2)
      ..write(obj.issueDate)
      ..writeByte(3)
      ..write(obj.issuerAddress)
      ..writeByte(4)
      ..write(obj.issuerDid)
      ..writeByte(5)
      ..write(obj.userDid)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.signedData)
      ..writeByte(8)
      ..write(obj.base64Data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletCredentialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
