part of ld39;

class SceneLD extends Scene {

  bool ejected;

  SceneLD() : super(0x222222, 'scene', 200) {
    ejected = false;
  }

  void create() {
    super.create();
    removables.add(new Removable(this, 'cover', 695, 200, 50, 25));
    switches.add(new Switch(this, 'switch', 75, 235, false));
    switches.add(new Switch(this, 'switch', 95, 235, true));
    switches.add(new Switch(this, 'switch', 135, 325, false));
    wires.add(new Wire(this, 'wire', 100, 100, true, 28, 300, 300, true, 10));
    batteries.add(new Battery(this, 3, 300, 200));
    game.world.bringToTop(flashlight);
    game.world.bringToTop(light);
  }

  void preload() {
    super.preload();
    game.load.image('cover', 'res/cover.png');
    game.load.spritesheet('switch', 'res/switch.png', 10, 30);
    game.load.image('battery_3', 'res/battery_3.png');
    game.load.image('wire', 'res/wire.png');
  }

  void render() {

  }

  void update() {
    super.update();
    for (Removable removable in removables) {
      removable.update();
      if (mouseClicked && game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ removable.sprite.body ]).length > 0) {
        removable.hit();
        mouseClicked = false;
      }
    }
    bool switchesOn = true;
    for (Switch button in switches) {
      if (game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ button.spriteOff.body ]).length > 0) {
        if (button.switched == false) {
          button.hit();
        }
      } else {
        button.switched = false;
      }
      if (!button.spriteOn.visible) {
        switchesOn = false;
      }
    }
    if (switchesOn && !ejected) {
      eject();
      ejected = true;
    }
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
  }

  void eject() {
    wires.add(new Wire(this, 'wire', 130, 230, true, 13, 130, 231));
    flashlight.bringToTop();
  }

}