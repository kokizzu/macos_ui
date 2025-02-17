import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  group('MacosWindow', () {
    group('Sidebar', () {
      const minWidth = 100.0;
      const maxWidth = 300.0;
      const startWidth = 150.0;
      const safeDelta = 20.0;
      const overflowDelta = 500.0;

      final sidebarBuilder = ({
        bool dragClosed = true,
        double? dragClosedBuffer,
        double? snapToStartBuffer,
      }) {
        return Sidebar(
          builder: (context, scrollController) => const Text('Hello there'),
          minWidth: minWidth,
          startWidth: startWidth,
          maxWidth: maxWidth,
          dragClosed: dragClosed,
          dragClosedBuffer: dragClosedBuffer,
          snapToStartBuffer: snapToStartBuffer,
        );
      };

      final viewBuilder = (Sidebar sidebar) {
        return MacosApp(
          home: MacosWindow(
            sidebar: sidebar,
            child: const MacosScaffold(
              children: [],
            ),
          ),
        );
      };

      final sidebarFinder = find.byType(AnimatedPositioned).first;
      final resizerFinder = find.byType(AnimatedPositioned).at(3);
      final backgroundFinder = find.byType(AnimatedPositioned).at(1);

      final expectSidebarOpen = (tester, {required double width}) {
        expect(
          tester.widget<AnimatedPositioned>(sidebarFinder).width,
          width,
        );
        expect(
          tester.widget<AnimatedPositioned>(backgroundFinder).left,
          width,
        );
      };

      final expectSidebarClosed = (tester) {
        expect(
          tester.widget<AnimatedPositioned>(sidebarFinder).width,
          minWidth,
        );
        expect(
          tester.widget<AnimatedPositioned>(backgroundFinder).left,
          0,
        );
      };

      testWidgets('initial width equals startWidth', (tester) async {
        final sidebar = sidebarBuilder();
        final view = viewBuilder(sidebar);
        await tester.pumpWidget(view);

        expectSidebarOpen(tester, width: startWidth);
      });

      test('dragClosedBuffer defaults to half minWidth', () {
        final sidebar = sidebarBuilder();
        expect(sidebar.dragClosedBuffer, minWidth / 2);
      });

      testWidgets('dragging wider works', (tester) async {
        final view = viewBuilder(sidebarBuilder());
        await tester.pumpWidget(view);
        await tester.drag(resizerFinder, const Offset(safeDelta, 0));
        await tester.pump();

        expectSidebarOpen(tester, width: startWidth + safeDelta);
      });

      testWidgets('dragging wider respects maxWidth', (tester) async {
        final view = viewBuilder(sidebarBuilder());
        await tester.pumpWidget(view);
        await tester.drag(resizerFinder, const Offset(overflowDelta, 0));
        await tester.pump();

        expectSidebarOpen(tester, width: maxWidth);
      });

      testWidgets('drag events past maxWidth have no effect', (tester) async {
        final view = viewBuilder(sidebarBuilder());
        await tester.pumpWidget(view);
        final gesture =
            await tester.startGesture(tester.getCenter(resizerFinder));
        await gesture.moveBy(const Offset(overflowDelta, 0));
        await gesture.moveBy(const Offset(-safeDelta, 0));
        await gesture.up();
        await tester.pump();

        expectSidebarOpen(tester, width: maxWidth);
      });

      testWidgets('dragging narrower works', (tester) async {
        final view = viewBuilder(sidebarBuilder());
        await tester.pumpWidget(view);
        await tester.drag(resizerFinder, const Offset(-safeDelta, 0));
        await tester.pump();

        expectSidebarOpen(tester, width: startWidth - safeDelta);
      });

      group('when dragClosed is true', () {
        testWidgets(
          'dragging narrower past minWidth but before minWidth - dragClosedBuffer does not close the sidebar',
          (tester) async {
            final dragClosedBuffer = 20.0;
            final view =
                viewBuilder(sidebarBuilder(dragClosedBuffer: dragClosedBuffer));
            await tester.pumpWidget(view);
            await tester.drag(
              resizerFinder,
              Offset(
                -((startWidth - minWidth) + dragClosedBuffer / 2),
                0,
              ),
            );
            await tester.pump();

            expectSidebarOpen(tester, width: minWidth);
          },
        );
        testWidgets(
          'dragging narrower past minWidth closes the sidebar',
          (tester) async {
            final view = viewBuilder(sidebarBuilder());
            await tester.pumpWidget(view);
            await tester.drag(resizerFinder, const Offset(-overflowDelta, 0));
            await tester.pump();

            expectSidebarClosed(tester);
          },
        );

        testWidgets(
          'dragging narrower past minWidth and then back reopens the sidebar',
          (tester) async {
            final view = viewBuilder(sidebarBuilder());
            await tester.pumpWidget(view);
            final gesture =
                await tester.startGesture(tester.getCenter(resizerFinder));
            for (var moved = 0; moved < overflowDelta; moved += 10) {
              await gesture.moveBy(const Offset(-10, 0));
            }
            await tester.pump();

            expectSidebarClosed(tester);

            for (var moved = 0;
                moved < overflowDelta - safeDelta;
                moved += 10) {
              await gesture.moveBy(const Offset(10, 0));
            }
            await gesture.up();
            await tester.pump();

            expectSidebarOpen(tester, width: startWidth - safeDelta);
          },
        );

        testWidgets('drag events past minWidth have no effect', (tester) async {
          final view = viewBuilder(sidebarBuilder());
          await tester.pumpWidget(view);
          final gesture =
              await tester.startGesture(tester.getCenter(resizerFinder));
          await gesture.moveBy(const Offset(-overflowDelta, 0));
          await gesture.moveBy(const Offset(safeDelta, 0));
          await gesture.up();
          await tester.pump();

          expectSidebarClosed(tester);
        });
      });

      group('when dragClosed is false', () {
        testWidgets(
          'dragging narrower past minWidth does not close the sidebar',
          (tester) async {
            final view = viewBuilder(sidebarBuilder(dragClosed: false));
            await tester.pumpWidget(view);
            await tester.drag(resizerFinder, const Offset(-overflowDelta, 0));
            await tester.pump();

            expectSidebarOpen(tester, width: minWidth);
          },
        );

        testWidgets('drag events past minWidth have no effect', (tester) async {
          final view = viewBuilder(sidebarBuilder(dragClosed: false));
          await tester.pumpWidget(view);
          final gesture =
              await tester.startGesture(tester.getCenter(resizerFinder));
          await gesture.moveBy(const Offset(-overflowDelta, 0));
          await gesture.moveBy(const Offset(safeDelta, 0));
          await gesture.up();
          await tester.pump();

          expectSidebarOpen(tester, width: minWidth);
        });
      });

      group('when snapToStartBuffer is set', () {
        final snapToStartBuffer = 20.0;

        testWidgets(
          'dragging from startWidth has no effect until it passes snapToStartBuffer',
          (tester) async {
            final view = viewBuilder(
              sidebarBuilder(
                snapToStartBuffer: snapToStartBuffer,
              ),
            );
            await tester.pumpWidget(view);

            final gesture =
                await tester.startGesture(tester.getCenter(resizerFinder));
            await gesture.moveBy(Offset(snapToStartBuffer, 0));
            await tester.pump();

            expectSidebarOpen(tester, width: startWidth);

            await gesture.moveBy(Offset(snapToStartBuffer, 0));
            await tester.pump();

            expectSidebarOpen(
              tester,
              width: startWidth + snapToStartBuffer * 2,
            );
          },
        );

        testWidgets(
          'dragging from outside to within startWidth +/- snapToStartBuffer sets width to startWidth',
          (tester) async {
            final view = viewBuilder(
              sidebarBuilder(
                snapToStartBuffer: snapToStartBuffer,
              ),
            );
            await tester.pumpWidget(view);

            await tester.drag(resizerFinder, Offset(snapToStartBuffer * 2, 0));
            await tester.pump();

            expectSidebarOpen(
              tester,
              width: startWidth + snapToStartBuffer * 2,
            );

            await tester.drag(
              resizerFinder,
              Offset(snapToStartBuffer * -1.5, 0),
            );
            await tester.pump();
            expectSidebarOpen(tester, width: startWidth);
          },
        );
      });
    });
  });
}
