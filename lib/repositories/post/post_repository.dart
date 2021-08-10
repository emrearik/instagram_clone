import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/config/paths.dart';
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
  Future<void> createComment({required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postID)
        .collection(Paths.postComments)
        .add(comment.toDocument());
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
  Stream<List<Future<Comment?>>> getPostComments({required String postID}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postID)
        .collection(Paths.postComments)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }
}