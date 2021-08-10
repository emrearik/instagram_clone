import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

class StorageRepository extends BaseStorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({FirebaseStorage? firebaseStorage})
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<String> _uploadImage({
    required File? image,
    required String ref,
  }) async {
    final downloadUrl = await _firebaseStorage.ref(ref).putFile(image!).then(
          (taskSnapshot) => taskSnapshot.ref.getDownloadURL(),
        );
    return downloadUrl;
  }

  @override
  Future<String> uploadProfileImage(
      {required String url, required File? image}) async {
    var imageID = Uuid().v4();

    //Update user profile image.
    if (url.isNotEmpty) {
      final exp = RegExp(r'userProfile_(.*).jpg');
      String? imageID = exp.firstMatch(url)?[1];
    }

    final downloadURL = await _uploadImage(
      image: image,
      ref: 'images/users/userProfile_$imageID.jpg',
    );
    return downloadURL;
  }

  @override
  Future<String> uploadPostImage({required File image}) async {
    final imageID = Uuid().v4();
    final downloadURL = await _uploadImage(
      image: image,
      ref: 'images/posts/post_$imageID.jpg',
    );
    return downloadURL;
  }
}
