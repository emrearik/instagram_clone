part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadUser extends ProfileEvent {
  final String userID;

  const ProfileLoadUser({required this.userID});

  @override
  List<Object> get props => [userID];
}

class ProfileToggleGridView extends ProfileEvent {
  final bool isGridView;

  const ProfileToggleGridView({required this.isGridView});

  @override
  // TODO: implement props
  List<Object> get props => [isGridView];
}

class ProfileUpdatePosts extends ProfileEvent {
  final List<Post?> posts;

  const ProfileUpdatePosts({required this.posts});

  @override
  // TODO: implement props
  List<Object> get props => [posts];
}

class ProfileFollowUser extends ProfileEvent {}

class ProfileUnfollowUser extends ProfileEvent {}
