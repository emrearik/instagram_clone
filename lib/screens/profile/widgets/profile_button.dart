import 'package:flutter/material.dart';
import 'package:instaclone/screens/profile/bloc/profile_bloc.dart';
import 'package:instaclone/screens/screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileButton extends StatelessWidget {
  final bool isCurrentUser;
  final bool isFollowing;

  const ProfileButton(
      {Key? key, required this.isCurrentUser, required this.isFollowing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCurrentUser
        ? MaterialButton(
            onPressed: () => Navigator.of(context).pushNamed(
              EditProfileScreen.routeName,
              arguments: EditProfileScreenArgs(context: context),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text(
              "Edit Profile",
              style: TextStyle(fontSize: 16),
            ),
          )
        : MaterialButton(
            onPressed: () => isFollowing
                ? context.read<ProfileBloc>().add(ProfileUnfollowUser())
                : context.read<ProfileBloc>().add(ProfileFollowUser()),
            color: isFollowing
                ? Colors.grey.shade300
                : Theme.of(context).primaryColor,
            textColor: isFollowing ? Colors.black : Colors.white,
            child: Text(
              isFollowing ? 'Unfollow' : 'Follow',
              style: TextStyle(fontSize: 16),
            ),
          );
  }
}
