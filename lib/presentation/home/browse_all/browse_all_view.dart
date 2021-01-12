import 'package:boorusama/application/home/browse_all/browse_all_state_notifier.dart';
import 'package:boorusama/presentation/home/refreshable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final browseAllStateNotifier = StateNotifierProvider<BrowseAllStateNotifier>(
    (ref) => BrowseAllStateNotifier(ref));

class BrowseAllView extends StatefulWidget {
  BrowseAllView({Key key}) : super(key: key);

  @override
  _BrowseAllViewState createState() => _BrowseAllViewState();
}

class _BrowseAllViewState extends State<BrowseAllView>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    Future.delayed(Duration.zero,
        () => context.read(browseAllStateNotifier).getPosts("", 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderListener<BrowseAllState>(
      provider: browseAllStateNotifier.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts, page, query) => _refreshController
              ..loadComplete()
              ..refreshCompleted(),
            orElse: () {});
      },
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(browseAllStateNotifier.state);
          return state.when(
              initial: () => Center(),
              loading: () => Center(child: CircularProgressIndicator()),
              fetched: (posts, page, query) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: _downloadAllPosts,
                    heroTag: null,
                    child: Icon(Icons.download_sharp),
                  ),
                  body: RefreshableList(
                    posts: posts,
                    onLoadMore: () => context
                        .read(browseAllStateNotifier)
                        .getMorePosts(posts, query, page),
                    onRefresh: () =>
                        context.read(browseAllStateNotifier).refresh(),
                    refreshController: _refreshController,
                  ),
                );
              });
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _downloadAllPosts() {
    // _posts.forEach((post) {
    //   context
    //       .read<PostDownloadBloc>()
    //       .add(PostDownloadEvent.downloaded(post: post));
    // });
  }
}