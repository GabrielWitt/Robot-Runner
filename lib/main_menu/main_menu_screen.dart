import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ranger_gabo/audio/audio_controller.dart';
import 'package:ranger_gabo/audio/sounds.dart';
import 'package:ranger_gabo/settings/settings.dart';

import 'package:ranger_gabo/style/palette.dart';
import 'package:ranger_gabo/style/responsive_screen.dart';
import 'package:ranger_gabo/style/wobbly_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pallette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController =  context.watch<AudioController>();

    return Scaffold(
      backgroundColor: pallette.backgroundMain.color,
      body: ResponsiveScreen(
        squarishMainArea: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/banner.png',
                filterQuality: FilterQuality.none,
              ),
              _space,
              Transform.rotate(
                angle: -0.1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: const Text(
                    'Gabriel Witt Game demo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Press Start 2P',
                      fontSize: 32,
                      height: 1
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WobblyButton(
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context).go('/play');
              },
              child: const Text('Start'),
            ),
            _space,
            WobblyButton(
              onPressed: () => GoRouter.of(context).push('/settings'),
              child: const Text('Settings'),
            ),
            _space,
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ValueListenableBuilder<bool>(
                valueListenable: settingsController.audioOn,
                builder: (context, audioOn, child) {
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () => settingsController.toggleAudioOn(), 
                        icon: Icon(audioOn ? Icons.volume_up : Icons.volume_off),
                      ),
                      Text(
                        audioOn ? 'Audio: On' : 'Audio: Off',
                        textAlign: TextAlign.center,
                        style: const TextStyle (
                          fontFamily: 'Press Start 2P',
                          fontSize: 16,
                          height: 1
                        ),
                      ),
                    ],
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }

  static const _space = SizedBox(height: 10);
}