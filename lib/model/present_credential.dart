class PresentCredential {
  final String credentialId;
  final String verifierAddress;
  final String requestId;
  final String userDid;
  final String otherInfo;


  PresentCredential({
    required this.credentialId,
    required this.userDid,
    required this.verifierAddress,
    required this.requestId,
    required this.otherInfo
  });

  @override
  String toString() {
    return 'PresentCredential(credentialId: $credentialId, verifierAddress: $verifierAddress, requestId: $requestId, userDid: $userDid, otherInfo: $otherInfo)';
  }

  factory PresentCredential.fromJson(Map<String, dynamic> json) {
    return PresentCredential(
      credentialId: json['credentialId'],
      userDid: json['userDid'],
      verifierAddress: json['verifierAddress'],
      requestId: json['requestId'],
      otherInfo: json['otherInfo']
    );
  }
  
}