import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

class Background extends ParallaxComponent {
  final double speed;

  Background({required this.speed});

  @override
  Future<void> onLoad() async {
    final layers = [
      ParallaxImageData('./city/1.png'), // Sky background
      ParallaxImageData('./city/2.png'), // Small Buildings
      ParallaxImageData('./city/3.png'), // Tall buildings
      ParallaxImageData('./city/floor.png'), // Floor
      ParallaxImageData('./city/5.png'), // Skygrapers images/city/
    ];

    final baseVelocity = Vector2(speed / pow(2, layers.length), 0);
    final velocityMultiplierDelta = Vector2(2.0, 0.0);

    parallax = await game.loadParallax(
      layers,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      filterQuality: FilterQuality.none,
    );
  }
}