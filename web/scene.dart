part of ld39;

abstract class Scene {

  int backgroundColor;
  String backgroundKey;
  phaser.Sprite background;
  phaser.Sprite<p2.Body> flashlight;
  phaser.Graphics arm;
  phaser.Graphics lightMask;
  phaser.Sprite light;
  num lightRadius;

  List<Device> devices;
  List<Removable> removables;
  List<Switch> switches;
  List<Battery> batteries;
  List<Wire> wires;
  List<AttachableEnd> attachableEnds;
  p2.CollisionGroup mouseCollisionGroup;
  p2.CollisionGroup wireCollisionGroup;

  num mouseX, mouseY;
  num mouseTargetX, mouseTargetY;
  num mouseDX, mouseDY;
  bool mouseClicked;

  Scene(this.backgroundColor, this.backgroundKey, this.lightRadius) {
    devices = new List<Device>();
    removables = new List<Removable>();
    switches = new List<Switch>();
    batteries = new List<Battery>();
    wires = new List<Wire>();
    attachableEnds = new List<AttachableEnd>();
  }

  void checkVoltages() {
    Map<String, AttachableEnd> ends = new Map<String, AttachableEnd>();
    for (AttachableEnd end in attachableEnds) {
      ends[end.id] = end;
    }
    bool won = true;
    for (Device device in devices) {
      if (!device.check(ends)) {
        won = false;
      }
    }
    if (won) {
      print('WON');
    }
  }

  void preload() {
    game.load.image(backgroundKey, 'res/$backgroundKey.png');
    game.load.spritesheet('flashlight', 'res/flashlight.png', 50, 110);
    game.load.image('light', 'res/light.png');
  }

  void create() {
    game.physics.p2.restitution = 1;

    game.stage.backgroundColor = backgroundColor;
    background = game.add.sprite(0, 0, backgroundKey);

    mouseCollisionGroup = game.physics.p2.createCollisionGroup();
    wireCollisionGroup = game.physics.p2.createCollisionGroup();

    flashlight = game.add.sprite(0, 0, 'flashlight', 1);
    game.physics.p2.enable(flashlight);
    flashlight.anchor = new phaser.Point(0.5, 25 / 110);
    flashlight.body.clearShapes();
    flashlight.body.addCircle(25, 0, 0);
    flashlight.body.setCollisionGroup(mouseCollisionGroup);
    flashlight.body.collides(mouseCollisionGroup);
    flashlight.body.collides(wireCollisionGroup);
    //flashlight.body.fixedRotation = true;
    flashlight.body.kinematic = true;
    flashlight.body.mass = 1000000.0;
    flashlight.animations.add('hit')
      ..onStart.add((obj, ani) => flashlight.frame = 0)
      ..onComplete.add((obj, ani) => flashlight.frame = 1);
    arm = game.add.graphics();
    lightMask = game.add.graphics();
    game.stage.mask = lightMask;
    light = game.add.sprite(0, 0, 'light');

    mouseClicked = false;
    game.input.onDown.add(mouseDown);
    game.input.onUp.add(mouseUp);
    game.input.addMoveCallback(mouseMove);
    mouseMove(game.width / 2, game.height / 2, null);
  }

  void update() {
    updateMouse();
  }

  void preRender() {
    if (arm != null) {
      arm.clear();
      arm.lineStyle(20, 0xe9afaf);
      arm.moveTo(game.width / 2, game.height + 10);
      arm.lineTo(flashlight.body.x + 15, flashlight.body.y + 75);
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
    if (mouseX == null) mouseX = x;
    if (mouseY == null) mouseY = y;
    mouseTargetX = x;
    mouseTargetY = y;
  }

  void updateMouse() {
    num a = angle(mouseX, mouseY, mouseTargetX, mouseTargetY);
    num d = min(distance(mouseX, mouseY, mouseTargetX, mouseTargetY), 20);
    mouseDX = cos(a) * d;
    mouseDY = sin(a) * d;
    mouseX += mouseDX;
    mouseY += mouseDY;
    flashlight.body.x = mouseX;
    flashlight.body.y = mouseY;
    flashlight.body.velocity.x = mouseDX;
    flashlight.body.velocity.y = mouseDY;
    lightMask.clear();
    if (game.stage.mask != null) {
      lightMask.beginFill(0x000000);
      lightMask.drawCircle(mouseX, mouseY, lightRadius);
    }
    light.x = mouseX - lightRadius;
    light.y = mouseY - lightRadius;
    light.width = light.height = lightRadius * 2;
  }

}