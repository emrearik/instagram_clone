part of 'liked_posts_cubit.dart';

class LikedPostsState extends Equatable {
  final Set<String?> likedPostIDs;
  final Set<String?> recentlyLikedPostIDs;
  const LikedPostsState(
      {required this.likedPostIDs, required this.recentlyLikedPostIDs});

  factory LikedPostsState.initial() {
    return LikedPostsState(likedPostIDs: {}, recentlyLikedPostIDs: {});
  }

  @override
  List<Object> get props => [likedPostIDs, recentlyLikedPostIDs];

  LikedPostsState copyWith({
    Set<String?>? likedPostIDs,
    Set<String?>? recentlyLikedPostIDs,
  }) {
    return LikedPostsState(
      likedPostIDs: likedPostIDs ?? this.likedPostIDs,
      recentlyLikedPostIDs: recentlyLikedPostIDs ?? this.recentlyLikedPostIDs,
    );
  }
}
