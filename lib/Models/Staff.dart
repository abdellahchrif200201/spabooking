class Staff {
  final String name;
  final String id;
  final String avatarUrl;

  Staff({
    required this.name,
    required this.id,
    required this.avatarUrl,
  });
  factory Staff.fromJson(Map<String, dynamic> json) {
    List<dynamic> mediaList = json['user']['media'] as List<dynamic>;
    print(mediaList);
    String avatarUrl = mediaList.isNotEmpty
        ? (mediaList[0]['original_url'])
        : "https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D";
    print('Added Staff:');
    print('- Name: ${json['user']['name'] ?? ''}');
    print('- ID: ${(json['user']['id'] ?? '').toString()}');
    print('- Avatar URL: ${avatarUrl}');
    return Staff(
      name: json['user']['name'] ?? '',
      id: (json['user']['id'] ?? '').toString(),
      avatarUrl: avatarUrl,
    );
  }
}
