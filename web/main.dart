library ld39;

import 'dart:html';
import 'dart:math';
import 'package:play_phaser/phaser.dart' as phaser;
import 'package:play_phaser/p2.dart' as p2;



Random random;

void main() {
  random = new Random();
  phaser.Game game = new phaser.Game(800, 450, phaser.WEBGL, 'game');
  game.state.add('play', new PlayState());
  game.state.start('play');
}

class PlayState extends phaser.State {

  phaser.Sprite background;
  phaser.Sprite<p2.Body> flashlight;
  phaser.Sprite<p2.Body> battery;
  phaser.Graphics lightMask;
  phaser.Sprite light;
  num lightRadius;

  num mouseX, mouseY;
  num mouseDX, mouseDY;
  bool mouseClicked;
  p2.CollisionGroup mouseCollisionGroup;

  void preload() {
    game.load.image('background', 'res/background.png');
    game.load.image('battery', 'res/battery.png');
    game.load.image('flashlight', 'res/flashlight.png');
    game.load.image('wire', 'res/wire.png');
    game.load.image('light', 'res/light.png');
  }

  void create() {
    game.physics.startSystem(phaser.Physics.P2JS);
    stage.backgroundColor = 0x222222;
    background = game.add.sprite(0, 0, 'background');

    battery = game.add.sprite(200, 200, 'battery');
    mouseX = mouseY = 0;
    mouseDX = mouseDY = 0;
    flashlight = game.add.sprite(0, 0, 'flashlight');

    mouseCollisionGroup = game.physics.p2.createCollisionGroup();
    game.physics.p2.updateBoundsCollisionGroup();

    game.physics.p2.restitution = 1;

    game.physics.p2.enable(flashlight);
    flashlight.body.setCollisionGroup(mouseCollisionGroup);
    flashlight.body.collides(mouseCollisionGroup);
    flashlight.body.fixedRotation = true;

    game.physics.p2.enable(battery);
    battery.body.setCollisionGroup(mouseCollisionGroup);
    battery.body.collides(mouseCollisionGroup);

    createWire(400, 300, 5);

    lightMask = game.add.graphics();
    stage.mask = lightMask;
    light = game.add.sprite(0, 0, 'light');
    lightRadius = 200;

    game.input.onDown.add(mouseDown);
    game.input.onUp.add(mouseUp);
    game.input.addMoveCallback(mouseMove);
    mouseClicked = false;
    mouseMove(game.width / 2, game.height / 2, null);
  }

  void createWire(num x, num y, num length) {
    phaser.Sprite<p2.Body> lastRect;
    phaser.Sprite<p2.Body> newRect;
    num width = 5;
    num height = 20;
    num maxForce = 20000;
    p2.CollisionGroup collisionGroup = game.physics.p2.createCollisionGroup();
    for (int i = 0; i < length; i++) {
      newRect = game.add.sprite(x, y + i * height, 'wire');
      game.physics.p2.enable(newRect);
      //flashlight.body.setCollisionGroup(collisionGroup);
      flashlight.body.collides(collisionGroup);

      newRect.body.setCollisionGroup(collisionGroup);
      newRect.body.collides(mouseCollisionGroup);
      if (lastRect != null) {
        game.physics.p2.createRevoluteConstraint(newRect, [ 0, -height / 2 + width / 2 ], lastRect, [ 0, height / 2 - width / 2 ]);
      }
      lastRect = newRect;
    }
  }

  void update() {
    //if (game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ battery ]).length == 0) {
      flashlight.body.x = mouseX;
      flashlight.body.y = mouseY;
    //}
    flashlight.body.velocity.x = mouseDX;
    flashlight.body.velocity.y = mouseDY;
    if (mouseClicked && game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ battery ]).length > 0) {
      battery.body.velocity.x = random.nextDouble() * 1000 - 500;
      battery.body.velocity.y = random.nextDouble() * 1000 - 500;
      mouseClicked = false;
    }
  }

  void render() {

  }

  void mouseDown(phaser.Pointer pointer, MouseEvent event) {
    mouseClicked = true;
  }

  void mouseUp(phaser.Pointer pointer, MouseEvent event) {
    mouseClicked = false;
  }

  void mouseMove(num x, num y, bool fromClick) {
    mouseDX = x - mouseX;
    mouseDY = y - mouseY;
    mouseX = x;
    mouseY = y;
    lightMask.clear();
    lightMask.beginFill(0x000000);
    lightMask.drawCircle(x, y, lightRadius);
    light.x = x - lightRadius;
    light.y = y - lightRadius;
    light.width = light.height = lightRadius * 2;
  }

}