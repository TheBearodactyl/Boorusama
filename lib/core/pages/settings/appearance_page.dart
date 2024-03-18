// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_tile.dart';

class AppearancePage extends ConsumerStatefulWidget {
  const AppearancePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

String _themeModeToString(ThemeMode theme) => switch (theme) {
      ThemeMode.dark => 'settings.theme.dark',
      ThemeMode.system || ThemeMode.amoledDark => 'settings.theme.amoled_dark',
      ThemeMode.light => 'settings.theme.light',
    };

String _imageQualityToString(ImageQuality quality) => switch (quality) {
      ImageQuality.highest => 'settings.image_grid.image_quality.highest',
      ImageQuality.high => 'settings.image_grid.image_quality.high',
      ImageQuality.low => 'settings.image_grid.image_quality.low',
      ImageQuality.original => 'settings.image_grid.image_quality.original',
      ImageQuality.automatic => 'settings.image_grid.image_quality.automatic'
    };

String _gridSizeToString(GridSize size) => switch (size) {
      GridSize.large => 'settings.image_grid.grid_size.large',
      GridSize.small => 'settings.image_grid.grid_size.small',
      GridSize.normal => 'settings.image_grid.grid_size.medium'
    };

String _imageListToString(ImageListType imageListType) =>
    switch (imageListType) {
      ImageListType.standard => 'settings.image_list.standard',
      ImageListType.masonry => 'settings.image_list.masonry'
    };

class _AppearancePageState extends ConsumerState<AppearancePage> {
  late final ValueNotifier<double> _spacingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _borderRadiusSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _paddingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _aspectRatioSliderValue = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _spacingSliderValue.value = settings.imageGridSpacing;
    _borderRadiusSliderValue.value = settings.imageBorderRadius;
    _paddingSliderValue.value = settings.imageGridPadding;
    _aspectRatioSliderValue.value = settings.imageGridAspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final dynamicColorSupported = ref.watch(dynamicColorSupportProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.appearance.appearance').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SettingsHeader(label: 'settings.general'.tr()),
            SettingsTile<ThemeMode>(
              title: const Text('settings.theme.theme').tr(),
              selectedOption: settings.themeMode,
              items: [...ThemeMode.values]..remove(ThemeMode.system),
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(themeMode: value)),
              optionBuilder: (value) => Text(_themeModeToString(value).tr()),
            ),
            Builder(builder: (context) {
              return SwitchListTile(
                title: const Text('Dynamic theme color'),
                subtitle: dynamicColorSupported
                    ? !isDesktopPlatform()
                        ? const Text(
                            'Sync theme color with wallpaper',
                          )
                        : const Text(
                            "Sync theme color with OS's accent color",
                          )
                    : Text(
                        '${!isDesktopPlatform() ? 'Sync theme color with wallpaper.' : 'Sync theme color with OS\'s accent color.'}This device does not support dynamic color.',
                      ),
                value: settings.enableDynamicColoring,
                onChanged: dynamicColorSupported
                    ? (value) => ref.updateSettings(
                        settings.copyWith(enableDynamicColoring: value))
                    : null,
              );
            }),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
            SettingsTile<GridSize>(
              title: const Text('settings.image_grid.grid_size.grid_size').tr(),
              selectedOption: settings.gridSize,
              items: GridSize.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(gridSize: value)),
              optionBuilder: (value) => Text(_gridSizeToString(value).tr()),
            ),
            SettingsTile<ImageListType>(
              title: const Text('settings.image_list.image_list').tr(),
              selectedOption: settings.imageListType,
              items: ImageListType.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(imageListType: value)),
              optionBuilder: (value) => Text(_imageListToString(value)).tr(),
            ),
            if (settings.imageListType == ImageListType.standard)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Aspect ratio'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildAspectRatioSlider(settings),
                  ],
                ),
              ),
            SettingsTile<ImageQuality>(
              title: const Text(
                'settings.image_grid.image_quality.image_quality',
              ).tr(),
              subtitle: settings.imageQuality == ImageQuality.highest
                  ? Text(
                      'settings.image_grid.image_quality.high_quality_notice',
                      style: TextStyle(
                        color: context.theme.hintColor,
                      ),
                    ).tr()
                  : null,
              selectedOption: settings.imageQuality,
              items: [...ImageQuality.values]..remove(ImageQuality.original),
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(imageQuality: value)),
              optionBuilder: (value) => Text(_imageQualityToString(value)).tr(),
            ),
            SettingsTile<PageMode>(
              title: const Text('settings.result_layout.result_layout').tr(),
              selectedOption: settings.pageMode,
              subtitle: settings.pageMode == PageMode.infinite
                  ? const Text('settings.infinite_scroll_warning').tr()
                  : null,
              items: const [...PageMode.values],
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(pageMode: value)),
              optionBuilder: (value) => Text(_layoutToString(value)).tr(),
            ),
            if (settings.pageMode == PageMode.paginated)
              SettingsTile<PageIndicatorPosition>(
                title: const Text('Page indicator position'),
                selectedOption: settings.pageIndicatorPosition,
                items: const [...PageIndicatorPosition.values],
                onChanged: (value) => ref.updateSettings(
                    settings.copyWith(pageIndicatorPosition: value)),
                optionBuilder: (value) => Text(
                  switch (value) {
                    PageIndicatorPosition.top => 'Top',
                    PageIndicatorPosition.bottom => 'Bottom',
                    PageIndicatorPosition.both => 'Both',
                  },
                ),
              ),
            SwitchListTile(
              title: const Text('settings.appearance.show_scores').tr(),
              value: settings.showScoresInGrid,
              onChanged: (value) => ref
                  .updateSettings(settings.copyWith(showScoresInGrid: value)),
            ),
            SwitchListTile(
              title: const Text('Show posts configuration header'),
              value: settings.showPostListConfigHeader,
              onChanged: (value) =>
                  ref.setPostListConfigHeaderStatus(active: value),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('settings.image_grid.spacing').tr(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildSpacingSlider(settings),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('settings.image_grid.corner_radius').tr(),
                  ),
                  _buildBorderRadiusSlider(settings),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('settings.image_grid.padding').tr(),
                  ),
                  _buildPaddingSlider(settings),
                ],
              ),
            ),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_details.image_details'.tr()),
            SettingsTile<PostDetailsOverlayInitialState>(
              title: const Text('settings.image_details.ui_overlay').tr(),
              selectedOption: settings.postDetailsOverlayInitialState,
              items: PostDetailsOverlayInitialState.values,
              onChanged: (value) => ref.updateSettings(
                  settings.copyWith(postDetailsOverlayInitialState: value)),
              optionBuilder: (value) => Text(
                switch (value) {
                  PostDetailsOverlayInitialState.show =>
                    'settings.image_details.ui_overlay.show',
                  PostDetailsOverlayInitialState.hide =>
                    'settings.image_details.ui_overlay.hide',
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorderRadiusSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _borderRadiusSliderValue,
      builder: (context, value, child) {
        return Slider(
          label: value.toInt().toString(),
          divisions: 10,
          max: 10,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageBorderRadius: value)),
          onChanged: (value) => _borderRadiusSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildSpacingSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _spacingSliderValue,
      builder: (context, value, child) {
        return Slider(
          label: value.toInt().toString(),
          divisions: 10,
          max: 10,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageGridSpacing: value)),
          onChanged: (value) => _spacingSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildPaddingSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _paddingSliderValue,
      builder: (context, value, child) {
        return Slider(
          label: value.toInt().toString(),
          divisions: 8,
          max: 32,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageGridPadding: value)),
          onChanged: (value) => _paddingSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildAspectRatioSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _aspectRatioSliderValue,
      builder: (context, value, child) {
        return Slider(
          label: value.toStringAsFixed(1),
          divisions: 10,
          max: 1.5,
          min: 0.5,
          value: value,
          onChangeEnd: (value) => ref
              .updateSettings(settings.copyWith(imageGridAspectRatio: value)),
          onChanged: (value) => _aspectRatioSliderValue.value = value,
        );
      },
    );
  }
}

String _layoutToString(PageMode category) => switch (category) {
      PageMode.infinite => 'settings.result_layout.infinite_scroll',
      PageMode.paginated => 'settings.result_layout.pagination'
    };
