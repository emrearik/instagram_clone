import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instaclone/blocs/blocs.dart';
import 'package:instaclone/cubits/cubits.dart';
import 'package:instaclone/models/models.dart';
import 'package:instaclone/repositories/repositories.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final LikedPostsCubit _likedPostsCubit;

  FeedBloc({
    required PostRepository postRepository,
    required AuthBloc authBloc,
    required LikedPostsCubit likedPostsCubit,
  })  : _postRepository = postRepository,
        _authBloc = authBloc,
        _likedPostsCubit = likedPostsCubit,
        super(FeedState.initial());

  @override
  Stream<FeedState> mapEventToState(
    FeedEvent event,
  ) async* {
    if (event is FeedFetchPosts) {
      yield* _mapFeedFetchPostsToState();
    } else if (event is FeedPaginatePosts) {
      yield* _mapFeedPaginatePostsToState();
    }
  }

  Stream<FeedState> _mapFeedFetchPostsToState() async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);
    try {
      final posts =
          await _postRepository.getUserFeed(userID: _authBloc.state.user!.uid);
      _likedPostsCubit.clearAllLikedPosts();

      final likedPostIDs = await _postRepository.getLikedPostIDs(
          userID: _authBloc.state.user!.uid, posts: posts);

      _likedPostsCubit.updateLikedPosts(postIDs: likedPostIDs);

      yield state.copyWith(posts: posts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: Failure(message: 'We were unable to load your feed'),
      );
    }
  }

  Stream<FeedState> _mapFeedPaginatePostsToState() async* {
    yield state.copyWith(status: FeedStatus.paginating);
    try {
      final lastPostID = state.posts.isNotEmpty ? state.posts.last!.id : null;

      final posts = await _postRepository.getUserFeed(
          userID: _authBloc.state.user!.uid, lastPostID: lastPostID);
      final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);

      final likedPostIDs = await _postRepository.getLikedPostIDs(
          userID: _authBloc.state.user!.uid, posts: posts);

      _likedPostsCubit.updateLikedPosts(postIDs: likedPostIDs);

      yield state.copyWith(posts: updatedPosts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: Failure(message: 'We were unable to load your feed'),
      );
    }
  }
}
