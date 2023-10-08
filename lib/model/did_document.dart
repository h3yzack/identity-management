class DidDocument {
  final String did;
  final String didType;
  final String title;
  final String? description;
  final String signature;
  final String user;


  DidDocument({
    required this.did,
    required this.didType,
    required this.title,
    required this.user,
    required this.signature,
    this.description
  });

  factory DidDocument.fromJson(Map<String, dynamic> json) {
    return DidDocument(
      did: json['did'],
      didType: json['didType'],
      title: json['title'],
      description: json['description'],
      signature: json['signature'],
      user: json['user'],
    );
  }
}