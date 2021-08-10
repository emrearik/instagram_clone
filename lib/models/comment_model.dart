import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instaclone/config/paths.dart';

import 'package:instaclone/models/models.dart';

class Comment extends Equatable {
  final String? id;
  final String postID;
  final User? author;
  final String content;
  final DateTime date;
  Comment({
    this.id,
    required this.postID,
    required this.author,
    required this.content,
    required this.date,
  });

  @override
  List<Object?> get props => [id, postID, author, content, date];

  Comment copyWith({
    String? id,
    String? postID,
    User? author,
    String? content,
    DateTime? date,
  }) {
    return Comment(
      id: id ?? this.id,
      postID: postID ?? this.postID,
      author: author ?? this.author,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'postID': postID,
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author!.id),
      'content': content,
      'date': Timestamp.fromDate(date),
    };
  }

  static Future<Comment?> fromDocument(DocumentSnapshot doc) async {
    if (doc == null) return null;

    final data = doc;
    final authorRef = data['author'] as DocumentReference;
    if (authorRef != null) {
      final authorDoc = await authorRef.get();
      if (authorDoc.exists) {
        return Comment(
          id: doc.id,
          postID: data['postID'] ?? '',
          author: User.fromDocument(authorDoc),
          content: data['content'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
        );
      }
    }
    return null;
  }
}
