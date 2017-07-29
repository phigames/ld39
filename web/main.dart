library ld39;

import 'dart:html';
import 'dart:math';
import 'package:play_phaser/phaser.dart' as phaser;
import 'package:play_phaser/p2.dart' as p2;

part 'scene.dart';
part 'sceneLD.dart';
part 'battery.dart';
part 'removable.dart';
part 'switch.dart';
part 'wire.dart';

Random random;
phaser.Game game;

void main() {
  random = new Random();
  game = new phaser.Game(800, 450, phaser.WEBGL, 'game');
  game.state.add('play', new PlayState(new SceneLD()));
  game.state.start('play');
}

class PlayState extends phaser.State {

  Scene scene;

  PlayState(this.scene);

  void preload() {
    scene.preload();
  }

  void create() {
    game.physics.startSystem(phaser.Physics.P2JS);
    game.physics.p2.updateBoundsCollisionGroup();
    scene.create();
  }

  void update() {
    scene.update();
  }

  void render() {
    scene.render();
  }

}

num distance(num x1, num y1, num x2, num y2) {
  num dx = x2 - x1, dy = y2 - y1;
  return sqrt(dx * dx + dy * dy);
}

num angle(num x1, num y1, num x2, num y2) {
  return atan2(y2 - y1, x2 - x1);
}