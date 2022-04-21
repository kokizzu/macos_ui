import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class TabViewPage extends StatefulWidget {
  const TabViewPage({Key? key}) : super(key: key);

  @override
  State<TabViewPage> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage> {
  TabPosition positionSelected = TabPosition.top;
  Widget content = Container();

  void updatePosition(TabPosition? pos) {
    return setState(() => positionSelected = pos ?? TabPosition.top);
  }

  Widget _radioButton(TabPosition pos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MacosRadioButton<TabPosition>(
            groupValue: positionSelected,
            value: pos,
            onChanged: updatePosition,
          ),
          const SizedBox(width: 10),
          Text(pos.name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      titleBar: const TitleBar(
        title: Text('macOS Tab View'),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    const Text('Tab View Controls Position'),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _radioButton(TabPosition.top),
                        _radioButton(TabPosition.bottom),
                        _radioButton(TabPosition.left),
                        _radioButton(TabPosition.right),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TabView(
                      width: 500,
                      height: 400,
                      position: positionSelected,
                      body: content,
                      tabs: [
                        // TODO: Replace PushButton with ScopedButton
                        PushButton(
                          child: const Text('Sound Effects'),
                          buttonSize: ButtonSize.small,
                          isSecondary: true,
                          onPressed: () {
                            setState(() {
                              content = const Center(
                                child: Text('Sound Effects'),
                              );
                            });
                          },
                        ),
                        PushButton(
                          child: const Text('Input'),
                          buttonSize: ButtonSize.small,
                          onPressed: () {
                            setState(() {
                              content = const Center(
                                child: Text('Input'),
                              );
                            });
                          },
                        ),
                        PushButton(
                          child: const Text('Output'),
                          buttonSize: ButtonSize.small,
                          onPressed: () {
                            setState(() {
                              content = const Center(
                                child: Text('Output'),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
