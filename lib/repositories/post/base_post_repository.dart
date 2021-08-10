import 'package:instaclone/models/models.dart';

abstract class BasePostRepository {
  Future<void> createPost({required Post post});
  Future<void> createComment({required Comment comment});
  Stream<List<Future<Post?>>> getUserPosts({required String userID});
  Stream<List<Future<Comment?>>> getPostComments({required String postID});
}
