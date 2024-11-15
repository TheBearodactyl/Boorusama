// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruMoreActionButton extends ConsumerWidget {
  const DanbooruMoreActionButton({
    super.key,
    required this.post,
    this.onStartSlideshow,
  });

  final DanbooruPost post;
  final void Function()? onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;

    return SizedBox(
      width: 40,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        shape: const CircleBorder(),
        child: BooruPopupMenuButton(
          iconColor: Colors.white,
          onSelected: (value) {
            switch (value) {
              case 'download':
                ref.download(post);
                break;
              case 'add_to_favgroup':
                goToAddToFavoriteGroupSelectionPage(context, [post]);
                break;
              case 'show_tag_list':
                goToDanbooruShowTaglistPage(
                  ref,
                  post.extractTags(),
                );
                break;
              case 'view_in_browser':
                launchExternalUrl(
                  post.getUriLink(booruConfig.url),
                );
                break;
              case 'view_original':
                goToOriginalImagePage(context, post);
                break;
              case 'start_slideshow':
                if (onStartSlideshow != null) {
                  onStartSlideshow!();
                }
                break;
              case 'tag_history':
                goToPostVersionPage(context, post);
                break;
              case 'settings':
                openImageViewerSettingsPage(context);
                break;
              default:
            }
          },
          itemBuilder: {
            'download': const Text('download.download').tr(),
            if (booruConfig.hasLoginDetails())
              'add_to_favgroup':
                  const Text('post.action.add_to_favorite_group').tr(),
            if (post.tags.isNotEmpty) 'show_tag_list': const Text('View tags'),
            'tag_history': const Text('View tag history'),
            if (!booruConfig.hasStrictSFW)
              'view_in_browser': const Text('post.detail.view_in_browser').tr(),
            if (post.hasFullView)
              'view_original':
                  const Text('post.image_fullview.view_original').tr(),
            if (onStartSlideshow != null)
              'start_slideshow': const Text('Slideshow'),
            'settings': const Text('settings.settings').tr(),
          },
        ),
      ),
    );
  }
}
