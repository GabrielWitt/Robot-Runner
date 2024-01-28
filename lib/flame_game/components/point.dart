import '../endless_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// The [Point] components are the components that the [Player] should collect
/// to finish a level. The points are represented by Flame's mascot; Ember.
class Point extends SpriteAnimationComponent
    with HasGameReference, HasWorldReference<EndlessWorld> {
  Point() : super(size: spriteSize, anchor: Anchor.center);

  static final Vector2 spriteSize = Vector2.all(100);
  final speed = 200;

  @override
  Future<void> onLoad() async {
    animation = await game.loadSpriteAnimation(
      'objects/screwItem.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    );
    flipHorizontallyAroundCenter();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= (world.speed + speed) * dt;
    if (position.x + size.x / 2 < -world.size.x / 2) {
      removeFromParent();
    }
  }
}
