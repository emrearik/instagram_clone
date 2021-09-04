import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instaclone/blocs/blocs.dart';
import 'package:instaclone/models/models.dart';
import 'package:instaclone/repositories/repositories.dart';

part 'liked_posts_state.dart';

class LikedPostsCubit extends Cubit<LikedPostsState> {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;

  LikedPostsCubit(
      {required PostRepository postRepository, required AuthBloc authBloc})
      : _postRepository = postRepository,
        _authBloc = authBloc,
        super(LikedPostsState.initial());

  void updateLikedPosts({required Set<String?> postIDs}) {
    emit(
      state.copyWith(
        likedPostIDs: Set<String?>.from(state.likedPostIDs)..addAll(postIDs),
      ),
    );
  }

  void likePost({required Post post}) {
    _postRepository.createLike(post: post, userID: _authBloc.state.user!.uid);

    emit(
      state.copyWith(
        likedPostIDs: Set<String?>.from(state.likedPostIDs)..add(post.id),
        recentlyLikedPostIDs: Set<String?>.from(state.recentlyLikedPostIDs)
          ..add(post.id),
      ),
    );
  }

  void unlikePost({required Post post}) {
    _postRepository.deleteLike(
        postID: post.id, userID: _authBloc.state.user!.uid);

    emit(
      state.copyWith(
        likedPostIDs: Set<String?>.from(state.likedPostIDs)..remove(post.id),
        recentlyLikedPostIDs: Set<String?>.from(state.recentlyLikedPostIDs)
          ..remove(post.id),
      ),
    );
  }

  void clearAllLikedPosts() {
    emit(LikedPostsState.initial());
  }
}
