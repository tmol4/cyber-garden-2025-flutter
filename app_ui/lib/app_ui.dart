library;

export 'src/utils.dart';
export 'package:app_ui/src/custom_app_bar.dart';
export 'package:app_ui/src/custom_list.dart';

import 'package:app_ui/src/flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            type: .small,
            collapsedContainerColor: colorTheme.surfaceContainer,
            expandedContainerColor: colorTheme.surfaceContainer,
            title: Text("Нейротех"),
            trailing: Padding(
              padding: .fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: Flex.horizontal(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const IconLegacy(Symbols.keep_rounded, fill: 0.0),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: IconLegacy(Symbols.settings_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverList.list(children: []),
        ],
      ),
    );
  }
}
