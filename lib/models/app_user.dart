/// Usuário (tutor) autenticado no aplicativo.
///
/// O contrato de serialização já está preparado para o payload da futura
/// API Laravel (`/api/user`).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.address,
    this.photoAsset,
    this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String address;
  final String? photoAsset;
  final DateTime? memberSince;

  String get firstName => name.split(' ').first;

  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? document,
    String? address,
    String? photoAsset,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      document: document ?? this.document,
      address: address ?? this.address,
      photoAsset: photoAsset ?? this.photoAsset,
      memberSince: memberSince,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      document: json['document'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photoAsset: json['photo'] as String?,
      memberSince: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'document': document,
      'address': address,
      'photo': photoAsset,
      'created_at': memberSince?.toIso8601String(),
    };
  }
}
