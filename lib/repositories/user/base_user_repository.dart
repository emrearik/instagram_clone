import 'package:instaclone/models/models.dart';

abstract class BaseUserRepository {
  Future<User?> getUserWithID({required String userID});
  Future<void> updateUser({required User user});
  Future<List<User?>> searchUsers({required String query});
  void followUser({required String userID, required String followUserID});
  void unfollowUser({required String userID, required String unfollowUserID});
  Future<bool> isFollowing(
      {required String userID, required String otherUserID});
}
