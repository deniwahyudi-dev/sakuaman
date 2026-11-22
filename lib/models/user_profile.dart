class UserProfile {
  final String name;
  static const String defaultName = 'Pengguna SakuAman';

  UserProfile({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      UserProfile(name: json['name'] as String);
}
