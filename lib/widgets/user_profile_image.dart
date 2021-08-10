import 'dart:io' as i;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserProfileImage extends StatelessWidget {
  final double radius;
  final String profileImageUrl;
  String noPhoto =
      "https://upload.wikimedia.org/wikipedia/commons/2/2f/No-photo-m.png";
  final i.File? profileImage;
  UserProfileImage({
    Key? key,
    required this.radius,
    required this.profileImageUrl,
    this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: profileImage != null
          ? FileImage(profileImage!)
          : profileImageUrl.isNotEmpty
              ? CachedNetworkImageProvider(profileImageUrl) as ImageProvider
              : CachedNetworkImageProvider(noPhoto),
      child: _noProfileIcon(),
    );
  }

  Icon? _noProfileIcon() {
    if (profileImage == null && profileImageUrl.isEmpty) {
      return Icon(
        Icons.account_circle,
        color: Colors.grey.shade400,
        size: radius * 2,
      );
    }
    return null;
  }
}
