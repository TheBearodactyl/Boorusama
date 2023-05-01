// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/settings.dart';
import 'related_tag_section.dart';
import 'result_header.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    this.headerBuilder,
    this.scrollController,
    this.backgroundColor,
    required this.pagination,
  });

  final List<Widget> Function()? headerBuilder;
  final AutoScrollController? scrollController;
  final Color? backgroundColor;
  final bool pagination;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final refreshController = RefreshController();
  late final scrollController =
      widget.scrollController ?? AutoScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.pagination
        ? _InfiniteScroll(
            backgroundColor: widget.backgroundColor,
            scrollController: scrollController,
            refreshController: refreshController,
            headerBuilder: widget.headerBuilder,
          )
        : Scaffold(
            body: CustomScrollView(
            slivers: [
              if (widget.headerBuilder != null) ...widget.headerBuilder!.call(),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Center(
                      child: Text(
                          'Pagination is temporarily disabled. Please change to infinite scroll in Settings')),
                ),
              )
            ],
          ));
  }
}

class _InfiniteScroll extends StatelessWidget {
  const _InfiniteScroll({
    required this.scrollController,
    required this.refreshController,
    this.headerBuilder,
    this.backgroundColor,
  });

  final AutoScrollController scrollController;
  final RefreshController refreshController;
  final List<Widget> Function()? headerBuilder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagSearchBloc, TagSearchState>(
      builder: (context, state) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return DanbooruPostScope(
            fetcher: (page) => context.read<DanbooruPostRepository>().getPosts(
                  state.selectedTags.join(' '),
                  page,
                  limit: settingsState.settings.postsPerPage,
                ),
            builder: (context, controller, errors) {
              return DanbooruInfinitePostList(
                controller: controller,
                errors: errors,
                sliverHeaderBuilder: (context) => [
                  ...headerBuilder?.call() ?? [],
                  const SliverToBoxAdapter(child: RelatedTagSection()),
                  const SliverToBoxAdapter(child: ResultHeader()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class NoImplicitScrollPhysics extends AlwaysScrollableScrollPhysics {
  const NoImplicitScrollPhysics({super.parent});

  @override
  bool get allowImplicitScrolling => false;

  @override
  NoImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoImplicitScrollPhysics(parent: buildParent(ancestor));
  }
}
