part of ld39;

abstract class Scene {

  int backgroundColor;
  String backgroundKey;
  phaser.Sprite background;
  phaser.Sprite<p2.Body> flashlight;
  phaser.Graphics lightMask;
  phaser.Sprite light;
  num lightRadius;

  num mouseX, mouseY;
  num mouseDX, mouseDY;
  bool mouseClicked;
  p2.CollisionGroup mouseCollisionGroup;

  Scene(this.backgroundColor, this.backgroundKey, this.lightRadius);

  void preload() {
    game.load.image(backgroundKey, 'res/$backgroundKey.png');
    game.load.image('flashlight', 'res/flashlight.png');
    game.load.image('light', 'res/light.png');
  }

  void create() {
    game.physics.p2.restitution = 1;

    game.stage.backgroundColor = backgroundColor;
    background = game.add.sprite(0, 0, backgroundKey);

    mouseCollisionGroup = game.physics.p2.createCollisionGroup();

    flashlight = game.add.sprite(0, 0, 'flashlight');
    game.physics.p2.enable(flashlight);
    flashlight.body.setCollisionGroup(mouseCollisionGroup);
    flashlight.body.collides(mouseCollisionGroup);
    flashlight.body.fixedRotation = true;

    lightMask = game.add.graphics();
    game.stage.mask = lightMask;
    light = game.add.sprite(0, 0, 'light');

    mouseX = mouseY = 0;
    mouseDX = mouseDY = 0;
    mouseClicked = false;
    game.input.onDown.add(mouseDown);
    game.input.onUp.add(mouseUp);
    game.input.addMoveCallback(mouseMove);
    mouseMove(game.width / 2, game.height / 2, null);
  }

  void update() {
    //if (game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ battery ]).length == 0) {
    flashlight.body.x = mouseX;
    flashlight.body.y = mouseY;
    //}
    flashlight.body.velocity.x = mouseDX;
    flashlight.body.velocity.y = mouseDY;
  }

  void render();

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

class SceneLD extends Scene {

  phaser.Sprite<p2.Body> battery;
  Wire wire;

  SceneLD() : super(0x222222, 'scene', 200) {
  }

  void create() {
    super.create();
    wire = new Wire(this, 'wire', 100, 100, true, 11, 5, 100, 300);
    battery = game.add.sprite(200, 200, 'battery');
    game.physics.p2.enable(battery);

    battery.body.setCollisionGroup(mouseCollisionGroup);
    battery.body.collides(mouseCollisionGroup);
  }

  void preload() {
    super.preload();
    game.load.image('battery', 'res/battery.png');
    game.load.image('wire', 'res/wire.png');
  }

  void render() {

  }

  void update() {
    super.update();
    wire.update();
    if (mouseClicked && distance(mouseX, mouseY, battery.body.x, battery.body.y) < 50) {
      battery.body.velocity.x = random.nextDouble() * 2000 - 1000;
      battery.body.velocity.y = random.nextDouble() * 2000 - 1000;
      mouseClicked = false;
    }
  }



}