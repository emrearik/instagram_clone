import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/config/paths.dart';
import 'package:instaclone/enums/enums.dart';
import 'package:instaclone/models/models.dart';
import 'package:instaclone/models/post_model.dart';
import 'package:instaclone/models/comment_model.dart';
import 'package:instaclone/repositories/repositories.dart';

class PostRepository extends BasePostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;
  @override
  Future<void> createPost({required Post post}) async {
    await _firebaseFirestore.collection(Paths.posts).add(post.toDocument());
  }

  @override
  Future<void> createComment(
      {required Post? post, required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postID)
        .collection(Paths.postComments)
        .add(comment.toDocument());

    final notification = Notif(
      type: NotifType.comment,
      fromUser: comment.author,
      post: post,
      date: DateTime.now(),
    );

    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(post!.author!.id)
        .collection(Paths.userNotifications)
        .add(notification.toDocument());
  }

  @override
  void createLike({required Post? post, required String? userID}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(post!.id)
        .update({'likes': FieldValue.increment(1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(post.id)
        .collection(Paths.postLikes)
        .doc(userID)
        .set({});

    final notification = Notif(
      type: NotifType.like,
      fromUser: User.empty.copyWith(id: userID),
      post: post,
      date: DateTime.now(),
    );

    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(post.author!.id)
        .collection(Paths.userNotifications)
        .add(notification.toDocument());
  }

  @override
  Stream<List<Future<Post?>>> getUserPosts({required String userID}) {
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userID);
    return _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  @override
  Stream<List<Future<Comment?>>> getPostComments({required String? postID}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postID)
        .collection(Paths.postComments)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }

  @override
  Future<List<Post?>> getUserFeed(
      {required String userID, String? lastPostID}) async {
    QuerySnapshot postsSnap;

    if (lastPostID == null) {
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userID)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .limit(3)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userID)
          .collection(Paths.userFeed)
          .doc(lastPostID)
          .get();

      if (!lastPostDoc.exists) {
        return [];
      }

      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userID)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(3)
          .get();
    }
    final posts = Future.wait(
      postsSnap.docs.map((doc) => Post.fromDocument(doc)).toList(),
    );
    return posts;
  }

  @override
  Future<Set<String?>> getLikedPostIDs(
      {required String userID, required List<Post?> posts}) async {
    final postIDs = <String?>{};
    for (final post in posts) {
      final likeDoc = await _firebaseFirestore
          .collection(Paths.likes)
          .doc(post!.id)
          .collection(Paths.postLikes)
          .doc(userID)
          .get();

      if (likeDoc.exists) {
        postIDs.add(post.id);
      }
    }
    return postIDs;
  }

  @override
  void deleteLike({required String? postID, required String? userID}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(postID)
        .update({'likes': FieldValue.increment(-1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(postID)
        .collection(Paths.postLikes)
        .doc(userID)
        .delete();
  }
}
