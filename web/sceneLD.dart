part of ld39;

class SceneLD extends Scene {

  SceneLD() : super(0x222222, 'scene', 200) {

  }

  void create() {
    super.create();
    wires.add(new Wire(this, 'wire', 100, 100, true, 28, 10, 300, 300));
    batteries.add(new Battery(this, 3, 300, 200));
    removables.add(new Removable(this, 'cover', 695, 200, 50, 25));
    game.world.bringToTop(flashlight);
    game.world.bringToTop(light);
  }

  void preload() {
    super.preload();
    game.load.image('battery_3', 'res/battery_3.png');
    game.load.image('wire', 'res/wire.png');
    game.load.image('cover', 'res/cover.png');
  }

  void render() {

  }

  void update() {
    super.update();
    for (Wire wire in wires) {
      wire.update();
    }
    for (Battery battery in batteries) {
      battery.update();
      if (mouseClicked && distance(mouseX, mouseY, battery.sprite.body.x, battery.sprite.body.y) < 80) {
        battery.hit(angle(mouseX, mouseY, battery.sprite.body.x, battery.sprite.body.y));
        mouseClicked = false;
      }
    }
    for (Removable removable in removables) {
      removable.update();
      if (mouseClicked && game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ removable.sprite.body ]).length > 0) {
        removable.hit();
        mouseClicked = false;
      }
    }
  }

}