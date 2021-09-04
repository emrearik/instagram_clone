import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/config/paths.dart';
import 'package:instaclone/enums/enums.dart';
import 'package:instaclone/models/models.dart';
import 'package:instaclone/models/user_model.dart';
import 'package:instaclone/repositories/repositories.dart';

class UserRepository extends BaseUserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<User?> getUserWithID({required String? userID}) async {
    final doc =
        await _firebaseFirestore.collection(Paths.users).doc(userID).get();
    return doc.exists ? User.fromDocument(doc) : User.empty;
  }

  @override
  Future<void> updateUser({required User? user}) async {
    await _firebaseFirestore
        .collection(Paths.users)
        .doc(user!.id)
        .update(user.toDocument());
  }

  @override
  Future<List<User?>> searchUsers({required String query}) async {
    final userSnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('username', isGreaterThanOrEqualTo: query)
        .get();

    return userSnap.docs.map((doc) => User.fromDocument(doc)).toList();
  }

  @override
  void followUser({required String userID, required String followUserID}) {
    //Add followUser to user's userFollowing.
    _firebaseFirestore
        .collection(Paths.following)
        .doc(userID)
        .collection(Paths.userFollowing)
        .doc(followUserID)
        .set({});
    //Add user to folloUser's userFollowers.
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(followUserID)
        .collection(Paths.userFollowers)
        .doc(userID)
        .set({});
    final notification = Notif(
      type: NotifType.follow,
      fromUser: User.empty.copyWith(id: userID),
      date: DateTime.now(),
    );

    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(followUserID)
        .collection(Paths.userNotifications)
        .add(notification.toDocument());
  }

  @override
  void unfollowUser({required String userID, required String unfollowUserID}) {
    //remove unfollowUser from user's userFollowing.
    _firebaseFirestore
        .collection(Paths.following)
        .doc(userID)
        .collection(Paths.userFollowing)
        .doc(unfollowUserID)
        .delete();
    // remove user from unfollowUser's userFollowers.
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(unfollowUserID)
        .collection(Paths.userFollowers)
        .doc(userID)
        .delete();
  }

  @override
  Future<bool> isFollowing(
      {required String userID, required String otherUserID}) async {
    //is otherUser in user's userFollowing
    final otherUserDoc = await _firebaseFirestore
        .collection(Paths.following)
        .doc(userID)
        .collection(Paths.userFollowing)
        .doc(otherUserID)
        .get();

    return otherUserDoc.exists;
  }
}
