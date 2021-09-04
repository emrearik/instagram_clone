import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/config/paths.dart';
import 'package:instaclone/models/notif_model.dart';
import 'package:instaclone/repositories/notification/base_notification_repository.dart';

class NotificationRepository extends BaseNotificationRepository {
  final FirebaseFirestore _firebaseFirestore;

  NotificationRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;
  @override
  Stream<List<Future<Notif?>>> getUserNotifications({required String userID}) {
    return _firebaseFirestore
        .collection(Paths.notifications)
        .doc(userID)
        .collection(Paths.userNotifications)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((doc) => Notif.fromDocument(doc)).toList());
  }
}
