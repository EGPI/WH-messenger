class UserSearchResponse {
  final List<UserSearchResultModel> data;
  final UserSearchMetaModel meta;

  const UserSearchResponse({
    required this.data,
    required this.meta,
  });

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];

    return UserSearchResponse(
      data: rawData
          .map(
            (item) => UserSearchResultModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      meta: UserSearchMetaModel.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class UserSearchResultModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserSearchResultModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  factory UserSearchResultModel.fromJson(Map<String, dynamic> json) {
    return UserSearchResultModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class UserSearchMetaModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const UserSearchMetaModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory UserSearchMetaModel.fromJson(Map<String, dynamic> json) {
    return UserSearchMetaModel(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }
}