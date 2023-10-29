class VerifiedCredential {
  final String issuer;
  final String userDid;
  final String data;
  final String isRevoked;
  final String signature;


  VerifiedCredential({
    required this.issuer,
    required this.userDid,
    required this.data,
    required this.isRevoked,
    required this.signature
  });

  factory VerifiedCredential.fromJson(Map<String, dynamic> json) {
    return VerifiedCredential(
      issuer: json['issuer'],
      userDid: json['userDid'],
      data: json['data'],
      isRevoked: json['isRevoked'],
      signature: json['signature']
    );
  }
}