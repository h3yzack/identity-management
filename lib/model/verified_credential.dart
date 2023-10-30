class VerifiedCredential {
  final String issuer;
  final String userDid;
  final String data;
  final String isRevoked;
  final String signature;
  final String credentialId;


  VerifiedCredential({
    required this.issuer,
    required this.userDid,
    required this.data,
    required this.isRevoked,
    required this.signature,
    required this.credentialId
  });

  factory VerifiedCredential.fromJson(Map<String, dynamic> json) {
    return VerifiedCredential(
      issuer: json['issuer'],
      userDid: json['userDid'],
      data: json['data'],
      isRevoked: json['isRevoked'],
      signature: json['signature'],
      credentialId: json['credentialId']
    );
  }

  @override
  String toString() {
    return 'VerifiedCredential(credentialId: $credentialId, issuer: $issuer, userDid: $userDid, userDid: $userDid, signature: $signature)';
  }
}