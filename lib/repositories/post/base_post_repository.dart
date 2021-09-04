import 'package:instaclone/models/models.dart';

abstract class BasePostRepository {
  Future<void> createPost({required Post post});

  Future<void> createComment({required Post post, required Comment comment});

  void createLike({required Post post, required String userID});

  Stream<List<Future<Post?>>> getUserPosts({required String userID});

  Stream<List<Future<Comment?>>> getPostComments({required String postID});

  Future<List<Post?>> getUserFeed(
      {required String userID, required String lastPostID});

  Future<Set<String?>> getLikedPostIDs(
      {required String userID, required List<Post> posts});

  void deleteLike({required String postID, required String userID});
}
