import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/blocs/blocs.dart';
import 'package:instaclone/cubits/cubits.dart';
import 'package:instaclone/repositories/repositories.dart';
import 'package:instaclone/screens/profile/widgets/widgets.dart';
import 'package:instaclone/screens/screens.dart';
import 'package:instaclone/widgets/widgets.dart';

import 'bloc/profile_bloc.dart';

class ProfileScreenArgs {
  final String userID;

  const ProfileScreenArgs({required this.userID});
}

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  static Route route({required ProfileScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<ProfileBloc>(
        create: (_) => ProfileBloc(
          userRepository: context.read<UserRepository>(),
          postRepository: context.read<PostRepository>(),
          likedPostsCubit: context.read<LikedPostsCubit>(),
          authBloc: context.read<AuthBloc>(),
        )..add(
            ProfileLoadUser(userID: args.userID),
          ),
        child: ProfileScreen(),
      ),
    );
  }

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(content: state.failure.message),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              state.user.username,
            ),
            actions: [
              if (state.isCurrentUser)
                IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      context.read<LikedPostsCubit>().clearAllLikedPosts();
                    }),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(ProfileState state) {
    switch (state.status) {
      case ProfileStatus.loading:
        return Center(child: CircularProgressIndicator());
      default:
        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<ProfileBloc>()
                .add(ProfileLoadUser(userID: state.user.id));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Row(
                        children: [
                          UserProfileImage(
                            radius: 40,
                            profileImageUrl: state.user.profileImageUrl,
                          ),
                          ProfileStats(
                            isCurrentUser: state.isCurrentUser,
                            isFollowing: state.isFollowing,
                            posts: state.posts.length,
                            followers: state.user.followers,
                            following: state.user.following,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: ProfileInfo(
                          username: state.user.username, bio: state.user.bio),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.grid_on, size: 28),
                    ),
                    Tab(
                      icon: Icon(Icons.list, size: 28),
                    ),
                  ],
                  indicatorWeight: 3,
                  onTap: (i) => context
                      .read<ProfileBloc>()
                      .add(ProfileToggleGridView(isGridView: i == 0)),
                ),
              ),
              state.isGridView
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = state.posts[index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamed(CommentsScreen.routeName,arguments: CommentsScreenArgs(post: post)),
                                
                            child: CachedNetworkImage(
                              imageUrl: post!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                        childCount: state.posts.length,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = state.posts[index];
                          final likedPostsState =
                              context.watch<LikedPostsCubit>().state;
                          final isLiked =
                              likedPostsState.likedPostIDs.contains(post!.id);

                          return PostView(
                            post: post,
                            isLiked: isLiked,
                            onLike: () {
                              if (isLiked) {
                                context
                                    .read<LikedPostsCubit>()
                                    .unlikePost(post: post);
                              } else {
                                context
                                    .read<LikedPostsCubit>()
                                    .likePost(post: post);
                              }
                            },
                          );
                        },
                        childCount: state.posts.length,
                      ),
                    ),
            ],
          ),
        );
    }
  }
}
