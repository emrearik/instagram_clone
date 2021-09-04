import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:instaclone/models/models.dart';
import 'package:instaclone/screens/edit_profile/edit_profile_screen.dart';
import 'package:instaclone/screens/screens.dart';
import 'package:instaclone/widgets/user_profile_image.dart';
import 'package:instaclone/extensions/extensions.dart';

class PostView extends StatelessWidget {
  final Post? post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  const PostView({
    Key? key,
    required this.post,
    required this.isLiked,
    required this.onLike,
    this.recentlyLiked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              ProfileScreen.routeName,
              arguments: ProfileScreenArgs(userID: post!.author!.id),
            ),
            child: Row(
              children: [
                UserProfileImage(
                  radius: 18,
                  profileImageUrl: post!.author!.profileImageUrl,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post!.author!.username,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: onLike,
          child: CachedNetworkImage(
            height: MediaQuery.of(context).size.height / 2.25,
            imageUrl: post!.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: isLiked
                  ? Icon(Icons.favorite, color: Colors.red)
                  : Icon(
                      Icons.favorite_outline,
                    ),
              onPressed: onLike,
            ),
            IconButton(
              icon: Icon(
                Icons.comment_outlined,
              ),
              onPressed: () => Navigator.of(context).pushNamed(
                CommentsScreen.routeName,
                arguments: CommentsScreenArgs(post: post),
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${recentlyLiked ? post!.likes + 1 : post!.likes} likes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: post!.author!.username,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' '),
                    TextSpan(text: post!.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post!.date.timeAgo(),
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }
}
