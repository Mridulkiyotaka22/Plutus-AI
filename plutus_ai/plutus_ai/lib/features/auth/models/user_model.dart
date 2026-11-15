class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String baseCurrency;
  final String taxJurisdiction;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.baseCurrency = 'USD',
    this.taxJurisdiction = 'US_FEDERAL',
  });

  String get displayName => ('$firstName $lastName'.trim().isNotEmpty)
      ? '$firstName $lastName'.trim()
      : username;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? 'demo_investor',
      email: json['email'] as String? ?? 'demo@plutus.ai',
      firstName: json['first_name'] as String? ?? 'Mridul',
      lastName: json['last_name'] as String? ?? 'Investor',
      baseCurrency: profile['base_currency'] as String? ?? 'USD',
      taxJurisdiction: profile['tax_jurisdiction'] as String? ?? 'US_FEDERAL',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'profile': {
          'base_currency': baseCurrency,
          'tax_jurisdiction': taxJurisdiction,
        },
      };

  static const demoUser = UserModel(
    id: 'usr-demo-001',
    username: 'demo_user',
    email: 'demo@plutus.ai',
    firstName: 'Mridul',
    lastName: 'Investor',
    baseCurrency: 'USD',
    taxJurisdiction: 'US_FEDERAL',
  );
}
