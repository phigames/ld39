part of ld39;

class SceneLD extends Scene {

  bool ejected;

  SceneLD() : super(0x222222, 'scene', 200) {
    ejected = false;
  }

  void create() {
    super.create();
    //devices.add(new Device('1a_A', '1b_A', Battery.NINE_V));
    devices.add(new Device('2a_A', '2b_A', Battery.THREE_V));
    //devices.add(new Device('3a_A', '4a_B', Battery.THREE_V));
    devices.add(new Device('4a_A', '4b_A', Battery.NINE_V, lightsOn, lightsOff));
    //devices.add(new Device('5a_E', '5b_E', Battery.NINE_V));
    removables.add(new Removable(this, 'cover', 695, 200, -50, 25)
      ..onRemoved = ejectFromCover);
    Removable button1 = new Removable(this, 'button', 210, 110, null, null);
    button1.onRemoved = () => ejectFromButton(button1.sprite, '2a');
    Removable button2 = new Removable(this, 'button', 240, 110, null, null);
    button2.onRemoved = () => ejectFromButton(button2.sprite, '2b');
    Removable button3 = new Removable(this, 'button', 425, 305, null, null);
    button3.onRemoved = () => ejectFromButton(button3.sprite, '3a');
    removables.add(button1);
    removables.add(button2);
    removables.add(button3);
    switches.add(new Switch(this, 'switch', 75, 235, false));
    switches.add(new Switch(this, 'switch', 95, 235, true));
    switches.add(new Switch(this, 'switch', 135, 325, false));
    wires.add(new Wire(this, '4a', 545, 115, true, 18, 445, 215, true, null, 1));
    wires.add(new Wire(this, '4b', 565, 115, true, 15, 645, 225, true, null, 1));
    batteries.add(new Battery(this, Battery.THREE_V, 500, 400));
    batteries.add(new Battery(this, Battery.THREE_V, 550, 400));
    batteries.add(new Battery(this, Battery.NINE_V, 630, 400));
    batteries.add(new Battery(this, Battery.NINE_V, 690, 400));
    batteries.add(new Battery(this, Battery.NINE_V, 750, 400));
    game.world.bringToTop(flashlight);
    game.world.bringToTop(light);
    lightsOn();
  }

  void lightsOn() {
    light.visible = false;

  }

  void lightsOff() {

  }

  void preload() {
    super.preload();
    game.load.image('cover', 'res/cover.png');
    game.load.image('button', 'res/button.png');
    game.load.spritesheet('switch', 'res/switch.png', 10, 30);
    game.load.image('battery_3', 'res/battery_3.png');
    game.load.image('battery_9', 'res/battery_9.png');
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
      ejectFromSwitches();
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

  void ejectFromSwitches() {
    wires.add(new Wire(this, '1a', 130, 230, true, 13, 130, 231));
    wires.add(new Wire(this, '1b', 130, 230, true, 13, 131, 230));
    flashlight.bringToTop();
    light.bringToTop();
  }

  void ejectFromButton(phaser.Sprite<p2.Body> button, String id) {
    wires.add(new Wire(this, id, button.x, button.y, true, 10, button.x, button.y, true, button, 8));
    button.bringToTop();
    flashlight.bringToTop();
    light.bringToTop();
  }

  void ejectFromCover() {
    wires.add(new Wire(this, '5a', 675, 205, true, 2, 695, 195, false));
    wires.add(new Wire(this, '5b', 695, 205, true, 3, 715, 195, false));
    flashlight.bringToTop();
    light.bringToTop();
  }

}