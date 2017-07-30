library ld39;

import 'dart:html';
import 'dart:math';
import 'package:play_phaser/phaser.dart' as phaser;
import 'package:play_phaser/p2.dart' as p2;

part 'scene.dart';
part 'sceneLD.dart';
part 'device.dart';
part 'battery.dart';
part 'removable.dart';
part 'switch.dart';
part 'wire.dart';

Random random;
phaser.Game game;

void main() {
  random = new Random();
  game = new phaser.Game(800, 450, phaser.WEBGL, 'game');
  game.state.add('title', new TitleState());
  game.state.add('play', new PlayState(new SceneLD()));
  game.state.start('title');
}

class TitleState extends phaser.State {

  phaser.Sprite background;
  phaser.Graphics black;

  List<String> lines = [ "Clumsy Clemens goes to space",
                         "In a rocket, what a sight!",
                         "But many problems he shall face",
                         "By losing power during flight",
                         "But Clumsy Clemens got this down",
                         "Some batteries he'll introduce",
                         "There is no time to linger around",
                         "Before the flashlight lacks the juice" ];

  void preload() {
    game.load.image('background_1', 'res/background_1.png');
    game.load.image('background_2', 'res/background_2.png');
  }

  void create() {
    stage.backgroundColor = 0xEEEEEE;
    background = game.add.sprite(0, 0, 'background_1');
    background.alpha = 0;
    game.add.tween(background)
        .to({ 'alpha': 0.5 }, 2000, null, true, 5000);
    black = game.add.graphics();
    black.beginFill(0x222222);
    black.drawRect(0, 0, game.width, game.height);
    black.alpha = 0;
    game.add.tween(black)
        .to({ 'alpha': 1 }, 0, null, true, 10000)
        .onComplete.add((_) => goBlack());
    phaser.TextStyle style = new phaser.TextStyle(fill: '#222222', font: 'bold 20pt monospace', align: 'center');
    for (int i = 0; i < 3; i++) {
      phaser.Text text = game.add.text(game.width ~/ 2, 100 + i * 50, lines[i], style);
      text.anchor.setTo(0.5, 0);
      text.alpha = 0;
      game.add.tween(text)
          .to({ 'alpha': 1 }, 2000, null, true, 1000 + i * 3000)
          .to({ 'alpha': 0 }, 100, null, true, 1000 + (2 - i) * 3000);
    }
    game.input.onDown.add((_, __) => skip());
  }

  void goBlack() {
    background.destroy();
    phaser.TextStyle styleWhite = new phaser.TextStyle(fill: '#EEEEEE', font: 'bold 20pt monospace', align: 'center');
    phaser.Text textWhite = game.add.text(game.width ~/ 2, 250, lines[3], styleWhite);
    textWhite.anchor.setTo(0.5, 0);
    textWhite.alpha = 0;
    game.add.tween(textWhite)
        .to({ 'alpha': 1 }, 2000, null, true, 2000)
        .to({ 'alpha': 0 }, 2000, null, true, 5000);
    game.add.tween(black)
        .to({ 'alpha': 0 }, 2000, null, true, 5000)
        .to({ 'alpha': 1 }, 2000, null, true, 11000);
    background = game.add.sprite(0, 0, 'background_2');
    black.bringToTop();
    textWhite.bringToTop();
    background.alpha = 0;
    game.add.tween(background)
        .to({ 'alpha': 0.5 }, 2000, null, true, 9000);
    phaser.TextStyle style = new phaser.TextStyle(fill: '#222222', font: 'bold 20pt monospace', align: 'center');
    for (int i = 0; i < 4; i++) {
      phaser.Text text = game.add.text(game.width ~/ 2, 100 + i * 50, lines[i + 4], style);
      text.anchor.setTo(0.5, 0);
      text.alpha = 0;
      game.add.tween(text)
          .to({ 'alpha': 1 }, 2000, null, true, 5000 + i * 3000);
    }
    game.add.tween(new phaser.Sprite(game)).to({ }, 0, null, true, 20000).onComplete.add((_) => skip());
  }

  void skip() {
    stage.backgroundColor = 0x222222;
    game.state.start('play');
  }

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

  void preRender() {
    scene.preRender();
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