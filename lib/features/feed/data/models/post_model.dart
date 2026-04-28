/// Immutable data model representing a social feed post.
class PostModel {
  final String id;
  final DateTime createdAt;
  final String mediaThumbUrl;
  final String mediaMobileUrl;
  final String mediaRawUrl;
  final int likeCount;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.createdAt,
    required this.mediaThumbUrl,
    required this.mediaMobileUrl,
    required this.mediaRawUrl,
    this.likeCount = 0,
    this.isLiked = false,
  });

  /// Creates a [PostModel] from a Supabase JSON row.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaThumbUrl: json['media_thumb_url'] as String? ?? '',
      mediaMobileUrl: json['media_mobile_url'] as String? ?? '',
      mediaRawUrl: json['media_raw_url'] as String? ?? '',
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: false,
    );
  }

  /// Creates a shallow copy with optional field overrides.
  PostModel copyWith({
    String? id,
    DateTime? createdAt,
    String? mediaThumbUrl,
    String? mediaMobileUrl,
    String? mediaRawUrl,
    int? likeCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      mediaThumbUrl: mediaThumbUrl ?? this.mediaThumbUrl,
      mediaMobileUrl: mediaMobileUrl ?? this.mediaMobileUrl,
      mediaRawUrl: mediaRawUrl ?? this.mediaRawUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          likeCount == other.likeCount &&
          isLiked == other.isLiked;

  @override
  int get hashCode => Object.hash(id, likeCount, isLiked);

  @override
  String toString() =>
      'PostModel(id: $id, likes: $likeCount, isLiked: $isLiked)';
}
